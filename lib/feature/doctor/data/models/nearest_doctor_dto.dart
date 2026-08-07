class NearestDoctorDTO {
  final String doctorId;
  final String doctorName;
  final String specialization;
  final String hospitalName;
  final String hospitalAddress;
  final double distanceMeter;
  final bool acceptingPatient;
  final String onlineStatus;

  NearestDoctorDTO({
    required this.doctorId,
    required this.doctorName,
    required this.specialization,
    required this.hospitalName,
    required this.hospitalAddress,
    required this.distanceMeter,
    required this.acceptingPatient,
    required this.onlineStatus,
  });

  factory NearestDoctorDTO.fromJson(Map<String, dynamic> json) {
    return NearestDoctorDTO(
      doctorId: (json['doctor_id'] ?? '') as String,
      doctorName: (json['doctor_name'] ?? '') as String,
      specialization: (json['specialization'] ?? '') as String,
      hospitalName: (json['hospital_name'] ?? '') as String,
      hospitalAddress: (json['hospital_address'] ?? '') as String,
      distanceMeter: (json['distance_meter'] as num?)?.toDouble() ?? 0.0,
      acceptingPatient: (json['accepting_patient'] as bool?) ?? true,
      onlineStatus: (json['online_status'] ?? 'OFFLINE') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'specialization': specialization,
      'hospital_name': hospitalName,
      'hospital_address': hospitalAddress,
      'distance_meter': distanceMeter,
      'accepting_patient': acceptingPatient,
      'online_status': onlineStatus,
    };
  }
}
