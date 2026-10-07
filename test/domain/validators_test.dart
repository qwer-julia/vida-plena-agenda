import 'package:flutter_test/flutter_test.dart';
import 'package:vida_plena_agenda/domain/domain_exception.dart';
import 'package:vida_plena_agenda/domain/validators.dart';

void main() {
  group('e-mail', () {
    test('aceita e-mails válidos', () {
      for (final e in ['ana@email.com', 'a.b+c@sub.dominio.com.br', ' ana@email.com ']) {
        expect(Validators.isValidEmail(e), isTrue, reason: e);
      }
    });

    test('rejeita e-mails inválidos', () {
      for (final e in ['', 'ana', 'ana@', '@email.com', 'ana@email', 'ana @email.com', 'ana@email.c']) {
        expect(Validators.isValidEmail(e), isFalse, reason: e);
      }
    });

    test('ensureValidEmail lança DomainException', () {
      expect(() => Validators.ensureValidEmail('x'), throwsA(isA<DomainException>()));
      expect(() => Validators.ensureValidEmail('x@y.com'), returnsNormally);
    });
  });

  group('senha', () {
    test('exige no mínimo 6 caracteres', () {
      expect(Validators.isValidPassword('12345'), isFalse);
      expect(Validators.isValidPassword(''), isFalse);
      expect(Validators.isValidPassword('123456'), isTrue);
    });

    test('ensureValidPassword lança DomainException', () {
      expect(() => Validators.ensureValidPassword('123'), throwsA(isA<DomainException>()));
      expect(() => Validators.ensureValidPassword('1234567'), returnsNormally);
    });
  });
}
