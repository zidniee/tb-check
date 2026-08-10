import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/storage/cache_service.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/error_handler.dart';
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
  DateTime? _lastFetchTime;

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
    if (_isLoading) return;

    final now = DateTime.now();
    if (_lastFetchTime != null && now.difference(_lastFetchTime!).inSeconds < 2) {
      debugPrint('fetchNotifications throttled to prevent 429 rate limit.');
      return;
    }
    _lastFetchTime = now;

    _errorMessage = null;

    // 1. Try to load cached notifications instantly
    try {
      final cachedStr = await CacheService().getCachedData('cache_notifications');
      if (cachedStr != null && _notifications.isEmpty) {
        final List<dynamic> jsonList = jsonDecode(cachedStr);
        _notifications = jsonList.map((e) => NotificationDTO.fromJson(e as Map<String, dynamic>)).toList();
        notifyListeners();
      }
    } catch (_) {}

    // Only show loading indicator if we don't have notifications yet
    if (_notifications.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      _notifications = await _dataSource.getMyNotifications();
      _isLoading = false;

      // Save to cache
      try {
        final jsonList = _notifications.map((e) => e.toJson()).toList();
        await CacheService().cacheData('cache_notifications', jsonEncode(jsonList));
      } catch (_) {}

      notifyListeners();
    } on DioException catch (e) {
      _isLoading = false;
      if (_notifications.isEmpty) {
        _errorMessage = ErrorHandler.handleDioError(e).message;
      }
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      if (_notifications.isEmpty) {
        _errorMessage = e.toString();
      }
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
    } on DioException catch (e) {
      _isDetailLoading = false;
      _detailErrorMessage = ErrorHandler.handleDioError(e).message;
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
    _prefsErrorMessage = null;

    // 1. Try to load cached preferences instantly
    try {
      final cachedStr = await CacheService().getCachedData('cache_notification_preferences');
      if (cachedStr != null && _preferences == null) {
        _preferences = NotificationPreferencesDTO.fromJson(jsonDecode(cachedStr));
        notifyListeners();
      }
    } catch (_) {}

    // Only show loading if we have no preferences yet
    if (_preferences == null) {
      _isPrefsLoading = true;
      notifyListeners();
    }

    try {
      final data = await _dataSource.getNotificationPreferences();
      _preferences = data;
      _isPrefsLoading = false;

      // Save to cache
      try {
        await CacheService().cacheData('cache_notification_preferences', jsonEncode(data.toJson()));
      } catch (_) {}

      notifyListeners();
    } catch (e) {
      _isPrefsLoading = false;
      if (_preferences == null) {
        _prefsErrorMessage = e.toString();
      }
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

  Future<void> deleteNotification(String id) async {
    try {
      await _dataSource.deleteNotification(id);
      _notifications.removeWhere((n) => n.notificationId == id);
      if (_activeDetail?.notificationId == id) {
        _activeDetail = null;
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> unregisterDeviceToken(String deviceId) async {
    try {
      await _dataSource.unregisterDeviceToken(deviceId: deviceId);
    } catch (_) {}
  }
}
