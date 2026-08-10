import 'package:flutter/material.dart';
import '../../../../core/network/api_service.dart';
import '../../data/datasources/svir_remote_data_source.dart';
import '../../data/models/svir_models.dart';
import '../../data/repositories/svir_repository_impl.dart';
import '../../domain/repositories/svir_repository.dart';

class SvirProvider extends ChangeNotifier {
  final SvirRepository _repository;

  SvirProvider({SvirRepository? repository})
      : _repository = repository ??
            SvirRepositoryImpl(
              remoteDataSource: SvirRemoteDataSourceImpl(
                apiService: ApiService(),
              ),
            );

  bool _isLoading = false;
  String? _errorMessage;

  SimulationResponse? _simulationResponse;
  CommunityRisk? _communityRisk;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  SimulationResponse? get simulationResponse => _simulationResponse;
  CommunityRisk? get communityRisk => _communityRisk;

  Future<void> runSimulation(SimulationRequest req) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final n = req.population.toDouble();
      final i0 = req.initialInfected.toDouble();
      final r0 = req.initialRecovered.toDouble();
      
      double v0 = req.vaccinationRate * (n - i0 - r0);
      double s0 = n - i0 - r0 - v0;
      
      s0 = s0 < 0 ? 0.0 : s0;
      v0 = v0 < 0 ? 0.0 : v0;
      final double realI0 = i0 < 0 ? 0.0 : i0;
      final double realR0 = r0 < 0 ? 0.0 : r0;
      
      final beta = req.contactRate;
      final gamma = req.recoveryRate;
      final sigma = req.vaccineEfficacy;
      final mu = req.mortalityRate;
      final vRate = req.vaccinationRate;
      
      final List<double> daysList = [];
      final List<double> s = List<double>.filled(req.days + 1, 0.0);
      final List<double> v = List<double>.filled(req.days + 1, 0.0);
      final List<double> i = List<double>.filled(req.days + 1, 0.0);
      final List<double> r = List<double>.filled(req.days + 1, 0.0);
      
      s[0] = s0;
      v[0] = v0;
      i[0] = realI0;
      r[0] = realR0;
      daysList.add(0.0);
      
      const double dt = 1.0;
      
      for (int t = 0; t < req.days; t++) {
        daysList.add((t + 1).toDouble());
        final st = s[t];
        final vt = v[t];
        final it = i[t];
        final rt = r[t];
        
        double currentN = st + vt + it + rt;
        if (currentN <= 0) {
          currentN = 1.0;
        }
        
        final dS = (mu * (1.0 - vRate) * n) - (beta * st * it / currentN) - (mu * st);
        final dV = (mu * vRate * n) - ((1.0 - sigma) * beta * vt * it / currentN) - (mu * vt);
        final dI = (beta * st * it / currentN) + ((1.0 - sigma) * beta * vt * it / currentN) - ((gamma + mu) * it);
        final dR = (gamma * it) - (mu * rt);
        
        double nextS = st + dS * dt;
        double nextV = vt + dV * dt;
        double nextI = it + dI * dt;
        double nextR = rt + dR * dt;
        
        s[t + 1] = nextS < 0 ? 0.0 : nextS;
        v[t + 1] = nextV < 0 ? 0.0 : nextV;
        i[t + 1] = nextI < 0 ? 0.0 : nextI;
        r[t + 1] = nextR < 0 ? 0.0 : nextR;
        
        if (mu == 0.0) {
          final total = s[t + 1] + v[t + 1] + i[t + 1] + r[t + 1];
          if (total > 0) {
            final scale = n / total;
            s[t + 1] *= scale;
            v[t + 1] *= scale;
            i[t + 1] *= scale;
            r[t + 1] *= scale;
          }
        }
      }

      _simulationResponse = SimulationResponse(
        days: daysList,
        susceptible: s,
        vaccinated: v,
        infected: i,
        recovered: r,
        parameters: req.toJson(),
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadCommunityRisk({
    required double lat,
    required double lon,
    double radiusKm = 10,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getCommunityRisk(lat: lat, lon: lon, radiusKm: radiusKm);
    result.fold(
      (failure) => _errorMessage = failure.message,
      (data) => _communityRisk = data,
    );

    _isLoading = false;
    notifyListeners();
  }
}
