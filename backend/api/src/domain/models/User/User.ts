import { z } from 'zod';
import { BaseModel, validationSchemaKey } from "../BaseModel";
import {Repository, Schema} from "redis-om";
import {FacilityModel} from "../Facility/Facility";

/**
 * Validation Schema for User
 */
export const userSchema = z.object({
    uid: z.string(),
    email: z.string(),
    displayName: z.string().optional(),
    role: z.string().optional(),
    facilities: z.array(z.string()).optional()
});

/**
 * User Type inferred from the Zod schema
 */
export type User = z.infer<typeof userSchema>;

export class UserModel extends BaseModel<User> {
    [validationSchemaKey] = userSchema;

    uid: string;
    email: string;
    displayName?: string;
    role?: string;
    facilities?: string[]; // Array of facility IDs

    /**
     * @param data - The User data to initialize the model with
     */
    constructor(data: User) {
        super();
        this.uid = data.uid;
        this.email = data.email;
        this.displayName = data.displayName;
        this.role = data.role;
        this.facilities = data.facilities;
    }

    /**
     * Defines the Redis OM schema for UserModel
     */
    static schema() {
        return new Schema(
            this.name,
            {
                uid: { type: 'string' },
                email: { type: 'string' },
                displayName: { type: 'string' },
                role: { type: 'string' },
                facilities: { type: 'string[]' }
            }
        );
    }

    /**
     * Fetch the facilities associated with this user from Redis
     * @param repository - The repository for FacilityModel
     */
    async fetchFacilities(repository: Repository<FacilityModel>): Promise<FacilityModel[]> {
        if (!this.facilities) return [];

        const facilityPromises = this.facilities.map(async (facilityId) => {
            const facility = await repository.fetch(facilityId);
            if (facility) return FacilityModel.toModel(facility);
        });
        return (await Promise.all(facilityPromises)).filter(Boolean) as FacilityModel[];
    }
}