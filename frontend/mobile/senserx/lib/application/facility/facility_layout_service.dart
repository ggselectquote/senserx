import 'package:senserx/domain/models/facility/facility_layout_model.dart';
import 'package:senserx/application/facility/facility_layout_api_client.dart';

class FacilityLayoutService {
  final FacilityLayoutApiClient _client;

  FacilityLayoutService()
      : _client = FacilityLayoutApiClient();

  /// Gets Facility Layout by UID
  Future<FacilityLayoutModel> getFacilityLayoutByUid(
      String facilityUid, String uid) async {
    try {
      final layout = await _client.getFacilityLayoutByUid(facilityUid, uid);
      return layout;
    } catch (e) {
      throw Exception('Error fetching facility layout details: $e');
    }
  }

  /// Creates a Facility Layout
  Future<FacilityLayoutModel> createFacilityLayout(
      String facilityUid, FacilityLayoutModel layout) async {
    try {
      return await _client.createFacilityLayout(facilityUid, layout);
    } catch (e) {
      throw Exception('Error creating facility layout: $e');
    }
  }

  /// Updates a Facility Layout by UID
  Future<FacilityLayoutModel> updateFacilityLayout(
      String facilityUid, String uid, FacilityLayoutModel layout) async {
    try {
      return await _client.updateFacilityLayoutByUid(facilityUid, uid, layout);
    } catch (e) {
      throw Exception('Error updating facility layout: $e');
    }
  }

  /// Deletes a Facility Layout by UID
  Future<void> deleteFacilityLayout(String facilityUid, String uid) async {
    try {
      await _client.deleteFacilityLayoutByUid(facilityUid, uid);
    } catch (e) {
      throw Exception('Error deleting facility layout: $e');
    }
  }

  /// Gets Facility Layouts by Facility UID
  Future<List<FacilityLayoutModel>> listFacilityLayoutsByFacilityUid(
      String facilityUid) async {
    try {
      return await _client.listFacilityLayoutsByFacilityUid(facilityUid);
    } catch (e) {
      throw Exception('Error fetching facility layouts: $e');
    }
  }
}
