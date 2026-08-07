import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/care_entities.dart';

class TodayScheduleCard extends StatelessWidget {
  final List<ScheduleEntity> schedules;
  final List<LogEntity> logs;
  final Function(String) onConfirm;
  final VoidCallback onManageTap;

  const TodayScheduleCard({
    super.key,
    required this.schedules,
    required this.logs,
    required this.onConfirm,
    required this.onManageTap,
  });

  @override
  Widget build(BuildContext context) {
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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.today_rounded,
                      color: AppColors.secondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Hari Ini',
                    style: AppTextStyles.labelLarge.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: onManageTap,
                icon: const Icon(Icons.settings_rounded, size: 16, color: AppColors.primary),
                label: Text(
                  'Atur',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (schedules.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                'Belum ada jadwal minum obat hari ini. Ketuk tombol Atur untuk menambahkan jadwal.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(height: 1.4),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: schedules.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final schedule = schedules[index];
                
                // Find matching log
                final log = logs.firstWhere(
                  (l) => l.scheduleId == schedule.scheduleId,
                  orElse: () => LogEntity(
                    logId: '',
                    scheduleId: schedule.scheduleId,
                    reminderDate: '',
                    reminderTime: '',
                    status: 'PENDING',
                  ),
                );

                final isTaken = log.status == 'TAKEN';

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isTaken ? AppColors.successLight.withOpacity(0.3) : AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isTaken ? AppColors.success.withOpacity(0.2) : AppColors.border.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.alarm_rounded,
                            size: 18,
                            color: isTaken ? AppColors.success : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            schedule.reminderTime,
                            style: AppTextStyles.labelMedium.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isTaken ? AppColors.successDark : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      if (isTaken)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_rounded, size: 12, color: AppColors.success),
                              const SizedBox(width: 4),
                              Text(
                                'Sudah diminum',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.successDark,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ElevatedButton(
                          onPressed: () => onConfirm(schedule.scheduleId),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Sudah Minum',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
