import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:saude_ja/data/services/mock/mock_backend.dart';

// Testa o mock pelas mesmas rotas e códigos de status de docs/API.md.
// O relógio é fixo em ter, 24/11/2026 07:00 para os resultados não mudarem.
void main() {
  late MockBackend api;

  setUp(() {
    api = MockBackend(
      loader: (file) => File('assets/mock/$file').readAsString(),
      clock: () => DateTime(2026, 11, 24, 7, 0),
    );
  });

  Future<String> loginToken() async {
    final res = await api.handle(
      'POST',
      '/auth/login',
      body: {'email': 'maria@saudeja.com', 'password': '123456'},
    );
    return 'Bearer ${(res.body as Map)['token']}';
  }

  Map error(MockResponse res) => (res.body as Map)['error'] as Map;

  group('auth', () {
    test('login válido devolve token e usuário sem senha', () async {
      final res = await api.handle(
        'POST',
        '/auth/login',
        body: {'email': 'MARIA@saudeja.com', 'password': '123456'},
      );
      expect(res.statusCode, 200);
      final body = res.body as Map;
      expect(body['token'], isNotEmpty);
      expect((body['user'] as Map)['name'], 'Maria Souza');
      expect((body['user'] as Map).containsKey('password'), isFalse);
    });

    test('senha errada -> 401', () async {
      final res = await api.handle(
        'POST',
        '/auth/login',
        body: {'email': 'maria@saudeja.com', 'password': 'errada'},
      );
      expect(res.statusCode, 401);
      expect(error(res)['code'], 'INVALID_CREDENTIALS');
    });

    test('campos vazios -> 422 com fields', () async {
      final res = await api.handle('POST', '/auth/login', body: {});
      expect(res.statusCode, 422);
      expect(
        (error(res)['fields'] as Map).keys,
        containsAll(['email', 'password']),
      );
    });

    test('cadastro cria conta e já loga', () async {
      final res = await api.handle(
        'POST',
        '/auth/register',
        body: {
          'name': 'João Silva',
          'email': 'joao@email.com',
          'phone': '(63) 98888-7777',
          'password': 'segredo1',
          'acceptedTerms': true,
        },
      );
      expect(res.statusCode, 201);
      final user = (res.body as Map)['user'] as Map;
      expect(user['id'], 'u2');
      expect(user['phone'], '63988887777');

      final login = await api.handle(
        'POST',
        '/auth/login',
        body: {'email': 'joao@email.com', 'password': 'segredo1'},
      );
      expect(login.statusCode, 200);
    });

    test('cadastro com e-mail existente -> 409', () async {
      final res = await api.handle(
        'POST',
        '/auth/register',
        body: {
          'name': 'Outra Maria',
          'email': 'maria@saudeja.com',
          'phone': '63999990000',
          'password': '123456',
          'acceptedTerms': true,
        },
      );
      expect(res.statusCode, 409);
      expect(error(res)['code'], 'EMAIL_ALREADY_IN_USE');
    });

    test('cadastro inválido -> 422 com todos os campos', () async {
      final res = await api.handle(
        'POST',
        '/auth/register',
        body: {
          'name': 'Jo',
          'email': 'sem-arroba',
          'phone': '123',
          'password': '1',
          'acceptedTerms': false,
        },
      );
      expect(res.statusCode, 422);
      expect(
        (error(res)['fields'] as Map).keys,
        containsAll(['name', 'email', 'phone', 'password', 'acceptedTerms']),
      );
    });
  });

  group('especialidades e médicos', () {
    test('lista as 6 especialidades com contagem de médicos', () async {
      final res = await api.handle('GET', '/specialties');
      final list = res.body as List;
      expect(list, hasLength(6));
      expect(list.first['doctorCount'], 2); // Cardiologia
    });

    test('filtros de médicos', () async {
      final featured = await api.handle('GET', '/doctors?featured=true');
      expect((featured.body as List).map((d) => d['name']), [
        'Dra. Helena Ribeiro',
        'Dr. Carlos Mendes',
      ]);

      final bySpecialty = await api.handle(
        'GET',
        '/doctors',
        query: {'specialtyId': 'cardiologia'},
      );
      expect(bySpecialty.body as List, hasLength(2));

      // Busca sem acento e sem diferenciar maiúsculas.
      final search = await api.handle(
        'GET',
        '/doctors',
        query: {'q': 'HELENA'},
      );
      expect((search.body as List).single['specialtyName'], 'Cardiologia');
    });

    test('médico inexistente -> 404', () async {
      final res = await api.handle('GET', '/doctors/d999');
      expect(res.statusCode, 404);
      expect(error(res)['code'], 'DOCTOR_NOT_FOUND');
    });

    test('disponibilidade segue a agenda do médico', () async {
      final res = await api.handle(
        'GET',
        '/doctors/d1/availability',
        query: {'from': '2026-11-24', 'days': '5'},
      );
      expect(res.statusCode, 200);
      final days = (res.body as Map)['days'] as List;
      // Seg a sex: pula sábado e domingo, como no protótipo.
      expect(days.map((d) => d['date']), [
        '2026-11-24',
        '2026-11-25',
        '2026-11-26',
        '2026-11-27',
        '2026-11-30',
      ]);

      bool available(String date, String time) =>
          ((days.firstWhere((d) => d['date'] == date)['slots'] as List)
                  .firstWhere((s) => s['time'] == time))['available']
              as bool;

      expect(available('2026-11-24', '08:30'), isFalse); // bloqueado
      expect(available('2026-11-26', '09:30'), isFalse); // consulta a1
      expect(available('2026-11-26', '10:00'), isTrue);
    });

    test('parâmetro inválido -> 400', () async {
      final res = await api.handle(
        'GET',
        '/doctors/d1/availability',
        query: {'days': '99'},
      );
      expect(res.statusCode, 400);
    });
  });

  group('consultas', () {
    test('sem login -> 401', () async {
      final res = await api.handle('GET', '/appointments');
      expect(res.statusCode, 401);
    });

    test('agendar ocupa o horário e não deixa repetir', () async {
      final auth = await loginToken();
      final body = {'doctorId': 'd1', 'date': '2026-11-27', 'time': '10:00'};

      final created = await api.handle(
        'POST',
        '/appointments',
        body: body,
        authorization: auth,
      );
      expect(created.statusCode, 201);
      expect((created.body as Map)['status'], 'confirmed');
      expect((created.body as Map)['doctorName'], 'Dra. Helena Ribeiro');

      final again = await api.handle(
        'POST',
        '/appointments',
        body: body,
        authorization: auth,
      );
      expect(again.statusCode, 409);
      expect(error(again)['code'], 'SLOT_UNAVAILABLE');
    });

    test('horário fora da agenda -> 409, data passada -> 422', () async {
      final auth = await loginToken();
      final outside = await api.handle(
        'POST',
        '/appointments',
        body: {'doctorId': 'd1', 'date': '2026-11-28', 'time': '09:00'},
        authorization: auth,
      ); // sábado
      expect(outside.statusCode, 409);

      final past = await api.handle(
        'POST',
        '/appointments',
        body: {'doctorId': 'd1', 'date': '2026-11-20', 'time': '09:00'},
        authorization: auth,
      );
      expect(past.statusCode, 422);
      expect(error(past)['code'], 'DATE_IN_PAST');
    });

    test('lista e filtra por status', () async {
      final auth = await loginToken();
      final all = await api.handle('GET', '/appointments', authorization: auth);
      expect((all.body as List).map((a) => a['id']), ['a2', 'a3', 'a1']);

      final history = await api.handle(
        'GET',
        '/appointments',
        query: {'status': 'completed,cancelled', 'order': 'desc'},
        authorization: auth,
      );
      expect((history.body as List).map((a) => a['id']), ['a3', 'a2']);
    });

    test('cancelar libera o horário; não cancela duas vezes', () async {
      final auth = await loginToken();
      final res = await api.handle(
        'PATCH',
        '/appointments/a1/cancel',
        authorization: auth,
      );
      expect(res.statusCode, 200);
      expect((res.body as Map)['status'], 'cancelled');
      expect((res.body as Map)['cancelledAt'], isNotNull);

      final again = await api.handle(
        'PATCH',
        '/appointments/a1/cancel',
        authorization: auth,
      );
      expect(again.statusCode, 409);

      final completed = await api.handle(
        'PATCH',
        '/appointments/a2/cancel',
        authorization: auth,
      );
      expect(error(completed)['code'], 'APPOINTMENT_COMPLETED');

      final slots = await api.handle(
        'GET',
        '/doctors/d1/availability',
        query: {'from': '2026-11-26', 'days': '1'},
      );
      final day = ((slots.body as Map)['days'] as List).single as Map;
      expect(
        (day['slots'] as List).firstWhere(
          (s) => s['time'] == '09:30',
        )['available'],
        isTrue,
      );
    });

    test('rota desconhecida -> 404', () async {
      final res = await api.handle('DELETE', '/appointments/a1');
      expect(res.statusCode, 404);
      expect(error(res)['code'], 'ROUTE_NOT_FOUND');
    });
  });
}
