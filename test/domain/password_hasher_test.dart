import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:vida_plena_agenda/domain/password_hasher.dart';
import 'package:vida_plena_agenda/domain/patient.dart';

String hex(String b64) =>
    base64Decode(b64).map((b) => b.toRadixString(16).padLeft(2, '0')).join();

void main() {
  group('PasswordHasher', () {
    final salt = base64Encode(utf8.encode('salt'));

    // Vetores conhecidos de PBKDF2-HMAC-SHA256 (senha "password", salt "salt").
    test('bate com o vetor de referência (1 iteração)', () {
      expect(hex(PasswordHasher.hash('password', salt, rounds: 1)),
          '120fb6cffcf8b32c43e7225256c4f837a86548c92ccc35480805987cb70be17b');
    });

    test('bate com o vetor de referência (2 iterações)', () {
      expect(hex(PasswordHasher.hash('password', salt, rounds: 2)),
          'ae4d0c95af6b46d32d0adff928f06dd02a303f8ef3c251dfd6e2d85a95474c43');
    });

    test('bate com o vetor de referência (4096 iterações)', () {
      expect(hex(PasswordHasher.hash('password', salt, rounds: 4096)),
          'c5e478d59288c841aa530db6845c4c8d962893a001ce4e11a4963873aa98134a');
    });

    test('verify aceita a senha certa e recusa a errada', () {
      final s = PasswordHasher.newSalt();
      final h = PasswordHasher.hash('123456', s);
      expect(PasswordHasher.verify('123456', salt: s, hash: h), isTrue);
      expect(PasswordHasher.verify('654321', salt: s, hash: h), isFalse);
    });

    test('mesma senha com salts diferentes gera hashes diferentes', () {
      final a = PasswordHasher.hash('123456', PasswordHasher.newSalt());
      final b = PasswordHasher.hash('123456', PasswordHasher.newSalt());
      expect(a, isNot(b));
    });
  });

  group('Patient (RNF04)', () {
    test('o JSON não contém a senha em texto', () {
      final p = Patient.withPassword(
          id: 'p1', name: 'Ana', email: 'ana@email.com', password: 'segredo123');
      final json = jsonEncode(p.toJson());
      expect(json, isNot(contains('segredo123')));
      expect(p.toJson().containsKey('password'), isFalse);
    });

    test('ida e volta pelo JSON mantém a senha válida', () {
      final p = Patient.withPassword(
          id: 'p1', name: 'Ana', email: 'ana@email.com', password: 'segredo123');
      final back = Patient.fromJson(p.toJson());
      expect(back.matchesPassword('segredo123'), isTrue);
      expect(back.matchesPassword('outra'), isFalse);
    });

    test('dados antigos com senha em texto são migrados para hash', () {
      final p = Patient.fromJson({
        'id': 'p1',
        'name': 'Ana',
        'email': 'ana@email.com',
        'password': '123456',
      });
      expect(p.matchesPassword('123456'), isTrue);
      expect(jsonEncode(p.toJson()), isNot(contains('"password"')));
    });
  });
}
