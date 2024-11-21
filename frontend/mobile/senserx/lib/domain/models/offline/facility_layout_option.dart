import 'package:hive/hive.dart';

part 'facility_layout_option.g.dart';

@HiveType(typeId: 0)
class FacilityLayoutOption extends HiveObject {
  @HiveField(0)
  final String uid;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String type;

  @HiveField(3)
  final List<FacilityLayoutOption>? children;

  @HiveField(4)
  final int depth;

  FacilityLayoutOption({
    required this.uid,
    required this.name,
    required this.type,
    this.children,
    this.depth = 0,
  });

  factory FacilityLayoutOption.fromMap(Map<String, dynamic> map, {int depth = 0}) {
    return FacilityLayoutOption(
      uid: map['uid'],
      name: map['name'],
      type: map['type'],
      depth: depth,
      children: map['children'] != null
          ? List<FacilityLayoutOption>.from(
          map['children'].map((x) => FacilityLayoutOption.fromMap(x, depth: depth + 1)))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'type': type,
      'depth': depth,
      'children': children?.map((x) => x.toMap()).toList(),
    };
  }
}
