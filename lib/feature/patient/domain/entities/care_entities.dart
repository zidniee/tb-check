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
}
