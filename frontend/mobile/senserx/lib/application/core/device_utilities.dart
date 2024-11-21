import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';

class DeviceUtilities {
  static Future<void> openWifiSettings() async {
    if (Platform.isAndroid) { // supports android only for now
      const intent = AndroidIntent(
        action: 'android.settings.WIFI_SETTINGS',
      );
      await intent.launch();
    } else {
      throw Exception("Not supported");
    }
  }
}