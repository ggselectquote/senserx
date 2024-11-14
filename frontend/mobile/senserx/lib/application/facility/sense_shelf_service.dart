import 'package:senserx/domain/models/facility/sense_shelf_model.dart';
import 'package:senserx/application/facility/sense_shelf_api_client.dart';

class SenseShelfService {
  final SenseShelfApiClient _client;

  SenseShelfService() :
        _client = SenseShelfApiClient();

  /// Gets all Shelves by Facility and Layout UID
  Future<List<SenseShelfModel>> listShelves(String facilityId, String layoutId) async {
    try {
      return await _client.listShelvesByFacilityAndLayout(facilityId, layoutId);
    } catch (e) {
      throw Exception('Error fetching shelves: $e');
    }
  }

  /// Gets a specific Shelf by Facility, Layout, and Shelf UID
  Future<SenseShelfModel> getShelfDetails(String facilityId, String layoutId, String shelfId) async {
    try {
      return await _client.getShelfByUid(facilityId, layoutId, shelfId);
    } catch (e) {
      throw Exception('Error fetching shelf details: $e');
    }
  }

  /// Creates a new Shelf
  Future<SenseShelfModel> createShelf(String facilityId, String layoutId, SenseShelfModel shelf) async {
    try {
      return await _client.createShelf(facilityId, layoutId, shelf);
    } catch (e) {
      throw Exception('Error creating shelf: $e');
    }
  }

  /// Updates a specific Shelf by Facility, Layout, and Shelf UID
  Future<SenseShelfModel> updateShelf(String facilityId, String layoutId, String shelfId, SenseShelfModel shelf) async {
    try {
      return await _client.updateShelf(facilityId, layoutId, shelfId, shelf);
    } catch (e) {
      throw Exception('Error updating shelf: $e');
    }
  }

  /// Deletes a specific Shelf by Facility, Layout, and Shelf UID
  Future<void> deleteShelf(String facilityId, String layoutId, String shelfId) async {
    try {
      await _client.deleteShelf(facilityId, layoutId, shelfId);
    } catch (e) {
      throw Exception('Error deleting shelf: $e');
    }
  }
}