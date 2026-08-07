import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/care_entities.dart';

class RecentHistoryCard extends StatelessWidget {
  final List<LogEntity> history;
  final VoidCallback onTap;

  const RecentHistoryCard({
    super.key,
    required this.history,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Sort logs by date and time (newest first)
    final sorted = List<LogEntity>.from(history)
      ..sort((a, b) {
        final dateComp = b.reminderDate.compareTo(a.reminderDate);
        if (dateComp != 0) return dateComp;
        return b.reminderTime.compareTo(a.reminderTime);
      });

    final recent = sorted.take(5).toList();

    return Container(
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
                'Riwayat Terakhir',
                style: AppTextStyles.labelLarge.copyWith(fontSize: 16),
              ),
              TextButton(
                onPressed: onTap,
                child: Text(
                  'Lihat Semua',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Belum ada riwayat aktivitas minum obat.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall,
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recent.length,
              separatorBuilder: (_, __) => const Divider(height: 20, color: AppColors.border),
              itemBuilder: (context, index) {
                final log = recent[index];
                final isTaken = log.status == 'TAKEN';
                final isMissed = log.status == 'MISSED';

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatReminderDate(log.reminderDate),
                          style: AppTextStyles.labelMedium.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Jadwal: ${log.reminderTime}',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isTaken
                            ? AppColors.successLight
                            : (isMissed ? Colors.redAccent.withOpacity(0.1) : AppColors.primaryLight),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isTaken
                                ? Icons.check_rounded
                                : (isMissed ? Icons.close_rounded : Icons.hourglass_empty_rounded),
                            size: 14,
                            color: isTaken
                                ? AppColors.successDark
                                : (isMissed ? Colors.redAccent : AppColors.primary),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isTaken
                                ? 'Sudah Minum'
                                : (isMissed ? 'Terlewat' : 'Tertunda'),
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              color: isTaken
                                  ? AppColors.successDark
                                  : (isMissed ? Colors.redAccent : AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  String _formatReminderDate(String dateStr) {
    try {
      final now = DateTime.now();
      final dt = DateTime.parse(dateStr);
      final diff = now.difference(dt).inDays;

      if (diff == 0 && now.day == dt.day) {
        return 'Hari Ini';
      } else if (diff == 1 || (diff == 0 && now.day != dt.day)) {
        return 'Kemarin';
      } else {
        return DateFormat('dd MMM yyyy').format(dt);
      }
    } catch (_) {
      return dateStr;
    }
  }
}
