import '../../../../core/network/api_service.dart';
import '../models/hospital_dto.dart';

abstract class HospitalRemoteDataSource {
  Future<List<HospitalDTO>> getAllHospitals();
  Future<HospitalDTO> getHospitalById(String hospitalId);
}

class HospitalRemoteDataSourceImpl implements HospitalRemoteDataSource {
  final ApiService apiService;

  HospitalRemoteDataSourceImpl({required this.apiService});

  @override
  Future<List<HospitalDTO>> getAllHospitals() async {
    final response = await apiService.dio.get('/api/v1/hospitals');
    final list = response.data as List<dynamic>;
    return list.map((e) => HospitalDTO.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<HospitalDTO> getHospitalById(String hospitalId) async {
    final response = await apiService.dio.get('/api/v1/hospitals/$hospitalId');
    return HospitalDTO.fromJson(response.data as Map<String, dynamic>);
  }
}
