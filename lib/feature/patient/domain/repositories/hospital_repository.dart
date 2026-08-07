import 'package:dartz/dartz.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/models/hospital_dto.dart';

abstract class HospitalRepository {
  Future<Either<ApiException, List<HospitalDTO>>> getAllHospitals();
  Future<Either<ApiException, HospitalDTO>> getHospitalById(String hospitalId);
}
