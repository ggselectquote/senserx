import { Entity } from 'redis-om';
import { z } from 'zod';

/**
 * Non-enumerable model property
 */
export const validationSchemaKey = Symbol('validationSchema');

export abstract class BaseModel<T extends Record<string, any>> implements Entity {
    [validationSchemaKey]?: z.ZodType<T>;
    [key:string]: any;

    /**
     * Validates the model
     * @param data
     */
    validate(data: T): void {
        if (!this[validationSchemaKey]) {
            throw new Error('Validation schema not defined for this model.');
        }
        const result = this[validationSchemaKey].safeParse(data);
        if (!result.success) {
            throw new Error(`Validation failed: ${JSON.stringify(result.error.issues)}`);
        }
    }

    /**
     * Convert the model
     * @param data
     */
    static toModel<Model extends BaseModel<Record<string,  any>>, Data extends object>(this: new (data: Data) => Model, data: Data): Model {
        const modelInstance = new this(data);
        const modelProperties = Object.keys(modelInstance);

        for (const property of modelProperties) {
            if (property === 'validationSchema') continue;
            if (data.hasOwnProperty(property)) {
                const modelPropertyType = Reflect.getMetadata("design:type", modelInstance, property) as any;
                const dataValue = (data as any)[property];
                if (Array.isArray(dataValue) && modelPropertyType) {
                    (modelInstance as any)[property] = BaseModel.handleArray(dataValue, modelPropertyType);
                } else {
                    (modelInstance as any)[property] = dataValue;
                }
            }
        }

        return modelInstance;
    }

    /**
     * Parses an array recursively
     * @param dataArray
     * @param modelPropertyType
     * @private
     */
    private static handleArray(dataArray: any[], modelPropertyType: any): any[] {
        if (modelPropertyType.name === 'Array') {
            if (dataArray.length > 0) {
                const firstElement = dataArray[0];
                if (typeof firstElement === 'object' && firstElement !== null) {
                    return dataArray.map(item => JSON.stringify(item));
                }
            }
            return dataArray;
        }
        if (modelPropertyType.prototype instanceof BaseModel) {
            return dataArray.map(item => new modelPropertyType(item));
        }
        return dataArray;
    }
}