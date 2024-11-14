import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:senserx/domain/models/facility/facility_layout_model.dart';

class FacilityLayoutApiClient {
  final String baseUrl = dotenv.env['API_HOST'] ?? "http://localhost:8080";

  FacilityLayoutApiClient();

  /// Gets Facility Layouts by Facility UID
  Future<List<FacilityLayoutModel>> listFacilityLayoutsByFacilityUid(
      String facilityUid) async {
    final url = Uri.parse('$baseUrl/facilities/$facilityUid/layouts');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse is List) {
          return jsonResponse
              .map((item) => FacilityLayoutModel.fromJson(item))
              .toList();
        } else {
          throw Exception(
              'Expected a list of layouts, but received: $jsonResponse');
        }
      } else {
        throw Exception(
            'Failed to load facility layout data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching facility layout data: $e');
    }
  }

  /// Gets Facility Layout by UID
  Future<FacilityLayoutModel> getFacilityLayoutByUid(
      String facilityUid, String uid) async {
    final url = Uri.parse('$baseUrl/facilities/${facilityUid}/layouts/$uid');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return FacilityLayoutModel.fromJson(jsonResponse);
      } else {
        throw Exception(
            'Failed to load facility layout data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching facility layout data: $e');
    }
  }

  /// Creates a Facility Layout
  Future<FacilityLayoutModel> createFacilityLayout(
      String facilityUid, FacilityLayoutModel layout) async {
    final url = Uri.parse('$baseUrl/facilities/${facilityUid}/layouts');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(layout.toJson()),
      );
      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        return FacilityLayoutModel.fromJson(jsonResponse);
      } else {
        throw Exception(
            'Failed to create facility layout: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating facility layout: $e');
    }
  }

  /// Updates a Facility Layout by UID
  Future<FacilityLayoutModel> updateFacilityLayoutByUid(
      String facilityUid, String uid, FacilityLayoutModel layout) async {
    final url = Uri.parse('$baseUrl/facilities/${facilityUid}/layouts/$uid');

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(layout.toJson()),
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return FacilityLayoutModel.fromJson(jsonResponse);
      } else {
        throw Exception(
            'Failed to update facility layout: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating facility layout: $e');
    }
  }

  /// Deletes a Facility Layout by UID
  Future<void> deleteFacilityLayoutByUid(String facilityUid, String uid) async {
    final url = Uri.parse('$baseUrl/facilities/${facilityUid}/layouts/$uid');

    try {
      final response = await http.delete(url);
      if (response.statusCode == 204) {
        // No content to return, operation was successful
      } else {
        throw Exception(
            'Failed to delete facility layout: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting facility layout: $e');
    }
  }
}
