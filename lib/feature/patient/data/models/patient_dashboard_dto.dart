class PatientDashboardDTO {
  final double? latestProbabilityScore;
  final String? latestPredictionStatus;
  final String? medicationAdherenceStatus;
  final int activeConsultationsCount;
  final int unreadNotificationsCount;
  final String? lastScreeningDate;

  PatientDashboardDTO({
    this.latestProbabilityScore,
    this.latestPredictionStatus,
    this.medicationAdherenceStatus,
    this.activeConsultationsCount = 0,
    this.unreadNotificationsCount = 0,
    this.lastScreeningDate,
  });

  factory PatientDashboardDTO.fromJson(Map<String, dynamic> json) {
    return PatientDashboardDTO(
      latestProbabilityScore: (json['latest_probability_score'] as num?)?.toDouble() ??
          (json['probability_score'] as num?)?.toDouble(),
      latestPredictionStatus: (json['latest_prediction_status'] ?? json['prediction_status']) as String?,
      medicationAdherenceStatus: (json['medication_adherence_status'] ?? json['followup_status']) as String?,
      activeConsultationsCount: (json['active_consultations_count'] as num?)?.toInt() ?? 0,
      unreadNotificationsCount: (json['unread_notifications_count'] as num?)?.toInt() ?? 0,
      lastScreeningDate: (json['last_screening_date'] ?? json['last_screening_at']) as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latest_probability_score': latestProbabilityScore,
      'latest_prediction_status': latestPredictionStatus,
      'medication_adherence_status': medicationAdherenceStatus,
      'active_consultations_count': activeConsultationsCount,
      'unread_notifications_count': unreadNotificationsCount,
      'last_screening_date': lastScreeningDate,
    };
  }
}
