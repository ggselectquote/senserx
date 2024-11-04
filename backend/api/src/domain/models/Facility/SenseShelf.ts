import { z } from 'zod';
import { BaseModel, validationSchemaKey } from "../BaseModel";
import { Schema } from "redis-om";

/**
 * Validation Schema for Shelf
 */
export const shelfSchema = z.object({
    name: z.string(),
    macAddress: z.string(),
    layoutId: z.string(),
    facilityId: z.string(),
    capacity: z.number().optional(),
    currentUtilization: z.number().optional(),
    productTypes: z.array(z.string()).optional(),
    lastSeen: z.string().optional()
});

/**
 * Shelf Type inferred from the Zod schema
 */
export type SenseShelf = z.infer<typeof shelfSchema>;

export class SenseShelfModel extends BaseModel<SenseShelf> {
    [validationSchemaKey] = shelfSchema;

    name: string;
    macAddress: string;
    layoutId: string;
    facilityId: string;
    capacity?: number;
    currentUtilization?: number;
    productTypes?: string[];
    lastSeen?: string;

    /**
     * @param data - The Shelf data to initialize the model with
     */
    constructor(data: SenseShelf) {
        super();
        this.name = data.name;
        this.macAddress = data.macAddress;
        this.layoutId = data.layoutId;
        this.facilityId = data.facilityId;
        this.capacity = data.capacity;
        this.currentUtilization = data.currentUtilization;
        this.productTypes = data.productTypes;
        this.lastSeen = data.lastSeen ?? new Date().toISOString()
    }

    /**
     * Defines the Redis OM schema for ShelfModel
     */
    static schema() {
        return new Schema(
            this.name,
            {
                name: { type: 'string', indexed: true },
                macAddress: { type: 'string', indexed: true },
                layoutId: { type: 'string', indexed: true },
                facilityId: { type: 'string', indexed: true },
                capacity: { type: 'number' },
                currentUtilization: { type: 'number' },
                productTypes: { type: 'string[]' },
                lastSeen: { type: 'string' }
            }
        );
    }
}