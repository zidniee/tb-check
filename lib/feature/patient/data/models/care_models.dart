import '../../domain/entities/care_entities.dart';

class TreatmentResponse {
  final String treatmentId;
  final String userId;
  final bool isActive;
  final String startDate;
  final String? estimatedEndDate;
  final String timezone;
  final bool reminderEnabled;

  TreatmentResponse({
    required this.treatmentId,
    required this.userId,
    required this.isActive,
    required this.startDate,
    this.estimatedEndDate,
    required this.timezone,
    required this.reminderEnabled,
  });

  factory TreatmentResponse.fromJson(Map<String, dynamic> json) {
    return TreatmentResponse(
      treatmentId: (json['treatment_id'] ?? json['id'] ?? '') as String,
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

  TreatmentEntity toEntity() {
    return TreatmentEntity(
      treatmentId: treatmentId,
      userId: userId,
      isActive: isActive,
      startDate: startDate,
      estimatedEndDate: estimatedEndDate,
      timezone: timezone,
      reminderEnabled: reminderEnabled,
    );
  }
}

class ScheduleResponse {
  final String scheduleId;
  final String treatmentId;
  final String reminderTime;
  final bool isActive;

  ScheduleResponse({
    required this.scheduleId,
    required this.treatmentId,
    required this.reminderTime,
    required this.isActive,
  });

  factory ScheduleResponse.fromJson(Map<String, dynamic> json) {
    return ScheduleResponse(
      scheduleId: (json['schedule_id'] ?? json['id'] ?? '') as String,
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

  ScheduleEntity toEntity() {
    return ScheduleEntity(
      scheduleId: scheduleId,
      treatmentId: treatmentId,
      reminderTime: reminderTime,
      isActive: isActive,
    );
  }
}

class LogResponse {
  final String logId;
  final String scheduleId;
  final String reminderDate;
  final String reminderTime;
  final String? confirmedAt;
  final String status; // PENDING, TAKEN, MISSED

  LogResponse({
    required this.logId,
    required this.scheduleId,
    required this.reminderDate,
    required this.reminderTime,
    this.confirmedAt,
    required this.status,
  });

  factory LogResponse.fromJson(Map<String, dynamic> json) {
    return LogResponse(
      logId: (json['log_id'] ?? json['id'] ?? '') as String,
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

  LogEntity toEntity() {
    return LogEntity(
      logId: logId,
      scheduleId: scheduleId,
      reminderDate: reminderDate,
      reminderTime: reminderTime,
      confirmedAt: confirmedAt,
      status: status,
    );
  }
}

class StatisticsResponse {
  final int totalScheduled;
  final int totalTaken;
  final int totalMissed;
  final int totalPending;
  final double complianceRate;

  StatisticsResponse({
    required this.totalScheduled,
    required this.totalTaken,
    required this.totalMissed,
    required this.totalPending,
    required this.complianceRate,
  });

  factory StatisticsResponse.fromJson(Map<String, dynamic> json) {
    return StatisticsResponse(
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

  CareStatisticsEntity toEntity() {
    return CareStatisticsEntity(
      totalScheduled: totalScheduled,
      totalTaken: totalTaken,
      totalMissed: totalMissed,
      totalPending: totalPending,
      complianceRate: complianceRate,
    );
  }
}
