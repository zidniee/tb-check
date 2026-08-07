import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/api_service.dart';
import '../../data/datasources/care_remote_data_source.dart';
import '../../data/repositories/care_repository_impl.dart';
import '../../domain/repositories/care_repository.dart';
import '../../domain/entities/care_entities.dart';
import '../../domain/usecases/care_usecases.dart';
import '../states/care_state.dart';

// 1. Data Source Provider
final careRemoteDataSourceProvider = Provider<CareRemoteDataSource>((ref) {
  return CareRemoteDataSourceImpl(apiService: ApiService());
});

// 2. Repository Provider
final careRepositoryProvider = Provider<CareRepository>((ref) {
  final dataSource = ref.watch(careRemoteDataSourceProvider);
  return CareRepositoryImpl(remoteDataSource: dataSource);
});

// 3. Usecase Providers
final getTreatmentUseCaseProvider = Provider((ref) => GetTreatmentUseCase(ref.watch(careRepositoryProvider)));
final setupTreatmentUseCaseProvider = Provider((ref) => SetupTreatmentUseCase(ref.watch(careRepositoryProvider)));
final updateTreatmentReminderUseCaseProvider = Provider((ref) => UpdateTreatmentReminderUseCase(ref.watch(careRepositoryProvider)));
final deleteTreatmentUseCaseProvider = Provider((ref) => DeleteTreatmentUseCase(ref.watch(careRepositoryProvider)));
final getSchedulesUseCaseProvider = Provider((ref) => GetSchedulesUseCase(ref.watch(careRepositoryProvider)));
final addScheduleUseCaseProvider = Provider((ref) => AddScheduleUseCase(ref.watch(careRepositoryProvider)));
final updateScheduleUseCaseProvider = Provider((ref) => UpdateScheduleUseCase(ref.watch(careRepositoryProvider)));
final deleteScheduleUseCaseProvider = Provider((ref) => DeleteScheduleUseCase(ref.watch(careRepositoryProvider)));
final confirmMedicationUseCaseProvider = Provider((ref) => ConfirmMedicationUseCase(ref.watch(careRepositoryProvider)));
final getHistoryUseCaseProvider = Provider((ref) => GetHistoryUseCase(ref.watch(careRepositoryProvider)));
final getStatisticsUseCaseProvider = Provider((ref) => GetStatisticsUseCase(ref.watch(careRepositoryProvider)));

// 4. Care Notifier
class CareNotifier extends StateNotifier<CareState> {
  final Ref _ref;

  CareNotifier(this._ref)
      : super(CareState(
          treatment: const AsyncValue.loading(),
          schedules: const AsyncValue.loading(),
          statistics: const AsyncValue.loading(),
          todayLogs: const AsyncValue.loading(),
          history: const AsyncValue.loading(),
        )) {
    loadCareData();
  }

  Future<void> loadCareData() async {
    // Set all states to loading if they aren't already
    if (!state.isLoading) {
      state = state.copyWith(
        treatment: const AsyncValue.loading(),
        schedules: const AsyncValue.loading(),
        statistics: const AsyncValue.loading(),
        todayLogs: const AsyncValue.loading(),
        history: const AsyncValue.loading(),
      );
    }

    // 1. Fetch Treatment
    final treatmentRes = await _ref.read(getTreatmentUseCaseProvider).call();
    
    await treatmentRes.fold(
      (failure) async {
        if (failure.statusCode == 404) {
          // Patient has no treatment registered
          state = CareState(
            treatment: const AsyncValue.data(null),
            schedules: const AsyncValue.data([]),
            statistics: const AsyncValue.data(null),
            todayLogs: const AsyncValue.data([]),
            history: const AsyncValue.data([]),
          );
        } else {
          state = state.copyWith(
            treatment: AsyncValue.error(failure.message, StackTrace.current),
            schedules: AsyncValue.error(failure.message, StackTrace.current),
            statistics: AsyncValue.error(failure.message, StackTrace.current),
            todayLogs: AsyncValue.error(failure.message, StackTrace.current),
            history: AsyncValue.error(failure.message, StackTrace.current),
          );
        }
      },
      (treatment) async {
        state = state.copyWith(treatment: AsyncValue.data(treatment));
        
        if (treatment.isActive) {
          // Parallel fetch schedules, statistics, and history (last 30 days)
          final todayStr = _formatDate(DateTime.now());
          final thirtyDaysAgoStr = _formatDate(DateTime.now().subtract(const Duration(days: 30)));

          final results = await Future.wait([
            _ref.read(getSchedulesUseCaseProvider).call(),
            _ref.read(getStatisticsUseCaseProvider).call(),
            _ref.read(getHistoryUseCaseProvider).call(todayStr, todayStr),
            _ref.read(getHistoryUseCaseProvider).call(thirtyDaysAgoStr, todayStr),
          ]);

          final schedulesRes = results[0] as Either<ApiException, List<ScheduleEntity>>;
          final statsRes = results[1] as Either<ApiException, CareStatisticsEntity>;
          final todayLogsRes = results[2] as Either<ApiException, List<LogEntity>>;
          final historyRes = results[3] as Either<ApiException, List<LogEntity>>;

          // Map results to state
          schedulesRes.fold(
            (l) => state = state.copyWith(schedules: AsyncValue.error(l.message, StackTrace.current)),
            (r) => state = state.copyWith(schedules: AsyncValue.data(r)),
          );

          statsRes.fold(
            (l) => state = state.copyWith(statistics: AsyncValue.error(l.message, StackTrace.current)),
            (r) => state = state.copyWith(statistics: AsyncValue.data(r)),
          );

          todayLogsRes.fold(
            (l) => state = state.copyWith(todayLogs: AsyncValue.error(l.message, StackTrace.current)),
            (r) => state = state.copyWith(todayLogs: AsyncValue.data(r)),
          );

          historyRes.fold(
            (l) => state = state.copyWith(history: AsyncValue.error(l.message, StackTrace.current)),
            (r) => state = state.copyWith(history: AsyncValue.data(r)),
          );
        } else {
          state = state.copyWith(
            schedules: const AsyncValue.data([]),
            statistics: const AsyncValue.data(null),
            todayLogs: const AsyncValue.data([]),
            history: const AsyncValue.data([]),
          );
        }
      },
    );
  }

