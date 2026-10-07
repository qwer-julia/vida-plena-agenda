import 'domain_exception.dart';

class Validators {
  static const int minPasswordLength = 6;

  static final RegExp _emailRegex =
      RegExp(r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9\-]+(\.[A-Za-z0-9\-]+)*\.[A-Za-z]{2,}$');

  static bool isValidEmail(String email) => _emailRegex.hasMatch(email.trim());

  static bool isValidPassword(String password) =>
      password.length >= minPasswordLength;

  static void ensureValidEmail(String email) {
    if (!isValidEmail(email)) {
      throw const DomainException('Informe um e-mail válido.');
    }
  }

  static void ensureValidPassword(String password) {
    if (!isValidPassword(password)) {
      throw const DomainException(
        'A senha deve ter no mínimo $minPasswordLength caracteres.',
      );
    }
  }
}
