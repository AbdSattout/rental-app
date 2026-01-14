import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<String?> getFcmToken() async {
    try {
      await _firebaseMessaging.requestPermission();
      final token = await _firebaseMessaging.getToken();
      return token;
    } catch (_) {
      return null;
    }
  }

  Future<void> setupForegroundNotifications() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Received message: ${message.notification?.title}');
        print('Message data: ${message.data}');
      }
    });
  }

  Future<void> setupBackgroundNotifications() async {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Message opened from background: ${message.notification?.title}');
      }
    });
  }
}
