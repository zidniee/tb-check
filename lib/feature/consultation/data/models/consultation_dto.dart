class ConsultationDTO {
  final String consultationId;
  final String patientId;
  final String doctorId;
  final String? reportId;
  final bool consentGranted;
  final DateTime? consentTimestamp;
  final String status;
  final DateTime createdAt;

  ConsultationDTO({
    required this.consultationId,
    required this.patientId,
    required this.doctorId,
    this.reportId,
    required this.consentGranted,
    this.consentTimestamp,
    required this.status,
    required this.createdAt,
  });

  factory ConsultationDTO.fromJson(Map<String, dynamic> json) {
    return ConsultationDTO(
      consultationId: (json['consultation_id'] ?? json['id'] ?? '') as String,
      patientId: (json['patient_id'] ?? '') as String,
      doctorId: (json['doctor_id'] ?? '') as String,
      reportId: json['report_id'] as String?,
      consentGranted: (json['consent_granted'] as bool?) ?? false,
      consentTimestamp: json['consent_timestamp'] != null
          ? DateTime.parse(json['consent_timestamp'] as String)
          : null,
      status: (json['status'] ?? 'ACTIVE') as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'consultation_id': consultationId,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'report_id': reportId,
      'consent_granted': consentGranted,
      'consent_timestamp': consentTimestamp?.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
