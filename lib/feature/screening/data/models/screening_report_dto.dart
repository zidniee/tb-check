class ScreeningReportDTO {
  final String reportId;
  final String patientId;
  final double probabilityScore;
  final String predictionStatus;
  final List<double> mfccMeanVector;
  final Map<String, dynamic> clinicalAnswers;
  final DateTime createdAt;

  ScreeningReportDTO({
    required this.reportId,
    required this.patientId,
    required this.probabilityScore,
    required this.predictionStatus,
    required this.mfccMeanVector,
    required this.clinicalAnswers,
    required this.createdAt,
  });

  factory ScreeningReportDTO.fromJson(Map<String, dynamic> json) {
    return ScreeningReportDTO(
      reportId: (json['report_id'] ?? json['id'] ?? '') as String,
      patientId: (json['patient_id'] ?? '') as String,
      probabilityScore: (json['probability_score'] as num).toDouble(),
      predictionStatus: (json['prediction_status'] ?? '') as String,
      mfccMeanVector: (json['mfcc_mean_vector'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      clinicalAnswers: (json['clinical_answers'] as Map<String, dynamic>?) ?? {},
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'report_id': reportId,
      'patient_id': patientId,
      'probability_score': probabilityScore,
      'prediction_status': predictionStatus,
      'mfcc_mean_vector': mfccMeanVector,
      'clinical_answers': clinicalAnswers,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
