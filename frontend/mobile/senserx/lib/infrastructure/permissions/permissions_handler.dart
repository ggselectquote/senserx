import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
 static Future<bool> checkAndRequestPermissions() async {
    PermissionStatus locationAlwaysStatus = await Permission.locationAlways.status;
    await Permission.locationAlways.request();
    if (!locationAlwaysStatus.isGranted) return false;

    PermissionStatus nearbyWifiDevices = await Permission.nearbyWifiDevices.status;
    nearbyWifiDevices = await Permission.nearbyWifiDevices.request();
    if (!nearbyWifiDevices.isGranted) return false;

    PermissionStatus cameraStatus = await Permission.camera.status;
    cameraStatus = await Permission.camera.request();
    if (!cameraStatus.isGranted) return false;

    return true;
  }
}
