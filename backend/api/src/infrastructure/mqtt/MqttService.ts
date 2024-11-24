import {RedisService} from '../../application/services/RedisService';
import {Worker} from 'worker_threads';
import path from 'path';
import {Channels} from "../../domain/enums/Channels";
import {SenseShelf, SenseShelfModel, shelfSchema} from "../../domain/models/Facility/SenseShelf";
import {MobileDeviceModel} from "../../domain/models/MobileDevice/MobileDevice";
import {NotificationEvent} from "../../application/events/NotificationEvent";
import {FirebaseMessaging} from "../firebaseMessaging/FirebaseMessaging";
import {randomUUID} from "node:crypto";
import {InventoryEventModel} from "../../domain/models/Facility/InventoryEvent";

const THRESHOLD_MAX = 4085;
const THRESHOLD_MIN = 4084;

export class MqttService {
    private redisService: RedisService;
    private mqttWorker: Worker | undefined;
    private firebaseMessaging: FirebaseMessaging;

    constructor(redisService: RedisService) {
        this.redisService = redisService;
        this.firebaseMessaging = new FirebaseMessaging();
    }

    initialize() {
        this.mqttWorker = new Worker(path.join(__dirname, 'MqttWorker.js'));

        this.mqttWorker.on('message', (msg) => {
         //   parentPort?.postMessage(msg);
            this.handleMessage(msg);
        });

        this.mqttWorker.on('error', (error) => {
            console.error('MQTT Worker error:', error);
        });

        this.mqttWorker.on('exit', (code) => {
            if (code !== 0) {
                console.error(`MQTT Worker stopped with exit code ${code}`);
            }
        });
    }

    /**
     * Internal handle message
     * @param msg
     * @private
     */
    private async handleMessage(msg: any) {
        switch (msg.type) {
            case 'error':
                console.error('MQTT Error:', msg.message);
                break;
            case 'message':
                await this.handleMqttMessage(msg);
                break;
            default:
               // console.log('Unknown message from MQTT worker:', msg);
        }
    }

    /**
     * Handles the MQTT message
     * @param msg {any} The MQTT message
     * @private
     */
    private async handleMqttMessage(msg: any) {
        if (msg.topic === Channels.SHELVES) {
            try {
                const json = JSON.parse(msg.message);
                const readTime = json.readTime;
                const shelfData: SenseShelf = {
                    name: json.deviceName,
                    macAddress: json.deviceId,
                    layoutId: json.facilityLayoutId,
                    facilityId: json.facilityId,
                    lastSeen: Math.floor(Date.now() / 1000),
                    delta: json.delta,
                    currentMeasure: json.readMeasure,
                };
                const key = shelfData.macAddress;
                const existingShelf = await this.redisService.senseShelfRepository?.fetch(key);
                shelfData.currentUpc = existingShelf?.currentUpc;
                shelfData.currentMeasure = existingShelf?.currentQuantity;
                shelfData.lastReadMeasure = existingShelf?.currentMeasure || existingShelf?.lastReadMeasure || 0;
                if (existingShelf?.name !== shelfData.name) {
                    const devices = await this.fetchMobileDevicesByFacilityId(shelfData.facilityId);
                    if (devices.length > 0) {
                        const notificationEvent = new NotificationEvent(
                            "New Shelf Online",
                            `A new shelf named ${shelfData.name} has come online at your facility.`,
                            {
                                shelfId: shelfData.macAddress,
                                facilityLayoutId: shelfData.layoutId,
                                facilityId: shelfData.facilityId
                            }
                        );
                        await this.firebaseMessaging.sendNotification(
                            devices.map(device => device.fcmToken),
                            notificationEvent
                        );
                    }
                }
                if (readTime) {
                    shelfData.currentMeasure = json.readMeasure;
                    if (shelfData.currentMeasure == null) return;
                    const devices = await this.fetchMobileDevicesByFacilityId(shelfData.facilityId);
                    console.log("Change Event ", shelfData);

                    const isRisingEdge = shelfData.currentMeasure >= THRESHOLD_MAX && shelfData.lastReadMeasure < THRESHOLD_MIN;
                    const inventoryEvent = isRisingEdge
                        ? await this.handleRisingEdge(shelfData)
                        : await this.handleFallingEdge({ ...shelfData, ...existingShelf });

                    // dispatch a notification regarding dispensing or receiving inventory
                    if (devices.length > 0 && inventoryEvent) {
                        const formattedDateTime = this.formatTimestamp(inventoryEvent.timestamp);
                        const eventType = isRisingEdge ? 'Receive Confirmed' : 'Dispensing';
                        const messagePrefix = isRisingEdge ? '' : 'Confirm dispensing ';

                        const notificationEvent = new NotificationEvent(
                            `${eventType} ${inventoryEvent.upc}, qty. ${inventoryEvent.quantity}`,
                            `${messagePrefix}${inventoryEvent.quantity} units of ${inventoryEvent.upc} ${isRisingEdge ? 'from' : 'to'} ${shelfData.name}${isRisingEdge ? ' registered' : '?'} Inventory ${eventType.toLowerCase()} event occurred at ${formattedDateTime}.`,
                            {
                                shelfId: shelfData.macAddress,
                                facilityLayoutId: shelfData.layoutId,
                                facilityId: shelfData.facilityId,
                                upc: inventoryEvent.upc,
                                quantity: inventoryEvent.quantity.toString()
                            }
                        );

                        await this.firebaseMessaging.sendNotification(
                            devices.map(device => device.fcmToken),
                            notificationEvent
                        );
                    }
                }
                const newShelf = new SenseShelfModel(shelfData);
                await this.redisService.senseShelfRepository?.save(newShelf.macAddress, newShelf);
            } catch (error) {
                console.error('Failed to save shelf:', error);
            }
        } else if (msg.topic.includes(Channels.FIREBASE_MESSAGING)) {
            console.log(`Incoming msg on Firebase channel ${msg.topic}`)
            const facilityId = msg.topic.split('/')[2];
            console.log(`Facility is ${facilityId}`)
            const json = JSON.parse(msg.message);
            const devices = await this.fetchMobileDevicesByFacilityId(facilityId);
            const notificationEvent = NotificationEvent.fromJson(json);
            console.log(notificationEvent)
            await this.firebaseMessaging.sendNotification(
                devices.map(device => device.fcmToken),
                notificationEvent
            );
        }
    }

