import 'password_hasher.dart';

class Patient {
  const Patient({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.passwordSalt,
  });

  /// Cria o paciente a partir da senha em texto; só o hash é mantido.
  factory Patient.withPassword({
    required String id,
    required String name,
    required String email,
    required String password,
    String? salt,
  }) {
    final s = salt ?? PasswordHasher.newSalt();
    return Patient(
      id: id,
      name: name,
      email: email,
      passwordHash: PasswordHasher.hash(password, s),
      passwordSalt: s,
    );
  }

  factory Patient.fromJson(Map<String, dynamic> json) {
    final hash = json['passwordHash'] as String?;
    if (hash != null) {
      return Patient(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        passwordHash: hash,
        passwordSalt: json['passwordSalt'] as String,
      );
    }
    // Dados antigos, gravados com a senha em texto: migra para hash ao ler
    // (o texto some do aparelho na próxima vez que o paciente é salvo).
    return Patient.withPassword(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }

  final String id;
  final String name;
  final String email;
  final String passwordHash;
  final String passwordSalt;

  bool matchesPassword(String password) => PasswordHasher.verify(
        password,
        salt: passwordSalt,
        hash: passwordHash,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'passwordHash': passwordHash,
        'passwordSalt': passwordSalt,
      };
}
