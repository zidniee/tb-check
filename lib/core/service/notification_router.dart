import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../feature/notification/presentation/pages/notifikasi_page.dart';
import '../../feature/notification/presentation/pages/notification_detail_page.dart';
import '../../feature/patient/presentation/pages/care_dashboard_page.dart';

class NotificationRouter {
  static void navigate(
    BuildContext context,
    String notificationType, {
    String? relatedId,
    String? actionType,
    String? actionValue,
  }) {
    // 1. If it's a medication reminder
    if (notificationType == 'CARE_REMINDER') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const CareDashboardPage(),
        ),
      );
      return;
    }

    // 2. If the action is opening an external URL
    if (actionType == 'OPEN_URL' && actionValue != null && actionValue.isNotEmpty) {
      final uri = Uri.parse(actionValue);
      canLaunchUrl(uri).then((canLaunch) {
        if (canLaunch) {
          launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      });
      return;
    }

    // 3. If the action is opening a specific screen
    if (actionType == 'OPEN_SCREEN' && actionValue != null && actionValue.isNotEmpty) {
      // Since named routes are not registered, we can fall back to general route
      // or expand this if there are specific screen builders.
      // For now, redirect to NotifikasiPage as a fallback.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const NotifikasiPage(),
        ),
      );
      return;
    }

    // 4. Default: If relatedId is present, go to NotificationDetailPage
    if (relatedId != null && relatedId.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NotificationDetailPage(notificationId: relatedId),
        ),
      );
      return;
    }

    // 5. Fallback to Notifications List
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotifikasiPage(),
      ),
    );
  }
}
