import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../domain/models/mobile_devices/mobile_device_model.dart';
import 'mobile_device_api_client.dart';

class MobileDeviceService {
  final MobileDeviceApiClient _mobileDeviceApiClient;
  final FirebaseMessaging _firebaseMessaging;

  MobileDeviceService({MobileDeviceApiClient? mobileDeviceApiClient})
      : _mobileDeviceApiClient =
            mobileDeviceApiClient ?? MobileDeviceApiClient(),
        _firebaseMessaging = FirebaseMessaging.instance;

  /// Registers a mobile device with the given details and FCM token
  Future<bool> registerMobileDevice({
    required String deviceId,
    required String platform,
    required String osVersion,
    required String fcmToken,
    String? facilityId,
  }) async {
    try {
      final mobileDevice = MobileDevice(
        deviceId: deviceId,
        platform: platform,
        osVersion: osVersion,
        fcmToken: fcmToken,
        lastNotified: null,
        facilityId: facilityId,
      );
      await _mobileDeviceApiClient.registerDevice(mobileDevice);
      return true;
    } catch (e,s) {
      return false;
    }
  }

  /// Updates the FCM token for the device
  Future<bool> updateFcmToken(String deviceId) async {
    try {
      final fcmToken = await _firebaseMessaging.getToken();
      if (fcmToken == null) {
        throw Exception("Failed to retrieve FCM token");
      }

      final response =
          await _mobileDeviceApiClient.updateFcmToken(deviceId, fcmToken);
      if (response == 'true') {
        return true;
      } else {
        throw Exception('Failed to update FCM token: $response');
      }
    } catch (e, s) {
      print(e);
      print(s);
      return false;
    }
  }

  /// Fetches device information and registers the device
  Future<bool> fetchDeviceInfoAndRegister(String fcmToken) async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String platform = '';
    String osVersion = '';
    String deviceId = '';

    if (Platform.isAndroid) {
      // only supporting android for now
      platform = 'Android';
      var androidInfo = await deviceInfo.androidInfo;
      osVersion = androidInfo.version.release;
      deviceId = androidInfo.id;
    } else {
      throw ArgumentError("Platform not supported");
    }

    return await registerMobileDevice(
      deviceId: deviceId,
      platform: platform,
      osVersion: osVersion,
      fcmToken: fcmToken,
      facilityId: dotenv.env['FACILITY_ID'] ?? ""
    );
  }
}
