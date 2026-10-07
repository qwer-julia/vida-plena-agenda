import 'package:flutter/foundation.dart';

import '../../data/patient_repository.dart';
import '../../domain/domain_exception.dart';
import '../../domain/patient.dart';
import '../../domain/validators.dart';

class AuthState extends ChangeNotifier {
  AuthState(this._repository, {String Function()? idGenerator})
      : _newId = idGenerator ??
            (() => DateTime.now().microsecondsSinceEpoch.toString());

  final PatientRepository _repository;
  final String Function() _newId;

  Patient? _patient;
  bool _loading = false;
  String? _error;

  Patient? get currentPatient => _patient;
  bool get isLoggedIn => _patient != null;
  bool get isLoading => _loading;
  String? get error => _error;

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  /// Recupera a sessão salva ao abrir o app.
  Future<void> restoreSession() async {
    await _run(() async {
      _patient = await _repository.getLoggedPatient();
    });
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _run(() async {
      if (name.trim().isEmpty) {
        throw const DomainException('Informe seu nome.');
      }
      Validators.ensureValidEmail(email);
      Validators.ensureValidPassword(password);
      if (await _repository.findByEmail(email) != null) {
        throw const DomainException('Já existe uma conta com este e-mail.');
      }
      final patient = Patient(
        id: _newId(),
        name: name.trim(),
        email: email.trim(),
        password: password,
      );
      await _repository.save(patient);
      await _repository.setLoggedPatient(patient.id);
      _patient = patient;
    });
  }

  Future<bool> login({required String email, required String password}) {
    return _run(() async {
      Validators.ensureValidEmail(email);
      Validators.ensureValidPassword(password);
      final patient = await _repository.findByEmail(email);
      if (patient == null || patient.password != password) {
        throw const DomainException('E-mail ou senha incorretos.');
      }
      await _repository.setLoggedPatient(patient.id);
      _patient = patient;
    });
  }

  Future<void> logout() async {
    await _run(() async {
      await _repository.setLoggedPatient(null);
      _patient = null;
    });
  }

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
