enum AppointmentStatus { agendada, confirmada, cancelada, realizada }

class Appointment {
  const Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.dateTime,
    this.status = AppointmentStatus.agendada,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
        id: json['id'] as String,
        patientId: json['patientId'] as String,
        doctorId: json['doctorId'] as String,
        dateTime: DateTime.parse(json['dateTime'] as String),
        status: AppointmentStatus.values.byName(json['status'] as String),
      );

  final String id;
  final String patientId;
  final String doctorId;
  final DateTime dateTime;
  final AppointmentStatus status;

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientId': patientId,
        'doctorId': doctorId,
        'dateTime': dateTime.toIso8601String(),
        'status': status.name,
      };

  bool get isCancelled => status == AppointmentStatus.cancelada;

  Appointment copyWith({DateTime? dateTime, AppointmentStatus? status}) {
    return Appointment(
      id: id,
      patientId: patientId,
      doctorId: doctorId,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
    );
  }
}
