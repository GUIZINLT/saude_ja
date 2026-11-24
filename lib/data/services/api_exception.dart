/// Erro devolvido pela API (formato `{ "error": { code, message, fields } }`).
///
/// O ViewModel pode mostrar [message] direto na tela e usar [fields] para
/// marcar o campo com erro no formulário.
class ApiException implements Exception {
  final int statusCode;
  final String code;
  final String message;
  final Map<String, String> fields;

  const ApiException({
    required this.statusCode,
    required this.code,
    required this.message,
    this.fields = const {},
  });

  factory ApiException.fromResponse(int statusCode, Object? body) {
    final error = body is Map && body['error'] is Map
        ? body['error'] as Map
        : const <String, dynamic>{};
    final fields = error['fields'] is Map
        ? (error['fields'] as Map).map(
            (k, v) => MapEntry(k.toString(), v.toString()),
          )
        : const <String, String>{};
    return ApiException(
      statusCode: statusCode,
      code: error['code']?.toString() ?? 'UNKNOWN_ERROR',
      message:
          error['message']?.toString() ?? 'Erro inesperado. Tente novamente.',
      fields: fields,
    );
  }

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => 'ApiException($statusCode, $code): $message';
}
