import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:senserx/domain/models/facility/facility_model.dart';

class FacilityApiClient {
  final String baseUrl = dotenv.env['API_HOST'] ?? "http://localhost:8080";

  FacilityApiClient();

  ///
  /// Gets Facility by UID
  ///
  Future<String> getFacilityByUid(String uid) async {
    final url = Uri.parse('$baseUrl/facilities/$uid');

    print(url);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to load facility data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching facility data: $e');
    }
  }

  ///
  /// Gets Facility Layouts by UID
  ///
  Future<String> getFacilityLayoutsByUid(String uid) async {
    final url = Uri.parse('$baseUrl/facilities/$uid/layouts');

    print(url);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to load facility data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching facility data: $e');
    }
  }

  ///
  /// Creates a Facility
  ///
  Future<String> createFacility(FacilityModel facility) async {
    final url = Uri.parse('$baseUrl/facilities');

    try {
      final response = await http.post(url, body: facility);
      if (response.statusCode == 201) {
        return response.body;
      } else {
        throw Exception('Failed to load facility data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching facility data: $e');
    }
  }

  ///
  /// Updates a Facility by UID
  ///
  Future<String> updateFacilityByUid(String uid, FacilityModel facility) async {
    final url = Uri.parse('$baseUrl/facilities/${uid}');

    try {
      final response = await http.put(url, body: facility);
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to load facility data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching facility data: $e');
    }
  }

  ///
  /// Deletes a Facility by UID
  ///
  Future<String> deleteFacilityByUid(String uid) async {
    final url = Uri.parse('$baseUrl/facilities/${uid}');

    try {
      final response = await http.delete(url);
      if (response.statusCode == 204) {
        return response.body;
      } else {
        throw Exception('Failed to load facility data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching facility data: $e');
    }
  }
}