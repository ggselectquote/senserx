import express from 'express';
import { Repository } from 'redis-om';
import { InventoryEvent, InventoryEventModel } from "../../../../domain/models/Facility/InventoryEvent";
import { randomUUID } from "node:crypto";
import {RedisService} from "../../../services/RedisService";
import {NotificationEvent} from "../../../events/NotificationEvent";
import mqtt, { MqttClient } from 'mqtt';
import {Channels} from "../../../../domain/enums/Channels";
import {SenseShelf} from "../../../../domain/models/Facility/SenseShelf";

export class InventoryEventsController {
    private inventoryEventRepository: Repository<InventoryEvent>;
    private redisService: RedisService;
    private mqttClient: MqttClient;
    private senseShelfRepository: Repository<SenseShelf>;

    /**
     * @constructs InventoryEventsController
     * @param inventoryEventRepository
     * @param senseShelfRepository
     * @param redisService
     */
    constructor(inventoryEventRepository: Repository<InventoryEvent>, senseShelfRepository: Repository<SenseShelf>, redisService: RedisService) {
        this.inventoryEventRepository = inventoryEventRepository;
        this.senseShelfRepository = senseShelfRepository;
        this.redisService = redisService;
        const host = process.env.MQTT_SERVER_URL || 'localhost';
        const port = process.env.MQTT_SERVER_PORT || '1883';
        const clientId = `mqtt_${Math.random().toString(16).slice(3)}`;
        const connectUrl = `mqtt://${host}:${port}`;
        this.mqttClient = mqtt.connect(connectUrl, {
            clientId,
            clean: true,
            connectTimeout: 4000,
            username: process.env.MQTT_USERNAME,
            password: process.env.MQTT_PASSWORD,
            reconnectPeriod: 1000,
        });
    }

    /**
     * Creates a new InventoryEvent
     * @param req
     * @param res
     * @param next
     */
    public create = async (req: express.Request, res: express.Response, next: express.NextFunction): Promise<void> => {
        try {
            const { eventType, upc, quantity, facilityId } = req.body;

            const uid = randomUUID();
            const timestamp = Math.floor(Date.now() / 1000);

            const newInventoryEvent = InventoryEventModel.toModel({
                eventType,
                upc,
                quantity,
                isConfirmed: false,
                facilityId,
                timestamp,
                uid
            });

            newInventoryEvent.validate(newInventoryEvent);

            await this.inventoryEventRepository.save(uid, newInventoryEvent);
            await this.inventoryEventRepository.expire(uid, 1200);

            res.status(201).json(newInventoryEvent);
            const notificationEvent = new NotificationEvent(
                `Receive Started`,
                `Place your ${upc} container on a shelf to confirm finish the receive process.`,
                { facilityId, upc }
            );
            this.mqttClient.publish(Channels.FIREBASE_MESSAGING + `/${facilityId}`, JSON.stringify(notificationEvent))
        } catch (error) {
            next(error);
        }
    }

    /**
     * Updates the most recent unconfirmed checkout event at a facility
     * @param req
     * @param res
     */
    public updateLatestUnconfirmedCheckout = async (req: express.Request, res: express.Response): Promise<void> => {
        try {
            const { facilityId, upc, quantity } = req.body;

            const latestUnconfirmedCheckout = await this.inventoryEventRepository.search()
                .where('eventType').equals('dispense')
                .and('isConfirmed').equals(false)
                .and('facilityId').equals(facilityId)
                .and('upc').equals(upc)
                .sortBy('timestamp', 'DESC')
                .return.first();

            if (latestUnconfirmedCheckout) {
                const updatedEvent = { ...latestUnconfirmedCheckout, quantity, isConfirmed: true, confirmedAt: Math.floor(Date.now() / 1000)};
                await this.inventoryEventRepository.save(latestUnconfirmedCheckout.uid!, updatedEvent);
                await this.redisService.persist(`InventoryEventModel:${latestUnconfirmedCheckout.uid!}`)
                res.status(200).json(updatedEvent);
                const { facilityLayoutId, shelfId } = updatedEvent;
                if (!shelfId || !facilityLayoutId) return;
                const senseShelf = await this.senseShelfRepository.fetch(shelfId);
                if (!senseShelf) return;
                const notificationEvent = new NotificationEvent(
                    `Dispense Confirmed`,
                    `Dispensed ${upc} from ${senseShelf.name}, qty. ${latestUnconfirmedCheckout.quantity}.`,
                    { facilityId, upc, quantity: quantity.toString(), shelfId, facilityLayoutId }
                );
                this.mqttClient.publish(Channels.FIREBASE_MESSAGING + `/${facilityId}`, JSON.stringify(notificationEvent))
                return
            } else {
                res.status(404).json({ message: `No dispense events found for ${upc} at this facility.` });
                return
            }
        } catch (error) {
            console.error(error)
            res.status(500).json({message: error})
            return
        }
    }
}