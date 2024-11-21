import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationHandler {
  static FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

  /// Initialize the Flutter local notifications plugin
  static Future<void> initialize() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(android: android);
    await flutterLocalNotificationsPlugin?.initialize(initializationSettings);
  }

  /// Show notification (Static method)
  static Future<void> showNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Channel',
      channelDescription: 'Channel for general notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const platformDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin?.show(
      0,
      message.notification?.title,
      message.notification?.body,
      platformDetails,
    );
  }

  /// Handle background notifications (Static method)
  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    if(flutterLocalNotificationsPlugin == null) {
      await initialize();
    }
    await Firebase.initializeApp();
    showNotification(message);
  }

  /// Request notification permissions (Android 13 and above)
  static Future<void> requestPermission() async {
    if (Platform.isAndroid) {
      final permissionStatus = await Permission.notification.request();
      if (permissionStatus.isGranted) {
        print("Notification permission granted");
      } else if (permissionStatus.isDenied) {
        print("Notification permission denied");
      } else if (permissionStatus.isPermanentlyDenied) {
        print(
            "Notification permission permanently denied. Please enable it in settings.");
      }
    }
  }
}
