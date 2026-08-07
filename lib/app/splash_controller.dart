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
      await profileProvider.loadLocalProfile();
      profileProvider.fetchProfile();
      profileProvider.updateGPSLocation();

      final role = await storage.getUserRole();
      if (!context.mounted) return false;

      if (role == 'DOCTOR') {
        final doctorProvider = Provider.of<DoctorDashboardProvider>(context, listen: false);
        await doctorProvider.fetchDashboard();
      } else {
        final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
        await dashboardProvider.fetchDashboard();
      }

      if (!context.mounted) return false;
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      await notificationProvider.fetchNotifications();

      // Initialize FCM Service
      if (!context.mounted) return false;
      await FCMService().initialize(context);

      return true;
    } catch (_) {
      return false;
    }
  }
}
