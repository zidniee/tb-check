import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/care_provider.dart';
import '../pages/care_settings_page.dart';
import '../pages/care_dashboard_page.dart';
import '../../data/models/care_models.dart';

class MedicationScheduleCard extends StatelessWidget {
  const MedicationScheduleCard({super.key});

  @override
  Widget build(BuildContext context) {
    final careProvider = Provider.of<CareProvider>(context);

    // If there is no active treatment, show call-to-action to setup treatment
    if (careProvider.treatment == null) {
      return _buildNoTreatmentCard(context);
    }

    final schedules = careProvider.schedules;

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
                        'Kepatuhan: ${(careProvider.statistics == null || (careProvider.statistics!.totalTaken + careProvider.statistics!.totalMissed) == 0) ? 0 : careProvider.statistics!.complianceRate.toStringAsFixed(0)}%',
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

          if (schedules.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Belum ada jadwal minum obat. Ketuk ikon pengaturan di kanan atas untuk menambahkan jadwal.',
                style: AppTextStyles.bodySmall.copyWith(height: 1.4),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: schedules.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final schedule = schedules[index];
                
                // Find if there is a log for today and this schedule
                final log = careProvider.todayLogs.firstWhere(
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
                          onPressed: () => careProvider.confirmMedication(schedule.scheduleId),
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

  dynamic _createDummyPendingLog(String scheduleId) {
    return LogResponse(
      logId: '',
      scheduleId: scheduleId,
      reminderDate: '',
      reminderTime: '',
      status: 'PENDING',
    );
  }
}
