import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/care_notifier.dart';
import '../widgets/empty_treatment_widget.dart';
import '../widgets/loading_treatment_widget.dart';
import '../widgets/treatment_status_card.dart';
import '../widgets/today_schedule_card.dart';
import '../widgets/next_reminder_card.dart';
import '../widgets/statistics_card.dart';
import '../widgets/recent_history_card.dart';
import '../widgets/education_section.dart';

import 'schedule_management_page.dart';
import 'history_page.dart';
import 'statistics_page.dart';
import 'treatment_detail_page.dart';

class CareDashboardPage extends ConsumerWidget {
  const CareDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(careNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pendamping Terapi',
          style: AppTextStyles.labelLarge.copyWith(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: state.treatment.when(
        loading: () => const LoadingTreatmentWidget(),
        error: (err, _) => _buildErrorCard(context, ref, err.toString()),
        data: (treatment) {
          if (treatment == null) {
            return const EmptyTreatmentWidget();
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(careNotifierProvider.notifier).loadCareData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Treatment Status Card
                  TreatmentStatusCard(
                    treatment: treatment,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TreatmentDetailPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // 2. Next Reminder Card
                  state.schedules.when(
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                    data: (schedules) => NextReminderCard(schedules: schedules),
                  ),
                  const SizedBox(height: 16),

                  // 3. Today's Schedules Card
                  state.schedules.when(
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                    data: (schedules) {
                      return state.todayLogs.when(
                        loading: () => const SizedBox(),
                        error: (_, __) => const SizedBox(),
                        data: (logs) {
                          return TodayScheduleCard(
                            schedules: schedules,
                            logs: logs,
                            onConfirm: (scheduleId) {
                              ref.read(careNotifierProvider.notifier).confirmMedication(scheduleId);
                            },
                            onManageTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ScheduleManagementPage(),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // 4. Statistics Card
                  state.statistics.when(
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                    data: (stats) => StatisticsCard(
                      statistics: stats,
                      schedules: state.schedules.valueOrNull ?? [],
                      history: state.history.valueOrNull ?? [],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const StatisticsPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 5. Recent History Card
                  state.history.when(
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                    data: (history) => RecentHistoryCard(
                      history: history,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HistoryPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 6. Education Section
                  const EducationSection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 56,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              Text(
                'Terjadi Kesalahan',
                textAlign: TextAlign.center,
                style: AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ref.read(careNotifierProvider.notifier).loadCareData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  'Coba Lagi',
                  style: AppTextStyles.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
