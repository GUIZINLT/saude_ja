import 'user.dart';

/// Resposta de POST /auth/login e POST /auth/register.
class AuthSession {
  final String token;
  final User user;

  const AuthSession({required this.token, required this.user});

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
    token: json['token'] as String,
    user: User.fromJson(json['user'] as Map<String, dynamic>),
  );
}
