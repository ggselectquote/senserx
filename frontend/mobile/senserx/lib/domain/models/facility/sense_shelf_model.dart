class SenseShelfModel {
  final String name;
  final String macAddress;
  final String layoutId;
  final String facilityId;
  final int? capacity;
  final int? currentUtilization;
  final List<String>? productTypes;
  final String lastSeen;

  SenseShelfModel({
    required this.name,
    required this.macAddress,
    required this.layoutId,
    required this.facilityId,
    this.capacity,
    this.currentUtilization,
    this.productTypes,
    required this.lastSeen,
  });

  factory SenseShelfModel.fromJson(Map<String, dynamic> json) {
    return SenseShelfModel(
      name: json['name'] as String,
      macAddress: json['macAddress'] as String,
      layoutId: json['layoutId'] as String,
      facilityId: json['facilityId'] as String,
      capacity: json['capacity'] as int?,
      currentUtilization: json['currentUtilization'] as int?,
      productTypes: json['productTypes'] != null ? List<String>.from(json['productTypes']) : null,
      lastSeen: json['lastSeen'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'macAddress': macAddress,
      'layoutId': layoutId,
      'facilityId': facilityId,
      'capacity': capacity,
      'currentUtilization': currentUtilization,
      'productTypes': productTypes,
      'lastSeen': lastSeen,
    };
  }

  List<Object?> get props => [name, macAddress, layoutId, facilityId, capacity, currentUtilization, productTypes, lastSeen];
}