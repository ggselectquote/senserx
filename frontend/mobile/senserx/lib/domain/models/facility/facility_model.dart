class FacilityModel {
  final String uid;
  final String name;
  final String? address;
  final String? contact;
  final List<String>? layoutIds;

  FacilityModel({
    required this.uid,
    required this.name,
    required this.address,
    this.contact,
    this.layoutIds,
  });

  /// Factory constructor to create a [FacilityModel] from a JSON map
  factory FacilityModel.fromJson(Map<String, dynamic> json) {
    return FacilityModel(
      uid: json['uid'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
      contact: json['contact'] as String?,
      layoutIds: json['layoutIds'] != null ? List<String>.from(json['layoutIds']) : null,
    );
  }

  /// Converts the [FacilityModel] to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'address': address,
      'contact': contact,
      'layoutIds': layoutIds,
    };
  }

  /// Overrides the toString method to provide a string representation of the model
  @override
  String toString() {
    return 'FacilityModel(uid: $uid, name: $name, address: $address, contact: $contact, layoutIds: $layoutIds)';
  }
}