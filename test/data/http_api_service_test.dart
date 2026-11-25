import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:saude_ja/data/models/appointment.dart';
import 'package:saude_ja/data/services/api_exception.dart';
import 'package:saude_ja/data/services/http_api_service.dart';

import '../helpers/test_api.dart';

/// Testa o HttpApiService de ponta a ponta: as requisições HTTP que ele
/// monta vão para o MockBackend (o mesmo do tool/mock_server.dart) e as
/// respostas voltam como HTTP.
void main() {
  setUpAll(loadMockAssets);

  late List<http.BaseRequest> requests;

  HttpApiService createService() {
    requests = [];
    final backend = createTestBackend();
    final client = MockClient((request) async {
      requests.add(request);
      final result = await backend.handle(
        request.method,
        request.url.path,
        query: request.url.queryParameters,
        body: request.body.isEmpty ? null : jsonDecode(request.body),
        authorization: request.headers['Authorization'],
      );
      return http.Response(
        jsonEncode(result.body),
        result.statusCode,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    return HttpApiService(baseUrl: 'http://localhost:8080', client: client);
  }

  test('login manda JSON e guarda o token para as próximas chamadas', () async {
    final api = createService();
    final session = await api.login(
      email: 'maria@saudeja.com',
      password: '123456',
    );
    expect(session.user.name, 'Maria Souza');

    final login = requests.single as http.Request;
    expect(login.method, 'POST');
    expect(login.url.toString(), 'http://localhost:8080/auth/login');
    expect(login.headers['Content-Type'], contains('application/json'));

    final upcoming = await api.getAppointments(
      status: [AppointmentStatus.confirmed],
    );
    expect(upcoming.single.doctorName, 'Dra. Helena Ribeiro');
    expect(requests.last.headers['Authorization'], 'Bearer ${session.token}');
    expect(requests.last.url.queryParameters['status'], 'confirmed');
  });

  test('acentos chegam certos (UTF-8)', () async {
    final specialties = await createService().getSpecialties();
    expect(specialties.map((s) => s.name), contains('Oftalmologia'));
    final doctors = await createService().getDoctors(featured: true);
    expect(doctors.first.bio, contains('experiência'));
  });

  test('erro da API vira ApiException com código e campos', () async {
    final api = createService();
    await expectLater(
      api.login(email: 'maria@saudeja.com', password: 'errada'),
      throwsA(
        isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 401)
            .having((e) => e.code, 'code', 'INVALID_CREDENTIALS'),
      ),
    );
  });

  test('agendar e cancelar pela rede', () async {
    final api = createService();
    await api.login(email: 'maria@saudeja.com', password: '123456');
    final created = await api.createAppointment(
      doctorId: 'd1',
      date: '2026-11-27',
      time: '10:00',
    );
    expect(created.status, AppointmentStatus.confirmed);

    final cancelled = await api.cancelAppointment(created.id);
    expect(cancelled.status, AppointmentStatus.cancelled);
    expect(requests.last.method, 'PATCH');
  });

  test('sem conexão vira NETWORK_ERROR', () async {
    final api = HttpApiService(
      baseUrl: 'http://localhost:8080',
      client: MockClient((_) => throw http.ClientException('sem rede')),
    );
    await expectLater(
      api.getSpecialties(),
      throwsA(
        isA<ApiException>().having((e) => e.code, 'code', 'NETWORK_ERROR'),
      ),
    );
  });
}
