import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/storage/secure_storage_service.dart';
import '../core/service/fcm_service.dart';
import '../feature/doctor/presentation/providers/doctor_dashboard_provider.dart';
import '../feature/notification/presentation/providers/notification_provider.dart';
import '../feature/patient/presentation/providers/dashboard_provider.dart';
import '../feature/profile/presentation/providers/profile_provider.dart';

class SplashController {
  static Future<bool> checkAutoLogin(BuildContext context) async {
    final storage = SecureStorageService();
    final token = await storage.getAccessToken();
    if (token == null || token.isEmpty) {
      return false;
    }

    try {
      if (!context.mounted) return false;
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      
      // Load local profile first (no network connection required, takes 0ms)
      try {
        await profileProvider.loadLocalProfile();
      } catch (_) {}

      // Trigger all remote network fetches in the background asynchronously
      // so we don't block the splash screen rendering!
      _initializeInBackground(context);

      return true;
    } catch (_) {
      return true;
    }
  }

  static void _initializeInBackground(BuildContext context) async {
    try {
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      // Fetch fresh profile from server in background
      profileProvider.fetchProfile();
      profileProvider.updateGPSLocation();
    } catch (_) {}

    try {
      final storage = SecureStorageService();
      final role = await storage.getUserRole();
      
      if (role == 'DOCTOR') {
        final doctorProvider = Provider.of<DoctorDashboardProvider>(context, listen: false);
        doctorProvider.fetchDashboard();
      } else {
        final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
        dashboardProvider.fetchDashboard();
      }
    } catch (_) {}

    try {
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      notificationProvider.fetchNotifications();
    } catch (_) {}

    try {
      await FCMService().initialize(context);
    } catch (_) {}
  }
}
