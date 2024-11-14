import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:senserx/domain/models/facility/sense_shelf_model.dart';

class SenseShelfApiClient {
  final String baseUrl;

  SenseShelfApiClient() : baseUrl = dotenv.env['API_HOST'] ?? "http://localhost:8080";

  /// Gets all Shelves by Facility and Layout UID
  Future<List<SenseShelfModel>> listShelvesByFacilityAndLayout(String facilityId, String layoutId) async {
    final url = Uri.parse('$baseUrl/facilities/$facilityId/layouts/$layoutId/shelves');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse is List) {
          return jsonResponse.map((item) => SenseShelfModel.fromJson(item)).toList();
        } else {
          throw Exception('Expected a list of shelves, but received: $jsonResponse');
        }
      } else {
        throw Exception('Failed to load shelves data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching shelves data: $e');
    }
  }

  /// Gets a specific Shelf by Facility, Layout, and Shelf UID
  Future<SenseShelfModel> getShelfByUid(String facilityId, String layoutId, String shelfId) async {
    final url = Uri.parse('$baseUrl/facilities/$facilityId/layouts/$layoutId/shelves/$shelfId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return SenseShelfModel.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to load shelf data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching shelf data: $e');
    }
  }

  /// Creates a new Shelf
  Future<SenseShelfModel> createShelf(String facilityId, String layoutId, SenseShelfModel shelf) async {
    final url = Uri.parse('$baseUrl/facilities/$facilityId/layouts/$layoutId/shelves');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(shelf.toJson()),
      );
      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return SenseShelfModel.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to create shelf: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating shelf: $e');
    }
  }

  /// Updates a specific Shelf by Facility, Layout, and Shelf UID
  Future<SenseShelfModel> updateShelf(String facilityId, String layoutId, String shelfId, SenseShelfModel shelf) async {
    final url = Uri.parse('$baseUrl/facilities/$facilityId/layouts/$layoutId/shelves/$shelfId');

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(shelf.toJson()),
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return SenseShelfModel.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to update shelf: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating shelf: $e');
    }
  }

  /// Deletes a specific Shelf by Facility, Layout, and Shelf UID
  Future<void> deleteShelf(String facilityId, String layoutId, String shelfId) async {
    final url = Uri.parse('$baseUrl/facilities/$facilityId/layouts/$layoutId/shelves/$shelfId');

    try {
      final response = await http.delete(url);
      if (response.statusCode == 204) {
        // No content to return, operation was successful
      } else {
        throw Exception('Failed to delete shelf: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting shelf: $e');
    }
  }
}