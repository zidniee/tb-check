import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/error_handler.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment_remote_data_source.dart';
import '../models/appointment_models.dart';
import '../../../doctor/data/models/nearest_doctor_dto.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentRemoteDataSource remoteDataSource;

  AppointmentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<ApiException, List<DoctorSchedule>>> getSchedulesByDoctor(String doctorId) async {
    try {
      final res = await remoteDataSource.getSchedulesByDoctor(doctorId);
      return Right(res);
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<ApiException, Appointment>> createAppointment(CreateAppointmentRequest req) async {
    try {
      final res = await remoteDataSource.createAppointment(req);
      return Right(res);
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<ApiException, List<Appointment>>> getMyAppointments({String? status}) async {
    try {
      final res = await remoteDataSource.getMyAppointments(status: status);
      return Right(res);
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<ApiException, Appointment>> getAppointmentById(String id) async {
    try {
      final res = await remoteDataSource.getAppointmentById(id);
      return Right(res);
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<ApiException, Appointment>> reschedule(String id, RescheduleRequest req) async {
    try {
      final res = await remoteDataSource.reschedule(id, req);
      return Right(res);
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<ApiException, Appointment>> cancel(String id, CancelRequest req) async {
    try {
      final res = await remoteDataSource.cancel(id, req);
      return Right(res);
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<ApiException, AppointmentHistoryResponse>> getHistory({
    String? status,
    int? month,
    int? year,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final res = await remoteDataSource.getHistory(
        status: status,
        month: month,
        year: year,
        page: page,
        pageSize: pageSize,
      );
      return Right(res);
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<ApiException, AppointmentDashboard>> getDashboard() async {
    try {
      final res = await remoteDataSource.getDashboard();
      return Right(res);
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<ApiException, List<NearestDoctorDTO>>> getNearestDoctors({
    required double latitude,
    required double longitude,
    double radiusKm = 50.0,
  }) async {
    try {
      final res = await remoteDataSource.getNearestDoctors(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      );
      return Right(res);
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }
}
