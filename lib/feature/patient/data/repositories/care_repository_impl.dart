import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/error_handler.dart';
import '../../../../core/storage/cache_service.dart';
import '../../domain/entities/care_entities.dart';
import '../../domain/repositories/care_repository.dart';
import '../datasources/care_remote_data_source.dart';
import '../models/care_models.dart';

class CareRepositoryImpl implements CareRepository {
  final CareRemoteDataSource remoteDataSource;
  final CacheService _cache = CacheService();

  CareRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<ApiException, TreatmentEntity>> getTreatment() async {
    try {
      final model = await remoteDataSource.getTreatment();
      await _cache.cacheData('cache_treatment', jsonEncode(model.toJson()));
      return Right(model.toEntity());
    } on DioException catch (e) {
      // Offline fallback
      final cachedStr = await _cache.getCachedData('cache_treatment');
      if (cachedStr != null) {
        try {
          final model = TreatmentResponse.fromJson(jsonDecode(cachedStr));
          return Right(model.toEntity());
        } catch (_) {}
      }
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<ApiException, TreatmentEntity>> createTreatment(Map<String, dynamic> data) async {
    try {
      final model = await remoteDataSource.createTreatment(data);
      await _cache.clearCache('cache_treatment');
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<ApiException, TreatmentEntity>> updateTreatment(Map<String, dynamic> data) async {
    try {
      final model = await remoteDataSource.updateTreatment(data);
      await _cache.clearCache('cache_treatment');
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<ApiException, void>> deleteTreatment() async {
    try {
      await remoteDataSource.deleteTreatment();
      await _cache.clearCache('cache_treatment');
      await _cache.clearCache('cache_schedules');
      await _cache.clearCache('cache_today_logs');
      await _cache.clearCache('cache_statistics');
      return const Right(null);
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<ApiException, List<ScheduleEntity>>> getSchedules() async {
    try {
      final list = await remoteDataSource.getSchedules();
      final jsonList = list.map((e) => e.toJson()).toList();
      await _cache.cacheData('cache_schedules', jsonEncode(jsonList));
      return Right(list.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      // Offline fallback
      final cachedStr = await _cache.getCachedData('cache_schedules');
      if (cachedStr != null) {
        try {
          final List<dynamic> jsonList = jsonDecode(cachedStr);
          final list = jsonList.map((e) => ScheduleResponse.fromJson(e).toEntity()).toList();
          return Right(list);
        } catch (_) {}
      }
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<ApiException, ScheduleEntity>> addSchedule(String reminderTime) async {
    try {
      final model = await remoteDataSource.addSchedule(reminderTime);
      await _cache.clearCache('cache_schedules');
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<ApiException, ScheduleEntity>> updateSchedule(String scheduleId, Map<String, dynamic> data) async {
    try {
      final model = await remoteDataSource.updateSchedule(scheduleId, data);
      await _cache.clearCache('cache_schedules');
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<ApiException, void>> deleteSchedule(String scheduleId) async {
    try {
      await remoteDataSource.deleteSchedule(scheduleId);
      await _cache.clearCache('cache_schedules');
      return const Right(null);
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<ApiException, LogEntity>> confirmMedication(String scheduleId, String date) async {
    try {
      final model = await remoteDataSource.confirmMedication(scheduleId, date);
      await _cache.clearCache('cache_today_logs');
      await _cache.clearCache('cache_statistics');
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<ApiException, List<LogEntity>>> getHistory(String startDate, String endDate) async {
    final key = 'cache_history_${startDate}_$endDate';
    try {
      final list = await remoteDataSource.getHistory(startDate, endDate);
      final jsonList = list.map((e) => e.toJson()).toList();
      await _cache.cacheData(key, jsonEncode(jsonList));
      return Right(list.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      // Offline fallback
      final cachedStr = await _cache.getCachedData(key);
      if (cachedStr != null) {
        try {
          final List<dynamic> jsonList = jsonDecode(cachedStr);
          final list = jsonList.map((e) => LogResponse.fromJson(e).toEntity()).toList();
          return Right(list);
        } catch (_) {}
      }
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<ApiException, CareStatisticsEntity>> getStatistics() async {
    try {
      final model = await remoteDataSource.getStatistics();
      await _cache.cacheData('cache_statistics', jsonEncode(model.toJson()));
      return Right(model.toEntity());
    } on DioException catch (e) {
      // Offline fallback
      final cachedStr = await _cache.getCachedData('cache_statistics');
      if (cachedStr != null) {
        try {
          final model = StatisticsResponse.fromJson(jsonDecode(cachedStr));
          return Right(model.toEntity());
        } catch (_) {}
      }
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }
}
