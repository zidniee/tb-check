class TreatmentEntity {
  final String treatmentId;
  final String userId;
  final bool isActive;
  final String startDate;
  final String? estimatedEndDate;
  final String timezone;
  final bool reminderEnabled;

  TreatmentEntity({
    required this.treatmentId,
    required this.userId,
    required this.isActive,
    required this.startDate,
    this.estimatedEndDate,
    required this.timezone,
    required this.reminderEnabled,
  });

  factory TreatmentEntity.fromJson(Map<String, dynamic> json) {
    return TreatmentEntity(
      treatmentId: (json['treatment_id'] ?? '') as String,
      userId: (json['user_id'] ?? '') as String,
      isActive: (json['is_active'] as bool?) ?? false,
      startDate: (json['start_date'] ?? '') as String,
      estimatedEndDate: json['estimated_end_date'] as String?,
      timezone: (json['timezone'] ?? 'UTC') as String,
      reminderEnabled: (json['reminder_enabled'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'treatment_id': treatmentId,
      'user_id': userId,
      'is_active': isActive,
      'start_date': startDate,
      'estimated_end_date': estimatedEndDate,
      'timezone': timezone,
      'reminder_enabled': reminderEnabled,
    };
  }
}

class ScheduleEntity {
  final String scheduleId;
  final String treatmentId;
  final String reminderTime;
  final bool isActive;

  ScheduleEntity({
    required this.scheduleId,
    required this.treatmentId,
    required this.reminderTime,
    required this.isActive,
  });

  factory ScheduleEntity.fromJson(Map<String, dynamic> json) {
    return ScheduleEntity(
      scheduleId: (json['schedule_id'] ?? '') as String,
      treatmentId: (json['treatment_id'] ?? '') as String,
      reminderTime: (json['reminder_time'] ?? '') as String,
      isActive: (json['is_active'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schedule_id': scheduleId,
      'treatment_id': treatmentId,
      'reminder_time': reminderTime,
      'is_active': isActive,
    };
  }
}

class LogEntity {
  final String logId;
  final String scheduleId;
  final String reminderDate;
  final String reminderTime;
  final String? confirmedAt;
  final String status;

  LogEntity({
    required this.logId,
    required this.scheduleId,
    required this.reminderDate,
    required this.reminderTime,
    this.confirmedAt,
    required this.status,
  });

  factory LogEntity.fromJson(Map<String, dynamic> json) {
    return LogEntity(
      logId: (json['log_id'] ?? '') as String,
      scheduleId: (json['schedule_id'] ?? '') as String,
      reminderDate: (json['reminder_date'] ?? '') as String,
      reminderTime: (json['reminder_time'] ?? '') as String,
      confirmedAt: json['confirmed_at'] as String?,
      status: (json['status'] ?? 'PENDING') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'log_id': logId,
      'schedule_id': scheduleId,
      'reminder_date': reminderDate,
      'reminder_time': reminderTime,
      'confirmed_at': confirmedAt,
      'status': status,
    };
  }
}

class CareStatisticsEntity {
  final int totalScheduled;
  final int totalTaken;
  final int totalMissed;
  final int totalPending;
  final double complianceRate;

  CareStatisticsEntity({
    required this.totalScheduled,
    required this.totalTaken,
    required this.totalMissed,
    required this.totalPending,
    required this.complianceRate,
  });

  factory CareStatisticsEntity.fromJson(Map<String, dynamic> json) {
    return CareStatisticsEntity(
      totalScheduled: (json['total_scheduled'] as num?)?.toInt() ?? 0,
      totalTaken: (json['total_taken'] as num?)?.toInt() ?? 0,
      totalMissed: (json['total_missed'] as num?)?.toInt() ?? 0,
      totalPending: (json['total_pending'] as num?)?.toInt() ?? 0,
      complianceRate: (json['compliance_rate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_scheduled': totalScheduled,
      'total_taken': totalTaken,
      'total_missed': totalMissed,
      'total_pending': totalPending,
      'compliance_rate': complianceRate,
    };
  }
}
