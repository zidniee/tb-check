import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/care_entities.dart';

class StatisticsCard extends StatelessWidget {
  final CareStatisticsEntity? statistics;
  final List<ScheduleEntity> schedules;
  final List<LogEntity> history;
  final VoidCallback onTap;

  const StatisticsCard({
    super.key,
    required this.statistics,
    required this.schedules,
    required this.history,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Calculate daily schedule count (frequency)
    final dailyScheduledCount = schedules.where((s) => s.isActive).length.clamp(1, 99);

    // 2. Group history logs by date
    final Map<String, List<LogEntity>> logsByDate = {};
    for (final log in history) {
      logsByDate.putIfAbsent(log.reminderDate, () => []).add(log);
    }

    // 3. Count successful and missed days based on uppercase status values
    int successfulDays = 0;
    int missedDays = 0;

    for (final date in logsByDate.keys) {
      final dayLogs = logsByDate[date]!;
      final takenCount = dayLogs.where((log) => log.status == 'TAKEN').length;
      final missedCount = dayLogs.where((log) => log.status == 'MISSED').length;

      if (takenCount >= dailyScheduledCount) {
        successfulDays++;
      } else if (missedCount > 0) {
        missedDays++;
      }
    }

    final totalDays = successfulDays + missedDays;
    final double rate = totalDays > 0 ? (successfulDays / totalDays) * 100.0 : 0.0;
    final progress = rate / 100.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kepatuhan',
                  style: AppTextStyles.labelLarge.copyWith(fontSize: 16),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.textSecondary.withOpacity(0.7),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Radial Indicator
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    children: [
                      Center(
                        child: SizedBox(
                          width: 72,
                          height: 72,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 6,
                            backgroundColor: AppColors.border.withOpacity(0.5),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          '${rate.toStringAsFixed(0)}%',
                          style: AppTextStyles.labelMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Legend
                Expanded(
                  child: Column(
                    children: [
                      _buildRowItem('Berhasil', '$successfulDays Hari', AppColors.success),
                      const SizedBox(height: 8),
                      _buildRowItem('Terlewat', '$missedDays Hari', Colors.redAccent),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRowItem(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
