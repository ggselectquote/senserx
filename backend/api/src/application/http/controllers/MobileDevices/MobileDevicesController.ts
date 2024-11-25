import express from 'express';
import {Repository} from 'redis-om';
import {MobileDevice, MobileDeviceModel} from '../../../../domain/models/MobileDevice/MobileDevice'
import {randomUUID} from "node:crypto";

export class MobileDevicesController {
    private mobileDeviceRepository: Repository<MobileDevice>;

    /**
     * @constructs MobileDevicesController
     * @param mobileDeviceRepository
     */
    constructor(mobileDeviceRepository: Repository<MobileDevice>) {
        this.mobileDeviceRepository = mobileDeviceRepository;
    }

    /**
     * Creates a new mobile device
     * @param req
     * @param res
     * @param next
     */
    public create = async (req: express.Request, res: express.Response, next: express.NextFunction): Promise<void> => {
        try {
            const { deviceId, platform, osVersion, fcmToken, facilityId } = req.body;
            const uid = randomUUID();
            const newDevice = new MobileDeviceModel({
                uid,
                deviceId,
                platform,
                osVersion,
                fcmToken,
                lastNotified: null,
                facilityId
            });
            await this.mobileDeviceRepository.save(uid, newDevice);
            res.status(201).json(newDevice);
        } catch (error) {
            next(error);
        }
    }

    /**
     * Gets all mobile devices
     * @param req
     * @param res
     * @param next
     */
    public getAll = async (req: express.Request, res: express.Response, next: express.NextFunction): Promise<void> => {
        try {
            const devices = await this.mobileDeviceRepository.search().return.all();
            res.json(devices);
        } catch (error) {
            next(error);
        }
    }

    /**
     * Gets a mobile device by its UID
     * @param req
     * @param res
     * @param next
     */
    public getOne = async (req: express.Request, res: express.Response, next: express.NextFunction): Promise<void> => {
        try {
            console.log(req.params.id)
            const device = await this.mobileDeviceRepository.fetch(req.params.id);
            if (device?.fcmToken) {
                res.json(device);
            } else {
                res.status(404).send('Mobile device not found');
            }
        } catch (error) {
            next(error);
        }
    }

    /**
     * Updates a mobile device by its UID
     * @param req
     * @param res
     * @param next
     */
    public update = async (req: express.Request, res: express.Response, next: express.NextFunction): Promise<void> => {
        try {
            const device = await this.mobileDeviceRepository.fetch(req.params.id);
            if (device) {
                const { platform, osVersion, fcmToken, facilityId } = req.body;
                const updatedDevice = MobileDeviceModel.toModel({ ...device, platform, osVersion, fcmToken, facilityId });
                await this.mobileDeviceRepository.save(req.params.id, updatedDevice);
                res.json(updatedDevice);
            } else {
                res.status(404).send('Mobile device not found');
            }
        } catch (error) {
            next(error);
        }
    }

    /**
     * Deletes a mobile device by its UID
     * @param req
     * @param res
     * @param next
     */
    public delete = async (req: express.Request, res: express.Response, next: express.NextFunction): Promise<void> => {
        try {
            const device = await this.mobileDeviceRepository.fetch(req.params.id);
            if (device) {
                await this.mobileDeviceRepository.remove(req.params.id);
                res.status(204).send();
            } else {
                res.status(404).send('Mobile device not found');
            }
        } catch (error) {
            next(error);
        }
    }
}