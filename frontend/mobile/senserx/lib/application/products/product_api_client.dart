import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ProductApiClient {
  final String baseUrl = dotenv.env['API_HOST'] ?? "http://localhost:8080";

  ProductApiClient();


  Future<String> getProductByAsin(String asin) async {
    final url = Uri.parse('$baseUrl/products/$asin');

    try {
      print(url);
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to load product data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching product data: $e');
    }
  }
}