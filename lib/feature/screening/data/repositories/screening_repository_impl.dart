import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/error_handler.dart';
import '../../domain/repositories/screening_repository.dart';
import '../datasources/screening_remote_data_source.dart';
import '../models/screening_report_dto.dart';

class ScreeningRepositoryImpl implements ScreeningRepository {
  final ScreeningRemoteDataSource remoteDataSource;

  ScreeningRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<ApiException, ScreeningReportDTO>> submitReport({
    required double probabilityScore,
    required String predictionStatus,
    required List<double> mfccMeanVector,
    required Map<String, dynamic> clinicalAnswers,
  }) async {
    try {
      final report = await remoteDataSource.submitReport(
        probabilityScore: probabilityScore,
        predictionStatus: predictionStatus,
        mfccMeanVector: mfccMeanVector,
        clinicalAnswers: clinicalAnswers,
      );
      return Right(report);
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<ApiException, List<ScreeningReportDTO>>> getMyReports({int limit = 100, int page = 1}) async {
    try {
      final reports = await remoteDataSource.getMyReports(limit: limit, page: page);
      return Right(reports);
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<ApiException, ScreeningReportDTO>> getReportById(String reportId) async {
    try {
      final report = await remoteDataSource.getReportById(reportId);
      return Right(report);
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }
}
