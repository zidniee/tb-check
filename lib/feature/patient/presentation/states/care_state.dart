import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/care_entities.dart';

class CareState {
  final AsyncValue<TreatmentEntity?> treatment;
  final AsyncValue<List<ScheduleEntity>> schedules;
  final AsyncValue<CareStatisticsEntity?> statistics;
  final AsyncValue<List<LogEntity>> todayLogs;
  final AsyncValue<List<LogEntity>> history;

  CareState({
    required this.treatment,
    required this.schedules,
    required this.statistics,
    required this.todayLogs,
    required this.history,
  });

  CareState copyWith({
    AsyncValue<TreatmentEntity?>? treatment,
    AsyncValue<List<ScheduleEntity>>? schedules,
    AsyncValue<CareStatisticsEntity?>? statistics,
    AsyncValue<List<LogEntity>>? todayLogs,
    AsyncValue<List<LogEntity>>? history,
  }) {
    return CareState(
      treatment: treatment ?? this.treatment,
      schedules: schedules ?? this.schedules,
      statistics: statistics ?? this.statistics,
      todayLogs: todayLogs ?? this.todayLogs,
      history: history ?? this.history,
    );
  }

  bool get isLoading =>
      treatment.isLoading ||
      schedules.isLoading ||
      statistics.isLoading ||
      todayLogs.isLoading ||
      history.isLoading;

  bool get hasError =>
      treatment.hasError ||
      schedules.hasError ||
      statistics.hasError ||
      todayLogs.hasError ||
      history.hasError;

  String get errorMessage {
    if (treatment.hasError) return treatment.error.toString();
    if (schedules.hasError) return schedules.error.toString();
    if (statistics.hasError) return statistics.error.toString();
    if (todayLogs.hasError) return todayLogs.error.toString();
    if (history.hasError) return history.error.toString();
    return 'Terjadi kesalahan tidak dikenal.';
  }
}
