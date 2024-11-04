import { z } from 'zod';
import { BaseModel, validationSchemaKey } from "../BaseModel";
import {FacilityLayout, FacilityLayoutModel} from "./FacilityLayout";
import {Repository, Schema} from "redis-om";

/**
 * Validation Schema for Facility
 */
export const facilitySchema = z.object({
  uid: z.string(),
  name: z.string(),
  address: z.string(),
  contact: z.string().optional(),
  layoutIds: z.array(z.string()).optional()
});

/**
 * Facility Type inferred from the Zod schema
 */
export type Facility = z.infer<typeof facilitySchema>;

export class FacilityModel extends BaseModel<Facility> {
  [validationSchemaKey] = facilitySchema;

  uid: string;
  name: string;
  address: string;
  contact?: string;
  layoutIds?: string[];

  /**
   * @param data - The Facility data to initialize the model with
   */
  constructor(data: Facility) {
    super();
    this.uid = data.uid;
    this.name = data.name;
    this.address = data.address;
    this.contact = data.contact;
    this.layoutIds = data.layoutIds;
  }

  /**
   * Defines the Redis OM schema for FacilityModel
   */
  static schema() {
    return new Schema(
        this.name,
        {
          uid: { type: 'string', indexed: true },
          name: { type: 'string', indexed: true },
          address: { type: 'string' },
          contact: {
            type: 'string'
          },
          layoutIds: { type: 'string[]', indexed: true }
        }
    );
  }

  /**
   * Fetch the layouts associated with this facility from Redis
   * @param repository - The repository for FacilityLayoutModel
   */
  async fetchLayouts(repository: Repository<FacilityLayout>): Promise<FacilityLayoutModel[]> {
    if (!this.layoutIds) return [];

    const layoutPromises = this.layoutIds.map(async (layoutId: string) => {
      const layout = await repository.fetch(layoutId);
      if (layout) return FacilityLayoutModel.toModel(layout);
    });

    return (await Promise.all(layoutPromises)).filter(Boolean) as FacilityLayoutModel[];
  }

  /**
   * Update or add a layout to the facility
   * @param layout - The FacilityLayoutModel instance to update with
   * @param repository - The repository for FacilityLayoutModel
   */
  async updateLayout(layout: FacilityLayout, repository: Repository<Facility>): Promise<void> {
    if (!this.layoutIds) this.layoutIds = [];
    this.layoutIds.push(layout.uid);
    await repository.save(this.uid, this);
  }
}