import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/error_handler.dart';
import '../../domain/repositories/doctor_dashboard_repository.dart';
import '../datasources/doctor_dashboard_remote_data_source.dart';
import '../models/doctor_dashboard_dto.dart';

class DoctorDashboardRepositoryImpl implements DoctorDashboardRepository {
  final DoctorDashboardRemoteDataSource remoteDataSource;

  DoctorDashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<ApiException, DoctorDashboardDTO>> getDoctorDashboard() async {
    try {
      final json = await remoteDataSource.getDoctorDashboard();
      return Right(DoctorDashboardDTO.fromJson(json));
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }
}
