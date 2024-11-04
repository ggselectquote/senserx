import express from 'express';
import { Repository } from 'redis-om';
import {Facility, FacilityModel} from "../../../../domain/models/Facility/Facility";
import {randomUUID} from "node:crypto";

export class FacilitiesController {
    private facilityRepository: Repository<Facility>;

    /**
     * @constructs FacilitiesController
     * @param facilityRepository
     * @param layoutRepository
     */
    constructor(facilityRepository: Repository<Facility>) {
        this.facilityRepository = facilityRepository;
    }

    /**
     * Creates a facility
     * @param req
     * @param res
     * @param next
     */
    public create = async (req: express.Request, res: express.Response, next: express.NextFunction): Promise<void> => {
        try {
            const { name, address, contact } = req.body;
            const uid = randomUUID()
            const newFacility = FacilityModel.toModel({ name, address, contact, uid });
            await this.facilityRepository.save(uid, newFacility);
            res.status(201).json(newFacility);
        } catch (error) {
            next(error);
        }
    }

    /**
     * Gets all facilities
     * @param req
     * @param res
     * @param next
     */
    public getAll = async (req: express.Request, res: express.Response, next: express.NextFunction): Promise<void> => {
        try {
            const facilities = await this.facilityRepository.search().return.all();
            res.json(facilities);
        } catch (error) {
            next(error);
        }
    }

    /**
     * Gets a facility by ID
     * @param req
     * @param res
     * @param next
     */
    public getOne = async (req: express.Request, res: express.Response, next: express.NextFunction): Promise<void> => {
        try {
            const facility = await this.facilityRepository.fetch(req.params.id);
            if (facility) {
                res.json(facility);
            } else {
                res.status(404).send('Facility not found');
            }
        } catch (error) {
            next(error);
        }
    }

    /**
     * Updates a facility
     * @param req
     * @param res
     * @param next
     */
    public update = async (req: express.Request, res: express.Response, next: express.NextFunction): Promise<void> => {
        try {
            const { id } = req.params;
            const facility = await this.facilityRepository.fetch(id);
            if (facility) {
                Object.assign(facility, FacilityModel.toModel(req.body));
                await this.facilityRepository.save(facility);
                res.json(facility);
            } else {
                res.status(404).send('Facility not found');
            }
        } catch (error) {
            next(error);
        }
    }

    /**
     * Deletes a facility
     * @param req
     * @param res
     * @param next
     */
    public delete = async (req: express.Request, res: express.Response, next: express.NextFunction): Promise<void> => {
        try {
            const { id } = req.params;
            const facility = await this.facilityRepository.fetch(id);
            if (facility) {
                await this.facilityRepository.remove(id);
                res.status(204).send();
            } else {
                res.status(404).send('Facility not found');
            }
        } catch (error) {
            next(error);
        }
    }
}