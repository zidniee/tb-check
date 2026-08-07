import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/error_handler.dart';
import '../../domain/repositories/hospital_repository.dart';
import '../datasources/hospital_remote_data_source.dart';
import '../models/hospital_dto.dart';

class HospitalRepositoryImpl implements HospitalRepository {
  final HospitalRemoteDataSource remoteDataSource;

  HospitalRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<ApiException, List<HospitalDTO>>> getAllHospitals() async {
    try {
      final list = await remoteDataSource.getAllHospitals();
      return Right(list);
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }

  @override
  Future<Either<ApiException, HospitalDTO>> getHospitalById(String hospitalId) async {
    try {
      final hospital = await remoteDataSource.getHospitalById(hospitalId);
      return Right(hospital);
    } on DioException catch (e) {
      return Left(ErrorHandler.handleDioError(e));
    } catch (e) {
      return Left(ServerException(message: e.toString()));
    }
  }
}
