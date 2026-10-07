import '../domain/patient.dart';

abstract class PatientRepository {
  Future<Patient?> findByEmail(String email);
  Future<void> save(Patient patient);

  /// Paciente com sessão ativa (persiste entre execuções).
  Future<Patient?> getLoggedPatient();
  Future<void> setLoggedPatient(String? patientId);
}
