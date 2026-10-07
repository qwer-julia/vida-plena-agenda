import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/appointment.dart';
import 'appointment_repository.dart';

class LocalAppointmentRepository implements AppointmentRepository {
  LocalAppointmentRepository(this._prefs);

  static const appointmentsKey = 'appointments';

  final SharedPreferences _prefs;

  @override
  Future<List<Appointment>> getAll() async {
    final raw = _prefs.getString(appointmentsKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Appointment>> getByPatient(String patientId) async {
    final all = await getAll();
    return all.where((a) => a.patientId == patientId).toList();
  }

  @override
  Future<void> save(Appointment appointment) async {
    final all = await getAll();
    final index = all.indexWhere((a) => a.id == appointment.id);
    if (index >= 0) {
      all[index] = appointment;
    } else {
      all.add(appointment);
    }
    await _prefs.setString(
      appointmentsKey,
      jsonEncode(all.map((a) => a.toJson()).toList()),
    );
  }
}
