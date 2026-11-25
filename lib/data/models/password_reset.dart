/// Resposta de POST /auth/forgot-password.
class PasswordResetRequest {
  /// Mensagem para mostrar ao usuário.
  final String message;

  /// Só no mock: o código que um backend real mandaria por e-mail. Em
  /// produção é sempre null.
  final String? devCode;

  const PasswordResetRequest({required this.message, this.devCode});

  factory PasswordResetRequest.fromJson(Map<String, dynamic> json) =>
      PasswordResetRequest(
        message: json['message'] as String,
        devCode: json['devCode'] as String?,
      );
}
