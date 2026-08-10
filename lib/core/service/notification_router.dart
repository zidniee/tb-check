import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../feature/notification/presentation/pages/notifikasi_page.dart';
import '../../feature/notification/presentation/pages/notification_detail_page.dart';
import '../../feature/patient/presentation/pages/care_dashboard_page.dart';
import '../../feature/appointment/presentation/pages/appointment_detail_page.dart';
import '../../feature/appointment/presentation/pages/appointment_history_page.dart';

class NotificationRouter {
  static void navigate(
    BuildContext context,
    String notificationType, {
    String? relatedId,
    String? actionType,
    String? actionValue,
  }) {
    // 1. If it's a medication reminder
    if (notificationType == 'CARE_REMINDER' || notificationType == 'REMINDER') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const CareDashboardPage(),
        ),
      );
      return;
    }

    // 2. If it's an appointment notification
    if (notificationType == 'APPOINTMENT') {
      if (relatedId != null && relatedId.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AppointmentDetailPage(appointmentId: relatedId),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AppointmentHistoryPage(),
          ),
        );
      }
      return;
    }

    // 3. Handle OPEN_SCREEN action type
    if ((actionType == 'OPEN_SCREEN' || actionType == 'open_screen') && actionValue != null && actionValue.isNotEmpty) {
      final cleanVal = actionValue.trim().toLowerCase();
      if (cleanVal == '/care/dashboard' || cleanVal == 'care_dashboard' || cleanVal == '/care') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const CareDashboardPage(),
          ),
        );
        return;
      }
      if (cleanVal == '/appointments/history' || cleanVal == 'appointment_history' || cleanVal == '/appointments') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AppointmentHistoryPage(),
          ),
        );
        return;
      }
      if (cleanVal == '/notifications' || cleanVal == 'notifications') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const NotifikasiPage(),
          ),
        );
        return;
      }
      if ((cleanVal == '/appointments/detail' || cleanVal == 'appointment_detail') && relatedId != null && relatedId.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AppointmentDetailPage(appointmentId: relatedId),
          ),
        );
        return;
      }

      // Fallback: Pushing named route
      try {
        Navigator.pushNamed(context, actionValue);
        return;
      } catch (_) {}
    }

    // 4. If the action is opening an external URL
    if ((actionType == 'OPEN_URL' || actionType == 'open_url') && actionValue != null && actionValue.isNotEmpty) {
      final uri = Uri.parse(actionValue);
      launchUrl(uri, mode: LaunchMode.externalApplication);
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
