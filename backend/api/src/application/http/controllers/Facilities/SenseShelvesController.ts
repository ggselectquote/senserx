import express from 'express';
import { Repository } from 'redis-om';
import { randomUUID } from 'node:crypto';
import { SenseShelfModel } from "../../../../domain/models/Facility/SenseShelf";
import {SenseShelf} from "../../../../domain/models/Facility/SenseShelf";
import {FacilityLayout, FacilityLayoutModel} from "../../../../domain/models/Facility/FacilityLayout";

export class SenseShelvesController {
    private shelfRepository: Repository<SenseShelf>;
    private layoutRepository: Repository<FacilityLayout>;

    constructor(shelfRepository: Repository<SenseShelf>, layoutRepository: Repository<FacilityLayout>) {
        this.shelfRepository = shelfRepository;
        this.layoutRepository = layoutRepository;
    }

    /**
     * Creates a new shelf associated with a specific facility and layout
     * @param req {Request} - Express request object with facilityId and layoutId in params
     * @param res {Response}- Express response object
     * @param next {NextFunction} - Express next middleware function
     */
    public create = async (req: express.Request, res: express.Response, next: express.NextFunction): Promise<void> => {
        try {
            const { facilityId, layoutId } = req.params;
            const { name, macAddress, productTypes, currentUpc } = req.body;
            const layout = await this.layoutRepository.fetch(layoutId);
            const existingDevice = await this.shelfRepository.fetch(macAddress);
            if(existingDevice.macAddress) {
                res.status(400).json({message: "Device already registered"})
                return ;
            }
            if (!layout) {
                res.status(404).json({ message: `Layout with id ${layoutId} not found in facility ${facilityId}` });
                return;
            }
            if (layout.facilityId !== facilityId) {
                res.status(400).json({ message: `Layout ${layoutId} does not belong to facility ${facilityId}` });
                return;
            }
            const uid = randomUUID();
            const newShelf = SenseShelfModel.toModel({
                uid,
                name,
                macAddress,
                layoutId,
                currentUpc,
                facilityId: layout.facilityId,
                productTypes,
                lastSeen: Math.floor(Date.now() / 1000)
            });
            newShelf.validate(newShelf);
            await this.shelfRepository.save(newShelf.macAddress, newShelf);
            res.status(201).json(newShelf);
        } catch (error) {
            next(error);
        }
    }

    /**
     * Gets all shelves associated with a specific facility and layout
     * @param req {express.Request} - Express request object with facilityId and layoutId in params
     * @param res {express.Response} - Express response object
     * @param next {express.NextFunction} - Express next middleware function
     */
    public getAll = async (req: express.Request, res: express.Response, next: express.NextFunction): Promise<void> => {
        try {
            const {  layoutId } = req.params;
            const shelves = await this.shelfRepository.search()
                .where('layoutId').eq(layoutId)
                .return.all();
            res.json(shelves);
        } catch (error) {
            next(error);
        }
    }

    /**
     * Gets a specific shelf by ID within a facility and layout
     * @param req {express.Request} - Express request object with facilityId, layoutId, and id in params
     * @param res {express.Response} - Express response object
     * @param next {express.NextFunction} - Express next middleware function
     */
    public getOne = async (req: express.Request, res: express.Response, next: express.NextFunction): Promise<void> => {
        try {
            const { macAddress } = req.params;
            const shelf = await this.shelfRepository.fetch(macAddress);
            if (shelf) {
                res.json(shelf);
            } else {
                res.status(404).send('Shelf not found');
            }
        } catch (error) {
            next(error);
        }
    }

    /**
     * Updates a shelf within a specific facility and layout, including updating layoutId and facilityId
     * @param req {express.Request} - Express request object with facilityId, layoutId, and shelfId in params
     * @param res {express.Response} - Express response object
     * @param next {express.NextFunction} - Express next middleware function
     */
    public update = async (req: express.Request, res: express.Response, next: express.NextFunction): Promise<void> => {
        try {
            const { facilityId, layoutId, macAddress } = req.params;
            const shelf = await this.shelfRepository.fetch(macAddress);
            if (!shelf) {
                res.status(404).send('Shelf not found');
                return;
            }
            if (req.body.macAddress && req.body.macAddress !== shelf.macAddress) {
                res.status(400).json({ message: "The MAC address cannot be updated, register a new device instead." });
                return;
            }
            if (shelf.layoutId !== layoutId || shelf.facilityId !== facilityId) {
                const newLayout = new FacilityLayoutModel(await this.layoutRepository.fetch(layoutId));
                if (!newLayout.uid) {
                    res.status(404).json({ message: `La235c57c6-082a-4bc7-a754-103664e9f300yout with id ${layoutId} not found in facility ${facilityId}` });
                    return;
                }
                if (newLayout.facilityId !== facilityId) {
                    res.status(400).json({ message: `Layout ${layoutId} does not belong to facility ${facilityId}` });
                    return;
                }
                shelf.facilityId = newLayout.facilityId;
                shelf.layoutId = layoutId;
            }
            const shelfData = SenseShelfModel.toModel({
                ...shelf,
                ...req.body
            });
            shelfData.validate(shelfData);
            await this.shelfRepository.save(macAddress, shelfData);
            res.json(shelfData);
        } catch (error) {
            next(error);
        }
    }

    /**
     * Deletes a shelf within a specific facility and layout by ID
     * @param req {express.Request} - Express request object with facilityId, layoutId, and id in params
     * @param res {express.Response} - Express response object
     * @param next {express.NextFunction} - Express next middleware function
     */
    public delete = async (req: express.Request, res: express.Response, next: express.NextFunction): Promise<void> => {
        try {
            const { facilityId, layoutId, macAddress } = req.params;
            const shelf = await this.shelfRepository.fetch(macAddress);
            if (shelf) {
                if (shelf.layoutId !== layoutId || shelf.facilityId !== facilityId) {
                    res.status(400).json({ message: 'Shelf does not belong to this facility and layout' });
                    return;
                }
                await this.shelfRepository.remove(macAddress);
                res.status(204).send();
            } else {
                res.status(404).send('Shelf not found');
            }
        } catch (error) {
            next(error);
        }
    }
}