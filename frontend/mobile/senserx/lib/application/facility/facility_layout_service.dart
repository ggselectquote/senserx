import 'package:senserx/domain/models/facility/facility_layout_model.dart';
import 'package:senserx/application/facility/facility_layout_api_client.dart';

import '../../domain/models/offline/facility_layout_option.dart';

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

  Map<String, Map<String, int>> countShelvesAndLayouts(List<FacilityLayoutModel> layouts) {
    Map<String, Map<String, int>> counts = {};

    void countRecursively(FacilityLayoutModel layout) {
      int shelfCount = layout.shelves?.length ?? 0;
      int layoutCount = layout.children?.length ?? 0;

      for (var child in layout.children ?? []) {
        countRecursively(child);
        var childCounts = counts[child.uid]!;
        shelfCount += childCounts['shelves']!;
        layoutCount += childCounts['layouts']! + 1;
      }

      counts[layout.uid] = {
        'shelves': shelfCount,
        'layouts': layoutCount,
      };
    }

    for (var layout in layouts) {
      countRecursively(layout);
    }

    return counts;
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

  /// Flattens facility layouts for a list display
  Future<List<FacilityLayoutOption>> fetchAndStoreFacilityLayouts(String currentFacilityId) async {
    try {
      final layouts = await listFacilityLayoutsByFacilityUid(currentFacilityId);

      List<FacilityLayoutOption> convertToFacilityLayoutOptions(List<dynamic> layouts,
          {int depth = 0}) {
        return layouts.map((layout) => FacilityLayoutOption(
          uid: layout.uid,
          name: layout.name,
          type: layout.type,
          depth: depth,
          children: layout.children != null
              ? convertToFacilityLayoutOptions(layout.children, depth: depth+1)
              : null,
        )).toList();
      }

      final minimalLayouts = convertToFacilityLayoutOptions(layouts);

      List<FacilityLayoutOption> flattenLayouts(List<FacilityLayoutOption> layouts) {
        List<FacilityLayoutOption> flattened = [];
        void addLayout(FacilityLayoutOption layout) {
          flattened.add(layout);
          if (layout.children != null) {
            for (var child in layout.children!) {
              addLayout(child);
            }
          }
        }
        for (var layout in layouts) {
          addLayout(layout);
        }
        return flattened;
      }
      final flattenedLayouts = flattenLayouts(minimalLayouts);
      return flattenedLayouts;
    } catch (e) {
      print("Error fetching facility layouts: $e");
      return [];
    }
  }
}
