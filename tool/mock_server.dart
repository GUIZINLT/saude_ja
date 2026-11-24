// Servidor HTTP opcional com o mesmo mock usado dentro do app.
//
// Use se o professor pedir um "backend" rodando de verdade, ou para testar
// as rotas no navegador/Postman/curl:
//
//   dart run tool/mock_server.dart            (porta 8080)
//   dart run tool/mock_server.dart --port 3000
//
// Rode na raiz do projeto (onde está a pasta assets/).
import 'dart:convert';
import 'dart:io';

import 'package:saude_ja/data/services/mock/mock_backend.dart';

Future<void> main(List<String> args) async {
  final portIndex = args.indexOf('--port');
  final port = portIndex >= 0 && portIndex + 1 < args.length
      ? int.parse(args[portIndex + 1])
      : 8080;

  final backend = MockBackend(
    loader: (file) => File('assets/mock/$file').readAsString(),
  );

  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  stdout.writeln('SaúdeJá mock rodando em http://localhost:$port');

  await for (final request in server) {
    final res = request.response;
    res.headers
      ..set('Access-Control-Allow-Origin', '*')
      ..set('Access-Control-Allow-Methods', 'GET, POST, PATCH, OPTIONS')
      ..set('Access-Control-Allow-Headers', 'Content-Type, Authorization');

    if (request.method == 'OPTIONS') {
      res.statusCode = HttpStatus.noContent;
      await res.close();
      continue;
    }

    MockResponse result;
    final raw = await utf8.decoder.bind(request).join();
    Object? body;
    var bodyOk = true;
    if (raw.trim().isNotEmpty) {
      try {
        body = jsonDecode(raw);
      } on FormatException {
        bodyOk = false;
      }
    }

    if (!bodyOk) {
      result = const MockResponse(400, {
        'error': {
          'code': 'INVALID_JSON',
          'message': 'Corpo não é um JSON válido.',
        },
      });
    } else {
      result = await backend.handle(
        request.method,
        request.uri.path,
        query: request.uri.queryParameters,
        body: body,
        authorization: request.headers.value(HttpHeaders.authorizationHeader),
      );
    }

    stdout.writeln('${request.method} ${request.uri} -> ${result.statusCode}');
    res.statusCode = result.statusCode;
    res.headers.contentType = ContentType.json;
    res.write(jsonEncode(result.body));
    await res.close();
  }
}
