import 'dart:developer' as developer;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../feature/notification/presentation/providers/notification_provider.dart';
import 'local_notification_service.dart';
import 'notification_router.dart';

class FCMService {
  static final FCMService _instance = FCMService._();
  factory FCMService() => _instance;
  FCMService._();

  bool _initialized = false;

  Future<void> initialize(BuildContext context) async {
    if (_initialized) return;
    _initialized = true;

    try {
      // 1. Request notification permission (critical for Android 13+)
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      developer.log('FCM permission status: ${settings.authorizationStatus}');

      // 2. Initialize local notifications for foreground display
      await LocalNotificationService.initialize(
        onTap: (payload) {
          if (payload != null && context.mounted) {
            NotificationRouter.navigate(context, payload);
          }
        },
      );

      // 3. Get FCM Token & register to backend
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        developer.log('FCM Token: $token');
        await _registerToken(context, token);
      }

      // 4. Handle token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        _registerToken(context, newToken);
      });

      // 5. Handle foreground message (incoming while app is open)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        developer.log('FCM Foreground Message: ${message.notification?.title}');
        final notification = message.notification;
        if (notification != null) {
          // Show local heads-up notification
          LocalNotificationService.show(
            id: message.hashCode,
            title: notification.title ?? '',
            body: notification.body ?? '',
            payload: message.data['notification_type'] ?? 'general',
          );
        }
        // Fetch new notifications count/list in provider
        if (context.mounted) {
          context.read<NotificationProvider>().fetchNotifications();
        }
      });

      // 6. Handle notification click (when app is in background but active)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        developer.log('FCM Message Opened App: ${message.data}');
        if (context.mounted) {
          NotificationRouter.navigate(
            context,
            message.data['notification_type'] ?? 'general',
            relatedId: message.data['related_id'] ?? message.data['notification_id'] ?? message.data['id'],
            actionType: message.data['action_type'],
            actionValue: message.data['action_value'],
          );
        }
      });

      // 7. Check if app was launched from a terminated state via a notification click
      final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null && context.mounted) {
        developer.log('FCM Initial Message (Terminated): ${initialMessage.data}');
        NotificationRouter.navigate(
          context,
          initialMessage.data['notification_type'] ?? 'general',
          relatedId: initialMessage.data['related_id'] ?? initialMessage.data['notification_id'] ?? initialMessage.data['id'],
          actionType: initialMessage.data['action_type'],
          actionValue: initialMessage.data['action_value'],
        );
      }
    } catch (e) {
      developer.log('Error initializing FCM: $e');
    }
  }

  Future<void> _registerToken(BuildContext context, String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? deviceId = prefs.getString('device_id');
      if (deviceId == null) {
        deviceId = const Uuid().v4();
        await prefs.setString('device_id', deviceId);
      }

      if (context.mounted) {
        await context.read<NotificationProvider>().registerDeviceToken(
              fcmToken: token,
              deviceId: deviceId,
            );
        developer.log('FCM Token successfully registered to backend.');
      }
    } catch (e) {
      developer.log('Failed to register FCM token: $e');
    }
  }
}
