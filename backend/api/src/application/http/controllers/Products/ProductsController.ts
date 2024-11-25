import express from 'express';
import axios from 'axios';
import dotenv from "dotenv";
import {ProductDetails, ProductDetailsModel} from "../../../../domain/models/Products/ProductDetails";
import {Repository} from "redis-om";

dotenv.config();
const API_BASE_URL = `${process.env.UPC_API_URL}`;

export class ProductDetailsController {
  private productDetailRepository: Repository<ProductDetails>;

  /**
   * @constructs ProductDetailsController
   * @param productDetailRepository {Repository<ProductDetails>}
   */
  constructor(productDetailRepository: Repository<ProductDetails>) {
    this.productDetailRepository = productDetailRepository;
  }

  /**
   * Attempts to find a product by UPC
   * @param req
   * @param res
   * @param next
   */
  public getProductById = async (req: express.Request, res: express.Response, next: express.NextFunction): Promise<void> => {
    try {
      const { upc } = req.params;
      const cachedData =  await this.productDetailRepository.search()
          .where('upc')
          .equals(upc)
          .return.first();
      if (cachedData) {
        res.status(200).json(ProductDetailsModel.toModel(cachedData));
        return;
      }
      const response = await axios.get(`${API_BASE_URL}${upc}`);
      if (response.data.items?.length > 0) {
        const product = ProductDetailsModel.toModel(response.data.items[0]);
        await this.productDetailRepository.save(upc, product);
        res.status(200).json(product);
      } else {
        res.status(404).json({ error: 404, error_message: "Product ID not found" });
      }
    } catch (error) {
      if (axios.isAxiosError(error)) {
        if (error.response) {
          res.status(error.response.status).json({
            error: 'Error fetching product data',
            details: error.response.data
          });
          return;
        }
      }
      next(error);
    }
  }
}
