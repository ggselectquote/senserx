class WiFi {
  String ssid;
  String bssid;
  String? ipAddress;

  WiFi({
    required this.ssid,
    required this.bssid,
    this.ipAddress
  });

  factory WiFi.fromJson(Map<String, dynamic> json) {
    return WiFi(
      ssid: json['ssid'],
      bssid: json['bssid'],
      ipAddress: json['ipAddress']
    );
  }

  Map<String, dynamic> toJson() => {
    'ssid': ssid,
    'bssid': bssid,
    'ipAddress': ipAddress
  };
}
