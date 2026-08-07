class PatientMonitoringDTO {
  final String monitoringId;
  final String patientId;
  final String doctorId;
  final String patientName;
  final String followupStatus;
  final String? lastScreeningAt;
  final bool inactivityAlert;
  final String? notes;
  final DateTime createdAt;

  PatientMonitoringDTO({
    required this.monitoringId,
    required this.patientId,
    required this.doctorId,
    required this.patientName,
    required this.followupStatus,
    this.lastScreeningAt,
    required this.inactivityAlert,
    this.notes,
    required this.createdAt,
  });

  factory PatientMonitoringDTO.fromJson(Map<String, dynamic> json) {
    return PatientMonitoringDTO(
      monitoringId: (json['monitoring_id'] ?? json['id'] ?? '') as String,
      patientId: (json['patient_id'] ?? '') as String,
      doctorId: (json['doctor_id'] ?? '') as String,
      patientName: (json['patient_name'] ?? '') as String,
      followupStatus: (json['followup_status'] ?? 'under_treatment') as String,
      lastScreeningAt: json['last_screening_at'] as String?,
      inactivityAlert: (json['inactivity_alert'] as bool?) ?? false,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monitoring_id': monitoringId,
      'patient_id': patientId,
      'doctor_id': doctorId,
      'patient_name': patientName,
      'followup_status': followupStatus,
      'last_screening_at': lastScreeningAt,
      'inactivity_alert': inactivityAlert,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
