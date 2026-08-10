import 'package:dartz/dartz.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/models/svir_models.dart';

abstract class SvirRepository {
  Future<Either<ApiException, SimulationResponse>> simulate(SimulationRequest req);
  Future<Either<ApiException, CommunityRisk>> getCommunityRisk({
    required double lat,
    required double lon,
    double radiusKm,
  });
}