    /**
     * Handles confirming a checkin event when a bottle is placed on a shelf
     * @param shelfData
     */
    async handleRisingEdge(shelfData: SenseShelf) {
        const inventoryEventRepository = this.redisService.inventoryEventRepository;
        const senseShelfRepository = this.redisService.senseShelfRepository;
        const latestCheckinEvent = await this.getLastCheckinEvent(shelfData.facilityId);
        if (latestCheckinEvent) {
            latestCheckinEvent.isConfirmed = true;
            latestCheckinEvent.facilityLayoutId = shelfData.layoutId;
            latestCheckinEvent.shelfId = shelfData.macAddress;
            latestCheckinEvent.confirmedAt = Math.floor(Date.now() / 1000);
            await inventoryEventRepository?.save(latestCheckinEvent.uid, latestCheckinEvent);
            await this.redisService.persist(`InventoryEventModel:${latestCheckinEvent}`)
            shelfData.currentUpc = latestCheckinEvent.upc;
            shelfData.currentQuantity = latestCheckinEvent.quantity;
            await senseShelfRepository?.save(shelfData.macAddress, shelfData);
        }
        return latestCheckinEvent;
    }

    /**
     * Handles creating an unconfirmed checkout event when
     * @param shelfData
     */
    async handleFallingEdge(shelfData: SenseShelf) {
        const inventoryEventRepository = this.redisService.inventoryEventRepository;
        const senseShelfRepository = this.redisService.senseShelfRepository;
        if (!shelfData.currentUpc || !shelfData.currentQuantity) return; // ignore a checkout event without a product UPC
        const eventId = randomUUID();
        const checkOutEvent =  InventoryEventModel.toModel({
            eventType: 'dispense',
            upc: shelfData.currentUpc,
            quantity: shelfData.currentQuantity,
            isConfirmed: false,
            shelfId: shelfData.macAddress,
            facilityLayoutId: shelfData.layoutId,
            facilityId: shelfData.facilityId,
            timestamp: Math.floor(Date.now() / 1000),
            uid: eventId
        })
        await inventoryEventRepository?.save(eventId, checkOutEvent);
        await inventoryEventRepository?.expire(eventId, 1200);
        // clear the current upc from the shelf
        shelfData.currentUpc = undefined;
        await senseShelfRepository?.save(shelfData.macAddress, shelfData);
        return checkOutEvent;
    }

    /**
     * Formats a unix timestamp
     * This should go in a helper
     * @param timestamp
     * @private
     */
    private formatTimestamp(timestamp: number): string {
        const date = new Date(timestamp * 1000);
        return date.toLocaleString('en-US', {
            year: 'numeric',
            month: 'long',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit',
            timeZoneName: 'short'
        });
    }

    /**
     * Get Last Checkin Event
     * @param facilityId
     * @private
     */
    private async getLastCheckinEvent(facilityId: string) {
        return await this.redisService.inventoryEventRepository?.search()
            .where('eventType').equals('receive')
            .and('isConfirmed').equals(false)
            .and('facilityId').equals(facilityId)
            .sortBy('timestamp', 'DESC')
            .return.first();
    }

    /**
     * Fetches devices at a facility
     * @param facilityId {string}
     * @return {MobileDeviceModel[]}
     */
    private fetchMobileDevicesByFacilityId = async (facilityId: string): Promise<MobileDeviceModel[]> =>{
        try {
            const devices = await this.redisService.mobileDeviceRepository?.search()
                .where('facilityId').eq(facilityId)
                .return.all();
            if (!devices?.length) return [];
            return devices.map(device => MobileDeviceModel.toModel(device));
        } catch (error) {
            console.error('Error fetching mobile devices:', error);
            throw error;
        }
    }
}