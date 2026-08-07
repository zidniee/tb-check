import '../../../../core/network/api_service.dart';
import '../models/notification_dto.dart';
import '../models/notification_preferences_dto.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationDTO>> getMyNotifications({int limit = 100, int page = 1});
  Future<NotificationDTO> getNotificationDetail(String notificationId);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
  Future<void> registerDeviceToken({required String fcmToken, required String deviceId});
  Future<NotificationPreferencesDTO> getNotificationPreferences();
  Future<NotificationPreferencesDTO> updateNotificationPreferences(NotificationPreferencesDTO preferences);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiService apiService;

  NotificationRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<NotificationDTO>> getMyNotifications({int limit = 100, int page = 1}) async {
    final response = await apiService.dio.get(
      '/api/v1/notifications',
      queryParameters: {
        'limit': limit,
        'page': page,
      },
    );
    final list = response.data as List<dynamic>;
    return list.map((e) => NotificationDTO.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<NotificationDTO> getNotificationDetail(String notificationId) async {
    final response = await apiService.dio.get('/api/v1/notifications/$notificationId');
    return NotificationDTO.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await apiService.dio.put('/api/v1/notifications/$notificationId/read');
  }

  @override
  Future<void> markAllAsRead() async {
    await apiService.dio.put('/api/v1/notifications/read-all');
  }

  @override
  Future<void> registerDeviceToken({required String fcmToken, required String deviceId}) async {
    await apiService.dio.post(
      '/api/v1/notifications/device-token',
      data: {
        'fcm_token': fcmToken,
        'device_id': deviceId,
      },
    );
  }

  @override
  Future<NotificationPreferencesDTO> getNotificationPreferences() async {
    final response = await apiService.dio.get('/api/v1/notifications/preferences');
    return NotificationPreferencesDTO.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<NotificationPreferencesDTO> updateNotificationPreferences(NotificationPreferencesDTO preferences) async {
    final response = await apiService.dio.put(
      '/api/v1/notifications/preferences',
      data: preferences.toJson(),
    );
    return NotificationPreferencesDTO.fromJson(response.data as Map<String, dynamic>);
  }
}
