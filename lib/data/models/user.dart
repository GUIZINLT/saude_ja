class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.createdAt,
  });

  /// Primeiro nome, para a saudação da Home ("Olá, Maria").
  String get firstName => name.split(' ').first;

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'createdAt': createdAt.toIso8601String(),
  };
}
