import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize({required Function(String?) onTap}) async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);

    const channel = AndroidNotificationChannel(
      'tbcheck_notifications',
      'TBCheck Notifikasi',
      description: 'Menerima pemberitahuan medis dan konsultasi',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse res) {
        onTap(res.payload);
      },
    );
  }

  static Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'tbcheck_notifications',
      'TBCheck Notifikasi',
      channelDescription: 'Menerima pemberitahuan medis dan konsultasi',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      visibility: NotificationVisibility.public,
    );
    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(id, title, body, details, payload: payload);
  }
}
