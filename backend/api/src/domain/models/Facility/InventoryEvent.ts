import { z } from 'zod';
import { BaseModel, validationSchemaKey } from "../BaseModel";
import { Schema } from "redis-om";

/**
 * Validation Schema for InventoryEvent
 */
export const inventoryEventSchema = z.object({
    eventType: z.string(),
    upc: z.string(),
    uid: z.string(),
    quantity: z.number(),
    isConfirmed: z.boolean().optional().nullish(),
    facilityId: z.string(),
    shelfId: z.string().optional().nullish(),
    facilityLayoutId: z.string().optional().nullish(),
    timestamp: z.number(),
    confirmedAt: z.number().optional().nullish(),
});

/**
 * InventoryEvent Type inferred from the Zod schema
 */
export type InventoryEvent = z.infer<typeof inventoryEventSchema>;

export class InventoryEventModel extends BaseModel<InventoryEvent> {
    [validationSchemaKey] = inventoryEventSchema;

    uid: string;
    eventType: string;
    upc: string;
    quantity: number;
    isConfirmed: boolean;
    facilityId: string;
    shelfId?: string;
    facilityLayoutId?: string;
    timestamp: number;
    confirmedAt?: number;

    /**
     * @param data - The InventoryEvent data to initialize the model with
     */
    constructor(data: InventoryEvent) {
        super();
        this.uid = data.uid;
        this.eventType = data.eventType;
        this.upc = data.upc;
        this.quantity = data.quantity;
        this.isConfirmed = data.isConfirmed ?? false;
        this.facilityId = data.facilityId;
        this.shelfId = data.shelfId ?? undefined;
        this.facilityLayoutId = data.facilityLayoutId ?? undefined;
        this.timestamp = data.timestamp || Math.floor(Date.now() / 1000);
        this.confirmedAt = data.confirmedAt ?? undefined;
    }

    /**
     * Defines the Redis OM schema for InventoryEventModel
     */
    static schema() {
        return new Schema(
            this.name,
            {
                uid: { type: 'string', indexed: true },
                eventType: { type: 'string', indexed: true },
                upc: { type: 'string', indexed: true },
                isConfirmed: { type: 'boolean', indexed: true },
                facilityId: { type: 'string', indexed: true },
                shelfId: { type: 'string', indexed: true },
                facilityLayoutId: { type: 'string', indexed: true },
                timestamp: { type: 'number', indexed: true, sortable: true },
                quantity: { type: 'number' },
                confirmedAt: { type: 'number' },
            }
        );
    }
}