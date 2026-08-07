import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/error_handler.dart';
import '../../domain/entities/care_entities.dart';
import '../../domain/repositories/care_repository.dart';
import '../datasources/care_remote_data_source.dart';

class CareRepositoryImpl implements CareRepository {
  final CareRemoteDataSource remoteDataSource;

  CareRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<ApiException, TreatmentEntity>> getTreatment() async {
    try {
      final model = await remoteDataSource.getTreatment();
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<ApiException, TreatmentEntity>> createTreatment(Map<String, dynamic> data) async {
    try {
      final model = await remoteDataSource.createTreatment(data);
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
      return Right(list.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<ApiException, ScheduleEntity>> addSchedule(String reminderTime) async {
    try {
      final model = await remoteDataSource.addSchedule(reminderTime);
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
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<ApiException, List<LogEntity>>> getHistory(String startDate, String endDate) async {
    try {
      final list = await remoteDataSource.getHistory(startDate, endDate);
      return Right(list.map((e) => e.toEntity()).toList());
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<ApiException, CareStatisticsEntity>> getStatistics() async {
    try {
      final model = await remoteDataSource.getStatistics();
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }
}
