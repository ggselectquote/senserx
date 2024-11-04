import {z} from 'zod';
import { BaseModel } from "../BaseModel";
import { validationSchemaKey } from "../BaseModel";
import {Repository, Schema} from "redis-om";
import {SenseShelf, SenseShelfModel, shelfSchema} from "./SenseShelf";

/**
 * Facility Layout Type Definition
 */
export const facilityLayoutSchema = z.object({
    uid: z.string(),
    facilityId: z.string(),
    parentId: z.string().optional(),
    name: z.string(),
    description: z.string().optional(),
    type: z.enum(['floor', 'room', 'section', 'wall', 'wing', 'unit']),
    subLayouts: z.array(z.string()).optional(),
    children: z.array(z.lazy((): any => facilityLayoutSchema)).optional(),
    shelves: z.array(z.lazy((): any => shelfSchema)).optional(),
});

/**
 * Facility Layout Type inferred from the Zod schema
 */
export type FacilityLayout = z.infer<typeof facilityLayoutSchema>;

/**
 * FacilityLayout Model
 */
export class FacilityLayoutModel extends BaseModel<FacilityLayout> {
    [validationSchemaKey] = facilityLayoutSchema;

    uid: string;
    facilityId: string;
    parentId?: string;
    name: string;
    description?: string;
    type: 'floor' | 'room' | 'section' | 'wall' | 'wing' | 'unit';
    subLayouts?: string[];
    children?: FacilityLayout[];
    shelves?: SenseShelf[];

    /**
     * @constructs FacilityLayoutModel
     * @param data
     */
    constructor(data: FacilityLayout) {
        super();
        this.uid = data.uid;
        this.facilityId = data.facilityId;
        this.parentId = data.parentId;
        this.name = data.name;
        this.description = data.description;
        this.type = data.type;
        this.subLayouts = data.subLayouts;
        this.children = data.children;
        this.shelves = data.shelves;
    }

    /**
     * @static Redis Schema
     */
    static schema() {
        return new Schema(
            this.name,
            {
                uid: { type: 'string', indexed: true },
                facilityId: { type: 'string', indexed: true },
                parentId: {type: 'string', indexed: true },
                name: { type: 'string', indexed: true },
                description: { type: 'string' },
                type: { type: 'string', indexed: true },
                subLayouts: { type: 'string[]', indexed: true }
            }
        );
    }

    /**
     * Fetches the sub-layouts for a facility
     * @param repository
     */
    async fetchSubLayouts(repository: Repository<FacilityLayoutModel>): Promise<FacilityLayoutModel[]> {
        if (!this.subLayouts) return [];

        const subLayoutPromises = this.subLayouts.map(async (subLayoutId) => {
            const subLayout = await repository.fetch(subLayoutId);
            if (subLayout) return FacilityLayoutModel.toModel(subLayout);
        });

        return (await Promise.all(subLayoutPromises)).filter(Boolean) as FacilityLayoutModel[];
    }


    /**
     * Fetches shelves for a layout
     * @param repository
     */
    async fetchShelves(repository: Repository<SenseShelf>): Promise<SenseShelf[]> {
        const shelves = await repository.search()
            .where('layoutId').eq(this.uid)
            .return.all();
        this.shelves = shelves.map(shelf => SenseShelfModel.toModel(shelf));

        return this.shelves;
    }
}