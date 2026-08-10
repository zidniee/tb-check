// ===================== Simulate =====================
class SimulationRequest {
  final int population;        // default 100000
  final int initialInfected;   // default 100
  final int initialRecovered;  // default 0
  final double vaccinationRate;// default 0.3
  final double contactRate;    // default 0.5
  final double recoveryRate;   // default 0.1
  final double vaccineEfficacy;// default 0.8
  final double mortalityRate;  // default 0.0
  final int days;              // default 180 (1-1000)

  SimulationRequest({
    this.population = 100000, this.initialInfected = 100,
    this.initialRecovered = 0, this.vaccinationRate = 0.3,
    this.contactRate = 0.5, this.recoveryRate = 0.1,
    this.vaccineEfficacy = 0.8, this.mortalityRate = 0.0,
    this.days = 180,
  });

  Map<String, dynamic> toJson() => {
    'population': population, 'initial_infected': initialInfected,
    'initial_recovered': initialRecovered, 'vaccination_rate': vaccinationRate,
    'contact_rate': contactRate, 'recovery_rate': recoveryRate,
    'vaccine_efficacy': vaccineEfficacy, 'mortality_rate': mortalityRate,
    'days': days,
  };
}

class SimulationResponse {
  final List<double> days;
  final List<double> susceptible;
  final List<double> vaccinated;
  final List<double> infected;
  final List<double> recovered;
  final Map<String, dynamic> parameters;

  SimulationResponse({required this.days, required this.susceptible,
    required this.vaccinated, required this.infected, required this.recovered,
    required this.parameters});

  factory SimulationResponse.fromJson(Map<String, dynamic> json) =>
    SimulationResponse(
      days: _toDoubleList(json['days']),
      susceptible: _toDoubleList(json['susceptible']),
      vaccinated: _toDoubleList(json['vaccinated']),
      infected: _toDoubleList(json['infected']),
      recovered: _toDoubleList(json['recovered']),
      parameters: json['parameters'] as Map<String, dynamic>? ?? {},
    );
}

List<double> _toDoubleList(dynamic v) =>
    (v as List<dynamic>? ?? []).map((e) => (e as num).toDouble()).toList();

// ===================== Community Risk =====================
class CommunityRisk {
  final int totalScreenings;
  final int positiveCases;
  final int negativeCases;
  final double infectionRatio; // 0-1
  final String riskLevel;      // LOW | MEDIUM | HIGH
  final double radiusKm;

  CommunityRisk({required this.totalScreenings, required this.positiveCases,
    required this.negativeCases, required this.infectionRatio,
    required this.riskLevel, required this.radiusKm});

  factory CommunityRisk.fromJson(Map<String, dynamic> json) => CommunityRisk(
    totalScreenings: (json['total_screenings'] as num?)?.toInt() ?? 0,
    positiveCases: (json['positive_cases'] as num?)?.toInt() ?? 0,
    negativeCases: (json['negative_cases'] as num?)?.toInt() ?? 0,
    infectionRatio: (json['infection_ratio'] as num?)?.toDouble() ?? 0,
    riskLevel: json['risk_level'] as String? ?? 'LOW',
    radiusKm: (json['radius_km'] as num?)?.toDouble() ?? 10,
  );

  // Helper warna risiko
  bool get isHighRisk => riskLevel == 'HIGH';
  bool get isMediumRisk => riskLevel == 'MEDIUM';
}
