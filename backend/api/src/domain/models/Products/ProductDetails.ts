import {BaseModel, validationSchemaKey} from "../BaseModel";
import { z } from 'zod';
import {Schema} from "redis-om";

/**
 * Validation Schema
 */
export const productDetailsSchema = z.object({
  ean: z.string(),
  title: z.string(),
  description: z.string(),
  upc: z.string(),
  brand: z.string(),
  model: z.string(),
  color: z.string(),
  size: z.string(),
  dimension: z.string(),
  weight: z.string(),
  category: z.string(),
  currency: z.string(),
  lowest_recorded_price: z.string(),
  highest_recorded_price: z.string(),
  images: z.array(z.string())
});

/**
 * Product Details Type Definition
 */
export type ProductDetails = z.infer<typeof productDetailsSchema>;

/**
 * ProductDetails Model
 */
export class ProductDetailsModel extends BaseModel<ProductDetails> {
  [validationSchemaKey] = productDetailsSchema;

  ean: string;
  title: string;
  description: string;
  upc: string;
  brand: string;
  model: string;
  color: string;
  size: string;
  weight: string;
  category: string;
  currency: string;
  dimension: string;
  lowest_recorded_price: string;
  highest_recorded_price: string;
  images: string[];

  constructor(data: any) {
      super();
      this.ean  = data.ean;
      this.title = data.title;
      this.description = data.description;
      this.upc = data.upc;
      this.brand = data.brand;
      this.model = data.model;
      this.color = data.color;
      this.size = data.size;
      this.weight = data.weight;
      this.category = data.category;
      this.currency = data.currency;
      this.lowest_recorded_price = data.lowest_recorded_price;
      this.highest_recorded_price = data.highest_recorded_price;
      this.images = data.images;
      this.dimension = data.dimension;
  }

  static schema () {
    return new Schema(
        this.name,
        {
          upc: { type: 'string', indexed: true },
          ean: { type: 'string' },
          title: { type: 'string' },
          description: { type: 'text' },
          brand: { type: 'string' },
          model: { type: 'string' },
          color: { type: 'string' },
          size: { type: 'string' },
          dimension: { type: 'string' },
          weight: { type: 'string' },
          category: { type: 'string' },
          currency: { type: 'string' },
          lowest_recorded_price: { type: 'string' },
          highest_recorded_price: { type: 'string' },
          images: { type: 'string[]' }
      })
  }
}