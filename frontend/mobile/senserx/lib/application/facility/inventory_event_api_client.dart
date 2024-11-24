import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../domain/models/facility/inventory_event_model.dart';

class InventoryEventApiClient {
  final String baseUrl = dotenv.env['API_HOST'] ?? "http://localhost:8080";
  final Map<String, String> headers =  {'Content-Type': 'application/json'};
  InventoryEventApiClient();

  ///
  /// Creates an Inventory Event
  ///
  Future<String> createInventoryEvent(InventoryEventModel event) async {
    final url = Uri.parse('$baseUrl/inventory-events');

    try {
      final response = await http.post(url, body: json.encode(event), headers: headers);
      if (response.statusCode == 201) {
        return response.body;
      } else {
        throw Exception('Failed to create inventory event: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating inventory event: $e');
    }
  }

  ///
  /// Updates the latest unconfirmed checkout
  ///
  Future<String> updateLatestUnconfirmedCheckout(String upc, String facilityId, double quantity) async {
    final url = Uri.parse('$baseUrl/inventory-events/confirm-dispense');

    try {
      final response = await http.put(
          url,
          body:  json.encode({
            'upc': upc,
            'quantity': quantity,
            'facilityId': facilityId
          }),
          headers: headers
      );
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to update latest unconfirmed checkout: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating latest unconfirmed checkout: $e');
    }
  }
}