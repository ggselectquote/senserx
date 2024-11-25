

import 'package:flutter/cupertino.dart';
import 'package:senserx/application/products/product_service.dart';

import '../../domain/models/products/product_details.dart';
import '../../presentation/ui/dialogs/barcode_scanner_dialog.dart';

class BarcodeScanner {
  ProductService _productService = ProductService();

  ProductDetails parseSearchResults(Map<String, dynamic> jsonResponse) {
    return ProductDetails.fromJson(jsonResponse);
  }

  Future<ProductDetails?> scanAndFetchProductDetails(BuildContext context) async {
    try {
      String? barcode = await BarcodeScannerDialog.scan(context);
      if (barcode != null) {
        final productDetails = await _productService.getProductDetails(barcode);
        final product = parseSearchResults(productDetails);
        return product;
      }
    } catch (e, s) {
      rethrow;
    }
    return null;
  }
}