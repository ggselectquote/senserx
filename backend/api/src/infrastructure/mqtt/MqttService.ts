// mqtt/MqttService.ts
import {RedisService} from '../../application/services/RedisService';
import {Worker} from 'worker_threads';
import path from 'path';
import {Channels} from "../../domain/enums/Channels";
import {SenseShelf, SenseShelfModel} from "../../domain/models/Facility/SenseShelf";
import {MobileDeviceModel} from "../../domain/models/MobileDevice/MobileDevice";
import {NotificationEvent} from "../../application/events/NotificationEvent";
import {FirebaseMessaging} from "../firebaseMessaging/FirebaseMessaging";

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
        switch (msg.topic) {
            case Channels.SHELVES:
                try {
                    const json = JSON.parse(msg.message);
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
                    shelfData.lastReadMeasure = existingShelf?.currentMeasure || existingShelf?.lastReadMeasure || 0;
                    if (!existingShelf?.name) {
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
                    if (shelfData?.delta) {
                        shelfData.currentMeasure = json.readMeasure;
                        const devices = await this.fetchMobileDevicesByFacilityId(shelfData.facilityId);

                    }
                    const newShelf = new SenseShelfModel(shelfData);
                    await this.redisService.senseShelfRepository?.save(newShelf.macAddress, newShelf);
                } catch (error) {
                    console.error('Failed to save shelf:', error);
                }
                break;
        }
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