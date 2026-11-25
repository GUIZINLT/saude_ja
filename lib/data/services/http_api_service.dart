import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_exception.dart';
import 'json_api_service.dart';

/// Implementação da API pela rede (HTTP + JSON), no contrato de
/// docs/API.md.
///
/// Funciona com o servidor do mock (`dart run tool/mock_server.dart`) e com
/// qualquer backend real que siga a mesma documentação. Para usar no app:
///
///   flutter run --dart-define=API=http
///   flutter run --dart-define=API=http --dart-define=API_URL=http://10.0.2.2:8080
///
/// (No emulador Android, o localhost do computador é 10.0.2.2.)
class HttpApiService extends JsonApiService {
  HttpApiService({
    required this.baseUrl,
    http.Client? client,
    this.timeout = const Duration(seconds: 10),
  }) : _client = client ?? http.Client();

  /// Ex.: http://localhost:8080
  final String baseUrl;
  final Duration timeout;
  final http.Client _client;

  static const _networkError = ApiException(
    statusCode: 0,
    code: 'NETWORK_ERROR',
    message: 'Não foi possível conectar ao servidor. Verifique a conexão.',
  );

  @override
  Future<Object?> send(
    String method,
    String path, {
    Map<String, String> query = const {},
    Map<String, dynamic>? body,
  }) async {
    final base = Uri.parse(baseUrl);
    final uri = base.replace(
      path: '${base.path}$path'.replaceAll('//', '/'),
      queryParameters: query.isEmpty ? null : query,
    );

    final request = http.Request(method, uri)
      ..headers['Accept'] = 'application/json';
    final auth = authorization;
    if (auth != null) request.headers['Authorization'] = auth;
    if (body != null) {
      request.headers['Content-Type'] = 'application/json; charset=utf-8';
      request.body = jsonEncode(body);
    }

    final http.Response response;
    try {
      response = await http.Response.fromStream(
        await _client.send(request).timeout(timeout),
      ).timeout(timeout);
    } on TimeoutException {
      throw _networkError;
    } on http.ClientException {
      throw _networkError;
    }

    final text = utf8.decode(response.bodyBytes);
    Object? json;
    if (text.trim().isNotEmpty) {
      try {
        json = jsonDecode(text);
      } on FormatException {
        throw ApiException(
          statusCode: response.statusCode,
          code: 'INVALID_RESPONSE',
          message: 'O servidor respondeu em um formato inesperado.',
        );
      }
    }

    if (response.statusCode >= 400) {
      throw ApiException.fromResponse(response.statusCode, json);
    }
    return json;
  }

  /// Fecha as conexões abertas.
  void close() => _client.close();
}
