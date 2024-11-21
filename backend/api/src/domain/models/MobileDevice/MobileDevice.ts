import { z } from 'zod';
import { BaseModel, validationSchemaKey } from "../BaseModel";
import { Repository, Schema } from "redis-om";
import { FacilityModel } from "../Facility/Facility";
import {randomUUID} from "node:crypto";

/**
 * Validation Schema for MobileDevice
 */
export const mobileDeviceSchema = z.object({
    uid: z.string().uuid(),
    deviceId: z.string(),
    platform: z.string(),
    osVersion: z.string(),
    fcmToken: z.string(),
    lastNotified: z.date().optional().nullable(),
    facilityId: z.string().optional()
});

/**
 * MobileDevice Type inferred from the Zod schema
 */
export type MobileDevice = z.infer<typeof mobileDeviceSchema>;

export class MobileDeviceModel extends BaseModel<MobileDevice> {
    [validationSchemaKey] = mobileDeviceSchema;

    uid: string;
    deviceId: string;
    platform: string;
    osVersion: string;
    fcmToken: string;
    lastNotified?: Date;
    facilityId?: string;

    /**
     * @param data - The MobileDevice data to initialize the model with
     */
    constructor(data: MobileDevice) {
        super();
        this.uid = data.uid || randomUUID();
        this.deviceId = data.deviceId;
        this.platform = data.platform;
        this.osVersion = data.osVersion;
        this.fcmToken = data.fcmToken;
        this.lastNotified = data.lastNotified ?? undefined;
        this.facilityId = data.facilityId;
    }

    /**
     * Defines the Redis OM schema for MobileDeviceModel
     */
    static schema() {
        return new Schema(
            this.name,
            {
                uid: { type: 'string', indexed: true },
                deviceId: { type: 'string', indexed: true },
                platform: { type: 'string', indexed: true },
                osVersion: { type: 'string' },
                fcmToken: { type: 'string' },
                lastNotified: { type: 'date' },
                facilityId: { type: 'string', indexed: true }
            }
        );
    }

    /**
     * Fetch the associated Facility from Redis
     * @param repository - The repository for FacilityModel
     */
    async fetchFacility(repository: Repository<FacilityModel>): Promise<FacilityModel | null> {
        if (!this.facilityId) return null;

        const facility = await repository.fetch(this.facilityId);
        return facility ? FacilityModel.toModel(facility) : null;
    }
}