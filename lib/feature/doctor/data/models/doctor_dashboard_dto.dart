class DoctorDashboardDTO {
  final int todayPatientCount;
  final int activeMonitoringCount;
  final int pendingConsultationsCount;
  final int unreadNotificationsCount;

  DoctorDashboardDTO({
    this.todayPatientCount = 0,
    this.activeMonitoringCount = 0,
    this.pendingConsultationsCount = 0,
    this.unreadNotificationsCount = 0,
  });

  factory DoctorDashboardDTO.fromJson(Map<String, dynamic> json) {
    return DoctorDashboardDTO(
      todayPatientCount: (json['today_patient_count'] as num?)?.toInt() ?? 0,
      activeMonitoringCount: (json['active_monitoring_count'] as num?)?.toInt() ?? 0,
      pendingConsultationsCount: (json['pending_consultations_count'] as num?)?.toInt() ?? 0,
      unreadNotificationsCount: (json['unread_notifications_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'today_patient_count': todayPatientCount,
      'active_monitoring_count': activeMonitoringCount,
      'pending_consultations_count': pendingConsultationsCount,
      'unread_notifications_count': unreadNotificationsCount,
    };
  }
}
