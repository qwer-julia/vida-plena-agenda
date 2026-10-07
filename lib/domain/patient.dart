class Patient {
  const Patient({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
  });

  factory Patient.fromJson(Map<String, dynamic> json) => Patient(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        password: json['password'] as String,
      );

  final String id;
  final String name;
  final String email;
  final String password;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'password': password,
      };
}
