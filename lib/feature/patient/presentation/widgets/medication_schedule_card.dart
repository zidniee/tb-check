import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/care_notifier.dart';
import '../pages/care_dashboard_page.dart';
import '../../domain/entities/care_entities.dart';

class MedicationScheduleCard extends ConsumerWidget {
  const MedicationScheduleCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final careState = ref.watch(careNotifierProvider);

    return careState.treatment.when(
      loading: () => const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => const SizedBox(),
      data: (treatment) {
        if (treatment == null || !treatment.isActive) {
          return _buildNoTreatmentCard(context);
        }

        return careState.schedules.when(
          loading: () => const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (err, _) => const SizedBox(),
          data: (schedules) {
            return careState.statistics.when(
              loading: () => const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => const SizedBox(),
              data: (statistics) {
                return careState.todayLogs.when(
                  loading: () => const SizedBox(
                    height: 120,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, _) => const SizedBox(),
                  data: (todayLogs) {
                    return _buildCardContent(context, ref, schedules, statistics, todayLogs);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCardContent(
    BuildContext context,
    WidgetRef ref,
    List<ScheduleEntity> schedules,
    CareStatisticsEntity? statistics,
    List<LogEntity> todayLogs,
  ) {
    final activeSchedules = schedules.where((s) => s.isActive).toList();

    return Container(
      padding: const EdgeInsets.all(18),
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
                      Icons.medication_rounded,
                      color: AppColors.secondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jadwal Obat Hari Ini',
                        style: AppTextStyles.labelLarge.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Kepatuhan: ${(statistics == null || (statistics.totalTaken + statistics.totalMissed) == 0) ? 0 : statistics.complianceRate.toStringAsFixed(0)}%',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(
                  Icons.settings_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CareDashboardPage(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (activeSchedules.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Belum ada jadwal minum obat aktif. Ketuk ikon pengaturan di kanan atas untuk menambahkan jadwal.',
                style: AppTextStyles.bodySmall.copyWith(height: 1.4),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activeSchedules.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final schedule = activeSchedules[index];
                
                // Find if there is a log for today and this schedule
                final log = todayLogs.firstWhere(
                  (l) => l.scheduleId == schedule.scheduleId,
                  orElse: () => _createDummyPendingLog(schedule.scheduleId),
                );

                final isTaken = log.status == 'TAKEN';

                return Container(
                  padding: const EdgeInsets.all(12),
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
                            Icons.alarm_on_rounded,
                            size: 18,
                            color: isTaken ? AppColors.success : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            schedule.reminderTime,
                            style: AppTextStyles.labelMedium.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isTaken ? AppColors.successDark : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      if (isTaken)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                                'Sudah',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.successDark,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ElevatedButton(
                          onPressed: () => ref.read(careNotifierProvider.notifier).confirmMedication(schedule.scheduleId),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
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

  Widget _buildNoTreatmentCard(BuildContext context) {
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.favorite_outline_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Terapi Minum Obat',
                style: AppTextStyles.labelLarge.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Anda belum mendaftarkan terapi pengobatan Anda. Daftarkan terapi untuk memantau kepatuhan minum obat harian.',
            style: AppTextStyles.bodySmall.copyWith(height: 1.4),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CareDashboardPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Mulai Terapi Sekarang'),
          ),
        ],
      ),
    );
  }

  LogEntity _createDummyPendingLog(String scheduleId) {
    return LogEntity(
      logId: '',
      scheduleId: scheduleId,
      reminderDate: '',
      reminderTime: '',
      status: 'PENDING',
    );
  }
}
