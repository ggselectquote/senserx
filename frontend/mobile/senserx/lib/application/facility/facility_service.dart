import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:senserx/application/facility/facility_api_client.dart';
import 'package:senserx/domain/models/facility/facility_model.dart';

class FacilityService {
  final FacilityApiClient _client;

  FacilityService()
      : _client = FacilityApiClient();

  /// Gets Facility by UID
  Future<FacilityModel> getFacilityDetails(String uid) async {
    try {
      final response = await _client.getFacilityByUid(uid);
      final jsonResponse = jsonDecode(response);
      return FacilityModel.fromJson(jsonResponse);
    } catch (e) {
      throw Exception('Error fetching facility details: $e');
    }
  }

  /// Creates a Facility
  Future<FacilityModel> createFacility(FacilityModel facility) async {
    try {
      final response = await _client.createFacility(facility);
      final jsonResponse = jsonDecode(response);
      return FacilityModel.fromJson(jsonResponse);
    } catch (e) {
      throw Exception('Error creating facility: $e');
    }
  }

  /// Updates a Facility by UID
  Future<FacilityModel> updateFacility(String uid, FacilityModel facility) async {
    try {
      final response = await _client.updateFacilityByUid(uid, facility);
      final jsonResponse = jsonDecode(response);
      return FacilityModel.fromJson(jsonResponse);
    } catch (e) {
      throw Exception('Error updating facility: $e');
    }
  }

  /// Deletes a Facility by UID
  Future<void> deleteFacility(String uid) async {
    try {
      await _client.deleteFacilityByUid(uid);
    } catch (e) {
      throw Exception('Error deleting facility: $e');
    }
  }
}