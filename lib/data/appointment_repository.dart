import '../domain/appointment.dart';

abstract class AppointmentRepository {
  Future<List<Appointment>> getAll();
  Future<List<Appointment>> getByPatient(String patientId);

  /// Insere a consulta ou substitui a existente com o mesmo id.
  Future<void> save(Appointment appointment);
}
