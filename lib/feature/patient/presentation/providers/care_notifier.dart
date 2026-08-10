import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'dart:convert';

import '../../../../core/storage/cache_service.dart';
import '../../data/models/care_models.dart';
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
    // 1. Try to load cached data for instant render
    final cache = CacheService();
    try {
      final todayStr = _formatDate(DateTime.now());
      final thirtyDaysAgoStr = _formatDate(DateTime.now().subtract(const Duration(days: 30)));

      final cachedTreatmentStr = await cache.getCachedData('cache_treatment');
      final cachedSchedulesStr = await cache.getCachedData('cache_schedules');
      final cachedStatsStr = await cache.getCachedData('cache_statistics');
      final cachedTodayLogsStr = await cache.getCachedData('cache_history_${todayStr}_$todayStr');
      final cachedHistoryStr = await cache.getCachedData('cache_history_${thirtyDaysAgoStr}_$todayStr');

      TreatmentEntity? cachedTreatment;
      List<ScheduleEntity> cachedSchedules = [];
      CareStatisticsEntity? cachedStats;
      List<LogEntity> cachedTodayLogs = [];
      List<LogEntity> cachedHistory = [];

      if (cachedTreatmentStr != null) {
        cachedTreatment = TreatmentEntity.fromJson(jsonDecode(cachedTreatmentStr));
      }
      if (cachedSchedulesStr != null) {
        final List<dynamic> list = jsonDecode(cachedSchedulesStr);
        cachedSchedules = list.map((e) => ScheduleEntity.fromJson(e as Map<String, dynamic>)).toList();
      }
      if (cachedStatsStr != null) {
        cachedStats = CareStatisticsEntity.fromJson(jsonDecode(cachedStatsStr));
      }
      if (cachedTodayLogsStr != null) {
        final List<dynamic> list = jsonDecode(cachedTodayLogsStr);
        cachedTodayLogs = list.map((e) => LogEntity.fromJson(e as Map<String, dynamic>)).toList();
      }
      if (cachedHistoryStr != null) {
        final List<dynamic> list = jsonDecode(cachedHistoryStr);
        cachedHistory = list.map((e) => LogEntity.fromJson(e as Map<String, dynamic>)).toList();
      }

      if (cachedTreatment != null) {
        state = CareState(
          treatment: AsyncValue.data(cachedTreatment),
          schedules: AsyncValue.data(cachedSchedules),
          statistics: AsyncValue.data(cachedStats),
          todayLogs: AsyncValue.data(cachedTodayLogs),
          history: AsyncValue.data(cachedHistory),
        );
      }
    } catch (_) {
      // Fail silently on cache loading errors
    }

    // Set states to loading if we don't have any cached data yet to avoid blank screens
    if (state.treatment.valueOrNull == null) {
      state = state.copyWith(
        treatment: const AsyncValue.loading(),
        schedules: const AsyncValue.loading(),
        statistics: const AsyncValue.loading(),
        todayLogs: const AsyncValue.loading(),
        history: const AsyncValue.loading(),
      );
    }

    // 2. Fetch Treatment from server
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
          try {
            await cache.clearCache('cache_treatment');
            await cache.clearCache('cache_schedules');
            await cache.clearCache('cache_statistics');
          } catch (_) {}
        } else {
          // Only show error if we have no cached data; otherwise keep the cached data
          if (state.treatment.valueOrNull == null) {
            state = state.copyWith(
              treatment: AsyncValue.error(failure.message, StackTrace.current),
              schedules: AsyncValue.error(failure.message, StackTrace.current),
              statistics: AsyncValue.error(failure.message, StackTrace.current),
              todayLogs: AsyncValue.error(failure.message, StackTrace.current),
              history: AsyncValue.error(failure.message, StackTrace.current),
            );
          }
        }
      },
      (treatment) async {
        state = state.copyWith(treatment: AsyncValue.data(treatment));
        
        if (treatment != null) {
          try {
            await cache.cacheData('cache_treatment', jsonEncode(treatment.toJson()));
          } catch (_) {}
        }

        if (treatment != null && treatment.isActive) {
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

          // Map results to state and update cache
          schedulesRes.fold(
            (l) {
              if (state.schedules.valueOrNull == null) {
                state = state.copyWith(schedules: AsyncValue.error(l.message, StackTrace.current));
              }
            },
            (r) {
              state = state.copyWith(schedules: AsyncValue.data(r));
              try {
                cache.cacheData('cache_schedules', jsonEncode(r.map((e) => e.toJson()).toList()));
              } catch (_) {}
            },
          );

          statsRes.fold(
            (l) {
              if (state.statistics.valueOrNull == null) {
                state = state.copyWith(statistics: AsyncValue.error(l.message, StackTrace.current));
              }
            },
            (r) {
              state = state.copyWith(statistics: AsyncValue.data(r));
              try {
                cache.cacheData('cache_statistics', jsonEncode(r.toJson()));
              } catch (_) {}
            },
          );

          todayLogsRes.fold(
            (l) {
              if (state.todayLogs.valueOrNull == null) {
                state = state.copyWith(todayLogs: AsyncValue.error(l.message, StackTrace.current));
              }
            },
            (r) {
              state = state.copyWith(todayLogs: AsyncValue.data(r));
              try {
                cache.cacheData('cache_history_${todayStr}_$todayStr', jsonEncode(r.map((e) => e.toJson()).toList()));
              } catch (_) {}
            },
          );

          historyRes.fold(
            (l) {
              if (state.history.valueOrNull == null) {
                state = state.copyWith(history: AsyncValue.error(l.message, StackTrace.current));
              }
            },
            (r) {
              state = state.copyWith(history: AsyncValue.data(r));
              try {
                cache.cacheData('cache_history_${thirtyDaysAgoStr}_$todayStr', jsonEncode(r.map((e) => e.toJson()).toList()));
              } catch (_) {}
            },
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
