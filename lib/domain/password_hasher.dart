import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// Hash de senha com PBKDF2-HMAC-SHA256 (RFC 8018) e salt por usuário.
/// A senha em si nunca é gravada; só o salt e o hash.
class PasswordHasher {
  const PasswordHasher._();

  static const iterations = 10000;
  static const saltBytes = 16;

  static String newSalt([Random? random]) {
    final r = random ?? Random.secure();
    return base64Encode([for (var i = 0; i < saltBytes; i++) r.nextInt(256)]);
  }

  static String hash(String password, String salt, {int rounds = iterations}) {
    final hmac = Hmac(sha256, utf8.encode(password));
    // Um único bloco de 32 bytes: U1 = HMAC(senha, salt || INT(1)).
    var u = Uint8List.fromList(
      hmac.convert([...base64Decode(salt), 0, 0, 0, 1]).bytes,
    );
    final result = Uint8List.fromList(u);
    for (var i = 1; i < rounds; i++) {
      u = Uint8List.fromList(hmac.convert(u).bytes);
      for (var j = 0; j < result.length; j++) {
        result[j] ^= u[j];
      }
    }
    return base64Encode(result);
  }

  static bool verify(String password, {required String salt, required String hash}) {
    final candidate = PasswordHasher.hash(password, salt);
    if (candidate.length != hash.length) return false;
    var diff = 0;
    for (var i = 0; i < candidate.length; i++) {
      diff |= candidate.codeUnitAt(i) ^ hash.codeUnitAt(i);
    }
    return diff == 0;
  }
}
