enum AppointmentStatus { agendada, confirmada, cancelada, realizada }

class Appointment {
  const Appointment({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.dateTime,
    this.status = AppointmentStatus.agendada,
  });

  final String id;
  final String patientId;
  final String doctorId;
  final DateTime dateTime;
  final AppointmentStatus status;

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
