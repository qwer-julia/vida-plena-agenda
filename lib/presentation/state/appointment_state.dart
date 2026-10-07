import 'package:flutter/foundation.dart';

import '../../data/appointment_repository.dart';
import '../../data/catalog_repository.dart';
import '../../data/reminder_scheduler.dart';
import '../../domain/appointment.dart';
import '../../domain/appointment_service.dart';
import '../../domain/doctor.dart';
import '../../domain/domain_exception.dart';
import '../../domain/reminder_policy.dart';
import '../../domain/specialty.dart';

class AppointmentState extends ChangeNotifier {
  AppointmentState(
    this._appointments,
    this._catalog, {
    AppointmentService? service,
    DateTime Function()? clock,
    String Function()? idGenerator,
    this._reminders,
  })  : _clock = clock ?? DateTime.now,
        _service = service ?? AppointmentService(clock: clock),
        _newId = idGenerator ??
            (() => DateTime.now().microsecondsSinceEpoch.toString());

  final AppointmentRepository _appointments;
  final CatalogRepository _catalog;
  final ReminderScheduler? _reminders;
  final AppointmentService _service;
  final DateTime Function() _clock;
  final String Function() _newId;

  String? _patientId;
  List<Specialty> _specialties = [];
  List<Doctor> _doctors = [];
  List<Appointment> _all = [];
  bool _loading = false;
  String? _error;

  String? get patientId => _patientId;
  bool get isLoading => _loading;
  String? get error => _error;
  List<Specialty> get specialties => List.unmodifiable(_specialties);
  List<Doctor> get doctors => List.unmodifiable(_doctors);

  /// Consultas do paciente logado, da mais próxima para a mais distante.
  List<Appointment> get appointments {
    final mine = _all.where((a) => a.patientId == _patientId).toList();
    mine.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return mine;
  }

  /// Aba "Futuras": ainda por vir e nem canceladas nem realizadas.
  List<Appointment> get upcoming => appointments.where(_isUpcoming).toList();

  /// Aba "Histórico": todo o resto, da mais recente para a mais antiga.
  List<Appointment> get history =>
      appointments.where((a) => !_isUpcoming(a)).toList().reversed.toList();

  bool _isUpcoming(Appointment a) =>
      a.dateTime.isAfter(_clock()) &&
      a.status != AppointmentStatus.cancelada &&
      a.status != AppointmentStatus.realizada;

  List<Doctor> doctorsFor(String specialtyId) =>
      _doctors.where((d) => d.specialtyId == specialtyId).toList();

  Doctor? doctorById(String id) {
    for (final d in _doctors) {
      if (d.id == id) return d;
    }
    return null;
  }

  /// Horários livres do profissional em [day] (sem passados nem ocupados).
  List<DateTime> availableSlots(Doctor doctor, DateTime day) {
    return doctor
        .slotsOn(day)
        .where(
          (s) =>
              s.isAfter(_clock()) &&
              !_service.hasConflict(_all, doctor.id, s),
        )
        .toList();
  }

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  /// Carrega catálogo e consultas para o paciente [patientId].
  Future<void> load(String patientId) async {
    _patientId = patientId;
    await _run(() async {
      _specialties = await _catalog.getSpecialties();
      _doctors = await _catalog.getDoctors();
      _all = await _appointments.getAll();
    });
  }

  /// Limpa os dados do paciente ao sair da conta.
  void reset() {
    _patientId = null;
    _all = [];
    _error = null;
    notifyListeners();
  }

  Future<bool> book(Doctor doctor, DateTime dateTime) {
    return _run(() async {
      final created = _service.create(
        existing: _all,
        id: _newId(),
        patientId: _requirePatient(),
        doctorId: doctor.id,
        dateTime: dateTime,
      );
      await _appointments.save(created);
      _all = [..._all, created];
      await _syncReminder(created);
    });
  }

  Future<bool> confirm(String id) =>
      _update(id, (a) async => _service.confirm(a));

  Future<bool> cancel(String id) =>
      _update(id, (a) async => _service.cancel(a));

  Future<bool> reschedule(String id, DateTime newDateTime) => _update(
        id,
        (a) async => _service.reschedule(
          existing: _all,
          appointment: a,
          newDateTime: newDateTime,
        ),
      );

  Future<bool> _update(
    String id,
    Future<Appointment> Function(Appointment) change,
  ) {
    return _run(() async {
      final current = _all.firstWhere(
        (a) => a.id == id,
        orElse: () => throw const DomainException('Consulta não encontrada.'),
      );
      final updated = await change(current);
      await _appointments.save(updated);
      _all = [for (final a in _all) a.id == id ? updated : a];
      await _syncReminder(updated);
    });
  }

  /// Lembrete é complemento: se falhar, a consulta já salva continua válida.
  Future<void> _syncReminder(Appointment a) async {
    final reminders = _reminders;
    if (reminders == null) return;
    try {
      final at = a.status == AppointmentStatus.agendada ||
              a.status == AppointmentStatus.confirmada
          ? reminderTimeFor(a.dateTime, _clock())
          : null;
      if (at == null) {
        await reminders.cancel(a.id);
      } else {
        await reminders.schedule(
          a,
          at: at,
          doctorName: doctorById(a.doctorId)?.name ?? 'Clínica Vida Plena',
        );
      }
    } catch (_) {}
  }

  String _requirePatient() =>
      _patientId ?? (throw const DomainException('Faça login para agendar.'));

  Future<bool> _run(Future<void> Function() action) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on DomainException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Algo deu errado. Tente novamente.';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
