import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/patient.dart';
import 'patient_repository.dart';

class LocalPatientRepository implements PatientRepository {
  LocalPatientRepository(this._prefs);

  static const patientsKey = 'patients';
  static const loggedKey = 'logged_patient_id';

  final SharedPreferences _prefs;

  List<Patient> _readAll() {
    final raw = _prefs.getString(patientsKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => Patient.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Patient?> findByEmail(String email) async {
    final wanted = email.trim().toLowerCase();
    for (final p in _readAll()) {
      if (p.email.toLowerCase() == wanted) return p;
    }
    return null;
  }

  @override
  Future<void> save(Patient patient) async {
    final all = _readAll()..removeWhere((p) => p.id == patient.id);
    all.add(patient);
    await _prefs.setString(
      patientsKey,
      jsonEncode(all.map((p) => p.toJson()).toList()),
    );
  }

  @override
  Future<Patient?> getLoggedPatient() async {
    final id = _prefs.getString(loggedKey);
    if (id == null) return null;
    for (final p in _readAll()) {
      if (p.id == id) return p;
    }
    return null;
  }

  @override
  Future<void> setLoggedPatient(String? patientId) async {
    if (patientId == null) {
      await _prefs.remove(loggedKey);
    } else {
      await _prefs.setString(loggedKey, patientId);
    }
  }
}
