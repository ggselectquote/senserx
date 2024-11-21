import 'dart:convert';
import 'package:senserx/application/facility/facility_api_client.dart';
import 'package:senserx/domain/enums/facility_layout.dart';
import 'package:senserx/domain/models/facility/facility_layout_model.dart';
import 'package:senserx/domain/models/facility/facility_model.dart';

class FacilityService {
  final FacilityApiClient _client;

  FacilityService() : _client = FacilityApiClient();

  /// Gets Facility by UID
  Future<FacilityModel> getFacilityDetails(String uid) async {
    try {
      final response = await _client.getFacilityByUid(uid);
      final jsonResponse = jsonDecode(response);
      return FacilityModel.fromJson(jsonResponse);
    } catch (e) {
      print(e);
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
  Future<FacilityModel> updateFacility(
      String uid, FacilityModel facility) async {
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

  /// Converts facility layout type to `LocationType` and retrieves icon
  static FacilityLayout getFacilityLayoutType(String layoutType) {
    final locationType = FacilityLayout.fromString(layoutType);
    return locationType;
  }

  /// Find a child facility layout by UID
  Future<FacilityLayoutModel> findChildLayoutByUID(
      String parentFacilityUID, String childUID) async {
    try {
      final response = await _client.getFacilityLayoutsByUid(parentFacilityUID);
      final json = jsonDecode(response);
      final List<FacilityLayoutModel> facilityLayouts = (json as List)
          .map((item) => FacilityLayoutModel.fromJson(item))
          .toList();

      if (facilityLayouts.isEmpty) {
        throw Exception(
            'Facility layout not found for UID: $parentFacilityUID');
      }

      final FacilityLayoutModel? result =
          _findChildLayoutByUID(facilityLayouts, childUID);

      if (result == null) {
        throw Exception(
            'Child layout with UID $childUID not found in the facility $parentFacilityUID');
      }

      return result;
    } catch (e) {
      throw Exception('Failed to find child layout by UID');
    }
  }

  FacilityLayoutModel? _findChildLayoutByUID(
      List<FacilityLayoutModel> layouts, String childUID) {
    for (var layout in layouts) {
      if (layout.uid == childUID) {
        return layout;
      }

      final FacilityLayoutModel? result =
          _findChildLayoutByUID(layout.children ?? [], childUID);
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}