  Future<bool> setupTreatment({required String timezone, required String startDate}) async {
    state = state.copyWith(treatment: const AsyncValue.loading());
    final res = await _ref.read(setupTreatmentUseCaseProvider).call(timezone, startDate);
    return res.fold(
      (l) {
        state = state.copyWith(treatment: AsyncValue.error(l.message, StackTrace.current));
        return false;
      },
      (r) {
        loadCareData();
        return true;
      },
    );
  }

  Future<bool> updateTreatmentReminder(bool reminderEnabled) async {
    final activeTreatment = state.treatment.value;
    if (activeTreatment == null) return false;

    state = state.copyWith(treatment: const AsyncValue.loading());
    final res = await _ref.read(updateTreatmentReminderUseCaseProvider).call(
          activeTreatment.startDate,
          activeTreatment.timezone,
          reminderEnabled,
        );
    return res.fold(
      (l) {
        state = state.copyWith(treatment: AsyncValue.error(l.message, StackTrace.current));
        return false;
      },
      (r) {
        state = state.copyWith(treatment: AsyncValue.data(r));
        return true;
      },
    );
  }

  Future<bool> deleteTreatment() async {
    state = state.copyWith(treatment: const AsyncValue.loading());
    final res = await _ref.read(deleteTreatmentUseCaseProvider).call();
    return res.fold(
      (l) {
        state = state.copyWith(treatment: AsyncValue.error(l.message, StackTrace.current));
        return false;
      },
      (r) {
        state = CareState(
          treatment: const AsyncValue.data(null),
          schedules: const AsyncValue.data([]),
          statistics: const AsyncValue.data(null),
          todayLogs: const AsyncValue.data([]),
          history: const AsyncValue.data([]),
        );
        return true;
      },
    );
  }

  Future<bool> addSchedule(String reminderTime) async {
    final res = await _ref.read(addScheduleUseCaseProvider).call(reminderTime);
    return res.fold(
      (l) => false,
      (r) {
        loadCareData();
        return true;
      },
    );
  }

  Future<bool> updateSchedule(String scheduleId, String reminderTime, bool isActive) async {
    final res = await _ref.read(updateScheduleUseCaseProvider).call(scheduleId, reminderTime, isActive);
    return res.fold(
      (l) => false,
      (r) {
        loadCareData();
        return true;
      },
    );
  }

  Future<bool> deleteSchedule(String scheduleId) async {
    final res = await _ref.read(deleteScheduleUseCaseProvider).call(scheduleId);
    return res.fold(
      (l) => false,
      (r) {
        loadCareData();
        return true;
      },
    );
  }

  Future<bool> confirmMedication(String scheduleId) async {
    final todayStr = _formatDate(DateTime.now());
    final res = await _ref.read(confirmMedicationUseCaseProvider).call(scheduleId, todayStr);
    return res.fold(
      (l) => false,
      (r) {
        loadCareData();
        return true;
      },
    );
  }

  String _formatDate(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
  }
}

// 5. Global Provider Reference
final careNotifierProvider = StateNotifierProvider<CareNotifier, CareState>((ref) {
  return CareNotifier(ref);
});
