// ===================== Doctor Schedule =====================
class DoctorSchedule {
  final String scheduleId;
  final String doctorId;
  final int dayOfWeek; // 0=Minggu, 1=Senin, ... 6=Sabtu
  final String startTime; // "HH:MM"
  final String endTime;   // "HH:MM"
  final int quota;
  final int bookedCount;
  final int availableSlots;
  final bool isActive;

  DoctorSchedule({required this.scheduleId, required this.doctorId,
    required this.dayOfWeek, required this.startTime, required this.endTime,
    required this.quota, required this.bookedCount, required this.availableSlots,
    required this.isActive});

  factory DoctorSchedule.fromJson(Map<String, dynamic> json) => DoctorSchedule(
    scheduleId: json['schedule_id'] as String,
    doctorId: json['doctor_id'] as String,
    dayOfWeek: (json['day_of_week'] as num).toInt(),
    startTime: json['start_time'] as String,
    endTime: json['end_time'] as String,
    quota: (json['quota'] as num).toInt(),
    bookedCount: (json['booked_count'] as num).toInt(),
    availableSlots: (json['available_slots'] as num).toInt(),
    isActive: json['is_active'] as bool,
  );

  Map<String, dynamic> toJson() => {
    'schedule_id': scheduleId, 'doctor_id': doctorId,
    'day_of_week': dayOfWeek, 'start_time': startTime, 'end_time': endTime,
    'quota': quota, 'booked_count': bookedCount,
    'available_slots': availableSlots, 'is_active': isActive,
  };
}

// ===================== Doctor (dalam Appointment) =====================
class DoctorBrief {
  final String doctorId;
  final String fullName;
  final String specialization;
  final String photoUrl;
  final String hospitalName;
  final int yearsOfExperience;

  DoctorBrief({required this.doctorId, required this.fullName,
    required this.specialization, required this.photoUrl,
    required this.hospitalName, required this.yearsOfExperience});

  factory DoctorBrief.fromJson(Map<String, dynamic> json) => DoctorBrief(
    doctorId: json['doctor_id'] as String,
    fullName: json['full_name'] as String? ?? '',
    specialization: json['specialization'] as String? ?? '',
    photoUrl: json['photo_url'] as String? ?? '',
    hospitalName: json['hospital_name'] as String? ?? '',
    yearsOfExperience: (json['years_of_experience'] as num?)?.toInt() ?? 0,
  );
}

// ===================== Appointment =====================
class Appointment {
  final String appointmentId;
  final DoctorBrief doctor;
  final DoctorSchedule schedule;
  final String appointmentDate; // "YYYY-MM-DD"
  final String complaint;
  final String? screeningResultId;
  final String status; // PENDING | CONFIRMED | ...
  final String notes;
  final String cancelReason;
  final String rescheduleReason;
  final String createdAt;
  final String updatedAt;

  Appointment({required this.appointmentId, required this.doctor,
    required this.schedule, required this.appointmentDate, required this.complaint,
    this.screeningResultId, required this.status, required this.notes,
    required this.cancelReason, required this.rescheduleReason,
    required this.createdAt, required this.updatedAt});

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
    appointmentId: json['appointment_id'] as String,
    doctor: DoctorBrief.fromJson(json['doctor'] as Map<String, dynamic>),
    schedule: DoctorSchedule.fromJson(json['schedule'] as Map<String, dynamic>),
    appointmentDate: json['appointment_date'] as String,
    complaint: json['complaint'] as String,
    screeningResultId: json['screening_result_id'] as String?,
    status: json['status'] as String,
    notes: json['notes'] as String? ?? '',
    cancelReason: json['cancel_reason'] as String? ?? '',
    rescheduleReason: json['reschedule_reason'] as String? ?? '',
    createdAt: json['created_at'] as String,
    updatedAt: json['updated_at'] as String,
  );

  // Helper status
  bool get isPending => status == 'PENDING';
  bool get isConfirmed => status == 'CONFIRMED';
}

// ===================== Request DTO =====================
class CreateAppointmentRequest {
  final String scheduleId;
  final String appointmentDate; // "YYYY-MM-DD"
  final String complaint;
  final String? screeningResultId;

  CreateAppointmentRequest({required this.scheduleId,
    required this.appointmentDate, required this.complaint,
    this.screeningResultId});

  Map<String, dynamic> toJson() => {
    'schedule_id': scheduleId,
    'appointment_date': appointmentDate,
    'complaint': complaint,
    if (screeningResultId != null) 'screening_result_id': screeningResultId,
  };
}

class RescheduleRequest {
  final String newScheduleId;
  final String newDate; // "YYYY-MM-DD"
  final String reason;

  RescheduleRequest({required this.newScheduleId, required this.newDate,
    required this.reason});

  Map<String, dynamic> toJson() => {
    'new_schedule_id': newScheduleId,
    'new_date': newDate,
    'reason': reason,
  };
}

class CancelRequest {
  final String reason;
  CancelRequest({required this.reason});
  Map<String, dynamic> toJson() => {'reason': reason};
}

// ===================== History & Dashboard =====================
class AppointmentHistoryResponse {
  final List<Appointment> items;
  final int total;
  final int page;
  final int pageSize;

  AppointmentHistoryResponse({required this.items, required this.total,
    required this.page, required this.pageSize});

  factory AppointmentHistoryResponse.fromJson(Map<String, dynamic> json) =>
    AppointmentHistoryResponse(
      items: (json['items'] as List<dynamic>)
          .map((e) => Appointment.fromJson(e as Map<String, dynamic>)).toList(),
      total: (json['total'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      pageSize: (json['page_size'] as num).toInt(),
    );
}

class AppointmentDashboard {
  final Appointment? nextAppointment;
  final List<Appointment> history;
  final int upcomingCount;

  AppointmentDashboard({this.nextAppointment, required this.history,
    required this.upcomingCount});

  factory AppointmentDashboard.fromJson(Map<String, dynamic> json) =>
    AppointmentDashboard(
      nextAppointment: json['next_appointment'] != null
          ? Appointment.fromJson(json['next_appointment'] as Map<String, dynamic>)
          : null,
      history: (json['history'] as List<dynamic>? ?? [])
          .map((e) => Appointment.fromJson(e as Map<String, dynamic>)).toList(),
      upcomingCount: (json['upcoming_count'] as num?)?.toInt() ?? 0,
    );
}
