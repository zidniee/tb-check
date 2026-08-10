import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/error_handler.dart';
import '../../domain/repositories/svir_repository.dart';
import '../datasources/svir_remote_data_source.dart';
import '../models/svir_models.dart';

class SvirRepositoryImpl implements SvirRepository {
  final SvirRemoteDataSource remoteDataSource;

  SvirRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<ApiException, SimulationResponse>> simulate(SimulationRequest req) async {
    try {
      final res = await remoteDataSource.simulate(req);
      return Right(res);
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<ApiException, CommunityRisk>> getCommunityRisk({
    required double lat,
    required double lon,
    double radiusKm = 10,
  }) async {
    try {
      final res = await remoteDataSource.getCommunityRisk(lat: lat, lon: lon, radiusKm: radiusKm);
      return Right(res);
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }
}
