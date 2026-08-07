import 'package:flutter/material.dart';
import '../../../../core/network/api_service.dart';
import '../../data/datasources/notification_remote_data_source.dart';
import '../../data/models/notification_dto.dart';
import '../../data/models/notification_preferences_dto.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRemoteDataSource _dataSource;

  NotificationProvider({NotificationRemoteDataSource? dataSource})
      : _dataSource = dataSource ??
            NotificationRemoteDataSourceImpl(
              apiService: ApiService(),
            );

  List<NotificationDTO> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Notification Detail State
  NotificationDTO? _activeDetail;
  bool _isDetailLoading = false;
  String? _detailErrorMessage;

  // Notification Preferences State
  NotificationPreferencesDTO? _preferences;
  bool _isPrefsLoading = false;
  String? _prefsErrorMessage;

  List<NotificationDTO> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  NotificationDTO? get activeDetail => _activeDetail;
  bool get isDetailLoading => _isDetailLoading;
  String? get detailErrorMessage => _detailErrorMessage;

  NotificationPreferencesDTO? get preferences => _preferences;
  bool get isPrefsLoading => _isPrefsLoading;
  String? get prefsErrorMessage => _prefsErrorMessage;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notifications = await _dataSource.getMyNotifications();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchNotificationDetail(String id) async {
    _isDetailLoading = true;
    _detailErrorMessage = null;
    _activeDetail = null;
    notifyListeners();

    try {
      final detail = await _dataSource.getNotificationDetail(id);
      _activeDetail = detail;
      _isDetailLoading = false;

      // Auto mark as read in local list if it's unread
      if (!detail.isRead) {
        await _dataSource.markAsRead(id);
        final index = _notifications.indexWhere((n) => n.notificationId == id);
        if (index != -1) {
          _notifications[index] = detail.copyWith(isRead: true, readAt: DateTime.now());
        }
      }
      notifyListeners();
    } catch (e) {
      _isDetailLoading = false;
      _detailErrorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> registerDeviceToken({required String fcmToken, required String deviceId}) async {
    try {
      await _dataSource.registerDeviceToken(fcmToken: fcmToken, deviceId: deviceId);
    } catch (_) {}
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _dataSource.markAsRead(notificationId);
      final index = _notifications.indexWhere((n) => n.notificationId == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(
          isRead: true,
          readAt: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await _dataSource.markAllAsRead();
      _notifications = _notifications.map((n) {
        return n.copyWith(isRead: true, readAt: DateTime.now());
      }).toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchNotificationPreferences() async {
    _isPrefsLoading = true;
    _prefsErrorMessage = null;
    notifyListeners();

    try {
      _preferences = await _dataSource.getNotificationPreferences();
      _isPrefsLoading = false;
      notifyListeners();
    } catch (e) {
      _isPrefsLoading = false;
      _prefsErrorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> updateNotificationPreferences(NotificationPreferencesDTO preferences) async {
    try {
      final updated = await _dataSource.updateNotificationPreferences(preferences);
      _preferences = updated;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
