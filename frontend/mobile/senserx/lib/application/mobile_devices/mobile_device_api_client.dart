import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/models/mobile_devices/mobile_device_model.dart';

class MobileDeviceApiClient {
  final String baseUrl = dotenv.env['API_HOST'] ?? 'http://localhost:8080';

  MobileDeviceApiClient();

  /// Registers a new mobile device
  Future<String> registerDevice(MobileDevice mobileDevice) async {
    final url = Uri.parse('$baseUrl/mobile-devices');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(mobileDevice.toJson()),
      );
      if (response.statusCode == 201) {
        return response.body;
      } else {
        throw Exception('Failed to register device: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error registering device: $e');
    }
  }

  /// Updates the FCM token for a device
  Future<String> updateFcmToken(String deviceId, String fcmToken) async {
    final url = Uri.parse('$baseUrl/mobile-devices/$deviceId');

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'fcmToken': fcmToken}),
      );
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to update FCM token: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating FCM token: $e');
    }
  }

  /// Fetches device details by device ID
  Future<String> getDeviceDetails(String deviceId) async {
    final url = Uri.parse('$baseUrl/mobile-devices/$deviceId');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to load device data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching device data: $e');
    }
  }

  /// Deletes a device by device ID
  Future<String> deleteDevice(String deviceId) async {
    final url = Uri.parse('$baseUrl/mobile-devices/$deviceId');

    try {
      final response = await http.delete(url);
      if (response.statusCode == 204) {
        return response.body;
      } else {
        throw Exception('Failed to delete device: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting device: $e');
    }
  }
}