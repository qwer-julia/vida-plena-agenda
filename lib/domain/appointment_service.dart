import 'appointment.dart';
import 'domain_exception.dart';

/// Regras de agendamento. Não depende de Flutter nem de persistência:
/// recebe a lista de consultas existentes e devolve o novo estado.
class AppointmentService {
  AppointmentService({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;

  bool hasConflict(
    List<Appointment> existing,
    String doctorId,
    DateTime dateTime, {
    String? ignoreId,
  }) {
    return existing.any(
      (a) =>
          a.id != ignoreId &&
          !a.isCancelled &&
          a.doctorId == doctorId &&
          a.dateTime == dateTime,
    );
  }

  Appointment create({
    required List<Appointment> existing,
    required String id,
    required String patientId,
    required String doctorId,
    required DateTime dateTime,
  }) {
    _ensureFuture(dateTime, 'Escolha um horário futuro.');
    if (hasConflict(existing, doctorId, dateTime)) {
      throw const DomainException(
        'Este profissional já tem consulta neste horário.',
      );
    }
    return Appointment(
      id: id,
      patientId: patientId,
      doctorId: doctorId,
      dateTime: dateTime,
    );
  }

  Appointment confirm(Appointment appointment) {
    _ensureModifiable(appointment, 'confirmar');
    if (appointment.status == AppointmentStatus.confirmada) {
      throw const DomainException('A consulta já está confirmada.');
    }
    return appointment.copyWith(status: AppointmentStatus.confirmada);
  }

  Appointment cancel(Appointment appointment) {
    _ensureModifiable(appointment, 'cancelar');
    return appointment.copyWith(status: AppointmentStatus.cancelada);
  }

  Appointment reschedule({
    required List<Appointment> existing,
    required Appointment appointment,
    required DateTime newDateTime,
  }) {
    _ensureModifiable(appointment, 'remarcar');
    _ensureFuture(newDateTime, 'Escolha um novo horário futuro.');
    if (hasConflict(
      existing,
      appointment.doctorId,
      newDateTime,
      ignoreId: appointment.id,
    )) {
      throw const DomainException(
        'Este profissional já tem consulta neste horário.',
      );
    }
    return appointment.copyWith(
      dateTime: newDateTime,
      status: AppointmentStatus.agendada,
    );
  }

  void _ensureFuture(DateTime dateTime, String message) {
    if (!dateTime.isAfter(_clock())) throw DomainException(message);
  }

  void _ensureModifiable(Appointment appointment, String action) {
    if (appointment.status == AppointmentStatus.cancelada ||
        appointment.status == AppointmentStatus.realizada) {
      throw DomainException(
        'Não é possível $action uma consulta ${appointment.status.name}.',
      );
    }
    if (!appointment.dateTime.isAfter(_clock())) {
      throw DomainException(
        'Só é possível $action consultas futuras.',
      );
    }
  }
}
