import 'dart:convert';

import 'package:senserx/application/products/product_api_client.dart';

class ProductService {
  late ProductApiClient _productApiClient;

  ProductService() {
    _productApiClient = ProductApiClient();
  }

  Future<Map<String, dynamic>> getProductDetails(String asin) async {
    try {
      final rawJson = await _productApiClient.getProductByAsin(asin);
      return json.decode(rawJson);
    } catch (e) {
      print('Error fetching product details: $e');
      rethrow;
    }
  }
}