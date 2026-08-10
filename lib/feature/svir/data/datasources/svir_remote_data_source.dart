import '../../../../core/network/api_service.dart';
import '../models/svir_models.dart';

abstract class SvirRemoteDataSource {
  Future<SimulationResponse> simulate(SimulationRequest req);
  Future<CommunityRisk> getCommunityRisk({
    required double lat,
    required double lon,
    double radiusKm,
  });
}

class SvirRemoteDataSourceImpl implements SvirRemoteDataSource {
  final ApiService apiService;

  SvirRemoteDataSourceImpl({required this.apiService});

  @override
  Future<SimulationResponse> simulate(SimulationRequest req) async {
    final res = await apiService.dio.post('/api/v1/svir/simulate', data: req.toJson());
    return SimulationResponse.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<CommunityRisk> getCommunityRisk({
    required double lat,
    required double lon,
    double radiusKm = 10,
  }) async {
    final res = await apiService.dio.get('/api/v1/svir/community-risk', queryParameters: {
      'lat': lat,
      'lon': lon,
      'radius_km': radiusKm,
    });
    return CommunityRisk.fromJson(res.data as Map<String, dynamic>);
  }
}
