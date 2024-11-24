import 'dart:convert';
import 'package:senserx/application/facility/inventory_event_api_client.dart';
import 'package:senserx/domain/models/facility/inventory_event_model.dart';

class InventoryEventService {
  final InventoryEventApiClient _client;

  InventoryEventService() : _client = InventoryEventApiClient();

  /// Creates an Inventory Event
  Future<InventoryEventModel> createInventoryEvent(InventoryEventModel event) async {
    try {
      final response = await _client.createInventoryEvent(event);
      final jsonResponse = jsonDecode(response);
      return InventoryEventModel.fromJson(jsonResponse);
    } catch (e,s) {
      print(s);
      throw Exception('Error creating inventory event: $e');
    }
  }

  /// Updates the latest unconfirmed checkout event
  Future<InventoryEventModel> updateLatestUnconfirmedCheckout(String upc, String facilityId, double quantity) async {
    try {
      final response = await _client.updateLatestUnconfirmedCheckout(upc, facilityId, quantity);
      final jsonResponse = jsonDecode(response);
      return InventoryEventModel.fromJson(jsonResponse);
    } catch (e, s) {
      print(e);
      print(s);
      throw Exception('Error updating latest unconfirmed checkout: $e');
    }
  }
}