class PatientDashboardDTO {
  final int healthScore;
  final int healthScoreChange;
  final List<LungCapacityTrendPoint> lungCapacityTrend;

  const PatientDashboardDTO({
    required this.healthScore,
    required this.healthScoreChange,
    required this.lungCapacityTrend,
  });

  /// Desimal skor (0.0–1.0) untuk `_HealthScorePainter(score: ...)`.
  double get scoreFraction => (healthScore / 100).clamp(0.0, 1.0);

  /// `true` jika skor mingguan naik.
  bool get isScoreUp => healthScoreChange > 0;

  /// `true` jika skor mingguan turun.
  bool get isScoreDown => healthScoreChange < 0;

  factory PatientDashboardDTO.fromJson(Map<String, dynamic> json) {
    return PatientDashboardDTO(
      healthScore: (json['health_score'] as num?)?.toInt() ?? 0,
      healthScoreChange: (json['health_score_change'] as num?)?.toInt() ?? 0,
      lungCapacityTrend: (json['lung_capacity_trend'] as List<dynamic>? ?? const [])
          .map((e) => LungCapacityTrendPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'health_score': healthScore,
      'health_score_change': healthScoreChange,
      'lung_capacity_trend': lungCapacityTrend.map((e) => e.toJson()).toList(),
    };
  }
}

class LungCapacityTrendPoint {
  final String day; // "Sen", "Sel", "Rab", ...
  final int percentage; // 60–95

  const LungCapacityTrendPoint({required this.day, required this.percentage});

  factory LungCapacityTrendPoint.fromJson(Map<String, dynamic> json) {
    return LungCapacityTrendPoint(
      day: (json['day'] as String?) ?? '',
      percentage: (json['percentage'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'day': day, 'percentage': percentage};
  }
}
