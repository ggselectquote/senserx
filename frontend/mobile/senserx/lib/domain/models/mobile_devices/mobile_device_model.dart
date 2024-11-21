class MobileDevice {
  final String uid;
  final String deviceId;
  final String platform;
  final String osVersion;
  final String fcmToken;
  final DateTime? lastNotified;
  final String? facilityId;

  MobileDevice({
    required this.deviceId,
    required this.platform,
    required this.osVersion,
    required this.fcmToken,
    this.lastNotified,
    this.facilityId,
  }) : uid = "";

  factory MobileDevice.fromJson(Map<String, dynamic> json) => MobileDevice(
    deviceId: json['deviceId'] ?? '',
    platform: json['platform'] ?? '',
    osVersion: json['osVersion'] ?? '',
    fcmToken: json['fcmToken'] ?? '',
    lastNotified: json['lastNotified'] != null ? DateTime.tryParse(json['lastNotified']) : null,
    facilityId: json['facilityId'],
  );

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'deviceId': deviceId,
      'platform': platform,
      'osVersion': osVersion,
      'fcmToken': fcmToken,
      'lastNotified': lastNotified?.toIso8601String(),
      'facilityId': facilityId,
    };
  }

  @override
  String toString() {
    return '''
    MobileDevice {
      uid: $uid,
      deviceId: $deviceId,
      platform: $platform,
      osVersion: $osVersion,
      fcmToken: $fcmToken,
      lastNotified: $lastNotified,
      facilityId: $facilityId
    }
    ''';
  }
}
