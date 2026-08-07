class NotificationPreferencesDTO {
  final bool dailyScreeningEnabled;
  final String dailyScreeningTime;
  final bool educationNotificationsEnabled;
  final bool appointmentRemindersEnabled;

  NotificationPreferencesDTO({
    required this.dailyScreeningEnabled,
    required this.dailyScreeningTime,
    required this.educationNotificationsEnabled,
    required this.appointmentRemindersEnabled,
  });

  factory NotificationPreferencesDTO.fromJson(Map<String, dynamic> json) {
    return NotificationPreferencesDTO(
      dailyScreeningEnabled: (json['daily_screening_enabled'] as bool?) ?? true,
      dailyScreeningTime: (json['daily_screening_time'] ?? '08:00') as String,
      educationNotificationsEnabled: (json['education_notifications_enabled'] as bool?) ?? true,
      appointmentRemindersEnabled: (json['appointment_reminders_enabled'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'daily_screening_enabled': dailyScreeningEnabled,
      'daily_screening_time': dailyScreeningTime,
      'education_notifications_enabled': educationNotificationsEnabled,
      'appointment_reminders_enabled': appointmentRemindersEnabled,
    };
  }

  NotificationPreferencesDTO copyWith({
    bool? dailyScreeningEnabled,
    String? dailyScreeningTime,
    bool? educationNotificationsEnabled,
    bool? appointmentRemindersEnabled,
  }) {
    return NotificationPreferencesDTO(
      dailyScreeningEnabled: dailyScreeningEnabled ?? this.dailyScreeningEnabled,
      dailyScreeningTime: dailyScreeningTime ?? this.dailyScreeningTime,
      educationNotificationsEnabled: educationNotificationsEnabled ?? this.educationNotificationsEnabled,
      appointmentRemindersEnabled: appointmentRemindersEnabled ?? this.appointmentRemindersEnabled,
    );
  }
}
