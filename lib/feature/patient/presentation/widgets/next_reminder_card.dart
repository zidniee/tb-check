import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/care_entities.dart';

class NextReminderCard extends StatelessWidget {
  final List<ScheduleEntity> schedules;

  const NextReminderCard({super.key, required this.schedules});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    DateTime? nextAlarm;
    Duration? minDiff;

    for (final schedule in schedules) {
      if (!schedule.isActive) continue;
      
      final parts = schedule.reminderTime.split(':');
      if (parts.length != 2) continue;
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;

      var alarmTime = DateTime(now.year, now.month, now.day, hour, minute);
      if (alarmTime.isBefore(now)) {
        alarmTime = alarmTime.add(const Duration(days: 1));
      }

      final diff = alarmTime.difference(now);
      if (minDiff == null || diff < minDiff) {
        minDiff = diff;
        nextAlarm = alarmTime;
      }
    }

    final hasAlarm = nextAlarm != null;
    String timeStr = '--:--';
    String diffStr = 'Tidak ada alarm aktif';

    if (hasAlarm && minDiff != null) {
      final hours = minDiff.inHours;
      final minutes = minDiff.inMinutes % 60;
      timeStr = scheduleTimeFormatted(nextAlarm);
      
      if (hours > 0) {
        diffStr = 'Dalam $hours jam${minutes > 0 ? ' $minutes menit' : ''}';
      } else {
        diffStr = 'Dalam $minutes menit';
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pengingat Berikutnya',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    diffStr,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            timeStr,
            style: AppTextStyles.labelLarge.copyWith(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String scheduleTimeFormatted(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
