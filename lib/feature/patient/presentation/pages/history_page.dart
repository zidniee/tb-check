import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/care_notifier.dart';
import '../../domain/entities/care_entities.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
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
          'Riwayat Terapi',
          style: AppTextStyles.labelLarge.copyWith(fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
            onPressed: () => _pickDate(context),
          ),
        ],
      ),
      body: state.history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Gagal memuat: $err')),
        data: (logs) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Horizontal Calendar list
              _buildHorizontalCalendarBar(),
              const SizedBox(height: 20),
              
              // Timeline header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Timeline Hari Ini',
                  style: AppTextStyles.labelLarge.copyWith(fontSize: 16),
                ),
              ),
              const SizedBox(height: 12),

              // Timeline content list
              Expanded(
                child: state.schedules.when(
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                  data: (schedules) => _buildTimelineContent(schedules, logs),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHorizontalCalendarBar() {
    // Generate dates for the last 7 days
    final dates = List<DateTime>.generate(7, (index) {
      return DateTime.now().subtract(Duration(days: 6 - index));
    });

    return Container(
      height: 90,
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = DateUtils.isSameDay(date, _selectedDate);
          
          final dayName = DateFormat('E', 'id_ID').format(date).toUpperCase().substring(0, 3);
          final dayNum = date.day.toString();

          return InkWell(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 50,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isSelected ? Colors.white.withOpacity(0.9) : AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    dayNum,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimelineContent(List<ScheduleEntity> schedules, List<LogEntity> logs) {
    final dateStr = _formatDate(_selectedDate);
    
    // Find logs matching selected date
    final dayLogs = logs.where((l) => l.reminderDate == dateStr).toList();

    if (schedules.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada jadwal alarm terdaftar.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        final log = dayLogs.firstWhere(
          (l) => l.scheduleId == schedule.scheduleId,
          orElse: () => LogEntity(
            logId: '',
            scheduleId: schedule.scheduleId,
            reminderDate: dateStr,
            reminderTime: schedule.reminderTime,
            status: 'PENDING',
          ),
        );

        final isTaken = log.status == 'TAKEN';
        final isMissed = log.status == 'MISSED';
        
        final isLast = index == schedules.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Timeline connector line
              Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isTaken
                          ? AppColors.successLight
                          : (isMissed ? Colors.redAccent.withOpacity(0.1) : AppColors.border),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        isTaken
                            ? Icons.check_rounded
                            : (isMissed ? Icons.close_rounded : Icons.alarm_rounded),
                        size: 14,
                        color: isTaken
                            ? AppColors.success
                            : (isMissed ? Colors.redAccent : AppColors.textSecondary),
                      ),
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: AppColors.border,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              
              // Timeline card body
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              schedule.reminderTime,
                              style: AppTextStyles.labelMedium.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isTaken
                                  ? 'Obat diminum tepat waktu'
                                  : (isMissed ? 'Jadwal obat terlewat' : 'Menunggu jadwal'),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          isTaken ? 'TAKEN' : (isMissed ? 'MISSED' : 'PENDING'),
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            color: isTaken
                                ? AppColors.success
                                : (isMissed ? Colors.redAccent : AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
  }
}
