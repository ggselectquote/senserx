import 'package:senserx/domain/models/facility/sense_shelf_model.dart';

class FacilityLayoutModel {
  final String uid;
  final String facilityId;
  final String? parentId;
  final String name;
  final String? description;
  final String type;
  final List<String>? subLayouts;
  List<FacilityLayoutModel>? children;
  final List<SenseShelfModel>? shelves;

  FacilityLayoutModel({
    required this.uid,
    required this.facilityId,
    this.parentId,
    required this.name,
    this.description,
    required this.type,
    this.subLayouts,
    this.children,
    this.shelves,
  });

  factory FacilityLayoutModel.fromJson(Map<String, dynamic> json) {
    return FacilityLayoutModel(
      uid: json['uid'] as String,
      facilityId: json['facilityId'] as String,
      parentId: json['parentId'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: json['type'] as String,
      subLayouts: List<String>.from(json['subLayouts'] ?? []),
      children: json['children'] != null
          ? List<FacilityLayoutModel>.from(json['children'].map((x) => FacilityLayoutModel.fromJson(x)))
          : null,
      shelves: json['shelves'] != null
          ? List<SenseShelfModel>.from(json['shelves'].map((x) => SenseShelfModel.fromJson(x)))
          : null,
    );
  }

  /// Converts the [FacilityLayoutModel] to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'facilityId': facilityId,
      'parentId': parentId,
      'name': name,
      'description': description,
      'type': type,
      'subLayouts': subLayouts,
      'children': children?.map((e) => e.toJson()).toList(),
      'shelves': shelves?.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [uid, facilityId, parentId, name, description, type, subLayouts, children, shelves];
}