class SenseShelfModel {
  final String name;
  final String macAddress;
  final String layoutId;
  final String facilityId;
  final String? ipAddress;
  final List<String>? productTypes;
  final String? lastSeen;
  final String? currentUpc;
  final int? currentQuantity;

  SenseShelfModel({
    required this.name,
    required this.macAddress,
    required this.layoutId,
    required this.facilityId,
    this.ipAddress,
    this.productTypes,
    this.lastSeen,
    this.currentQuantity,
    this.currentUpc
  });

  factory SenseShelfModel.fromJson(Map<String, dynamic> json) {
    return SenseShelfModel(
      name: json['name'] as String,
      macAddress: json['macAddress'] as String,
      layoutId: json['layoutId'] as String,
      facilityId: json['facilityId'] as String,
      ipAddress: json['ipAddress'] as String?,
      currentUpc: json['currentUpc'] as String?,
      currentQuantity: json['currentQuantity'] as int?,
      productTypes: json['productTypes'] != null
          ? List<String>.from(json['productTypes'])
          : null,
      lastSeen: json['lastSeen'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastSeen'] * 1000)
              .toIso8601String()
          : null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'macAddress': macAddress,
      'layoutId': layoutId,
      'facilityId': facilityId,
      'ipAddress': ipAddress,
      'productTypes': productTypes,
      'currentQuantity': currentQuantity,
      'currentUpc': currentUpc,
      'lastSeen': lastSeen,
    };
  }

  List<Object?> get props => [
        name,
        macAddress,
        layoutId,
        facilityId,
        ipAddress,
        productTypes,
        lastSeen,
        currentUpc,
        currentQuantity
      ];
}
