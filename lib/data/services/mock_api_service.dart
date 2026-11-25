import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'api_exception.dart';
import 'json_api_service.dart';
import 'mock/mock_backend.dart';

/// Implementação da API sem servidor: lê `assets/mock/*.json` e simula a
/// latência da rede com `Future.delayed`.
///
/// Monta a mesma requisição que iria para o backend real (método, rota,
/// query, corpo, header Authorization) e entrega ao [MockBackend]. Assim, o
/// formato é exatamente o de docs/API.md.
class MockApiService extends JsonApiService {
  MockApiService({
    MockBackend? backend,
    this.latency = const Duration(milliseconds: 600),
  }) : _backend =
           backend ??
           MockBackend(
             loader: (file) => rootBundle.loadString('assets/mock/$file'),
           );

  final MockBackend _backend;

  /// Atraso de cada chamada. Use Duration.zero nos testes.
  final Duration latency;

  @override
  Future<Object?> send(
    String method,
    String path, {
    Map<String, String> query = const {},
    Map<String, dynamic>? body,
  }) async {
    await Future<void>.delayed(latency);
    final response = await _backend.handle(
      method,
      path,
      query: query,
      // Passa pelo JSON como numa requisição de verdade.
      body: body == null ? null : jsonDecode(jsonEncode(body)),
      authorization: authorization,
    );
    if (!response.isSuccess) {
      throw ApiException.fromResponse(response.statusCode, response.body);
    }
    return response.body;
  }
}
