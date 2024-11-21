import 'package:flutter/foundation.dart';
import 'package:network_info_plus/network_info_plus.dart';

class WifiProvider extends ChangeNotifier {
  bool _isConnectedToSenseShelf = false;
  final NetworkInfo _networkInfo = NetworkInfo();

  bool get isConnectedToSenseShelf => _isConnectedToSenseShelf;

  Future<bool> checkWifiConnection() async {
    try {
      final wifiName = await _networkInfo.getWifiName();
      if (wifiName != null) {
        _isConnectedToSenseShelf = _isSenseShelfNetwork(wifiName);
      } else {
        _isConnectedToSenseShelf = false;
      }
    } catch (e) {
      print("Error checking WiFi connection: $e");
      _isConnectedToSenseShelf = false;
    }
    notifyListeners();
    return _isConnectedToSenseShelf;
  }

  bool _isSenseShelfNetwork(String ssid) {
    return ssid.toLowerCase().contains("senseshelf");
  }
}
