import '../domain/appointment.dart';

abstract class ReminderScheduler {
  /// Agenda (ou reagenda) o lembrete da consulta em [at].
  Future<void> schedule(
    Appointment appointment, {
    required DateTime at,
    required String doctorName,
  });

  Future<void> cancel(String appointmentId);
}
