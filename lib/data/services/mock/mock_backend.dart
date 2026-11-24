import 'dart:convert';

/// Lê um arquivo de `assets/mock/` pelo nome (ex.: `doctors.json`).
typedef MockAssetLoader = Future<String> Function(String fileName);

/// Resposta simulada: código HTTP + corpo JSON (Map, List ou null).
class MockResponse {
  final int statusCode;
  final Object? body;

  const MockResponse(this.statusCode, [this.body]);

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}

/// Backend simulado do SaúdeJá.
///
/// Implementa as mesmas rotas, regras e códigos de status descritos em
/// `docs/API.md`. É Dart puro (sem Flutter), então é usado tanto pelo
/// `MockApiService` dentro do app quanto pelo servidor HTTP em
/// `tool/mock_server.dart`.
///
/// Os dados vêm dos JSONs de `assets/mock/` e ficam em memória: agendar e
/// cancelar funcionam, mas tudo volta ao estado inicial ao reiniciar.
class MockBackend {
  MockBackend({required this._loader, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final MockAssetLoader _loader;
  final DateTime Function() _clock;

  Future<void>? _loading;
  late final List<Map<String, dynamic>> _users;
  late final List<Map<String, dynamic>> _specialties;
  late final List<Map<String, dynamic>> _doctors;
  late final List<Map<String, dynamic>> _schedules;
  late final List<Map<String, dynamic>> _appointments;

  /// token -> userId
  final Map<String, String> _tokens = {};
  int _tokenSeq = 0;

  static final _dateRe = RegExp(r'^\d{4}-\d{2}-\d{2}$');
  static final _timeRe = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');
  static final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  Future<void> _ensureLoaded() => _loading ??= _load();

  Future<void> _load() async {
    Future<List<Map<String, dynamic>>> read(String name) async {
      final raw = jsonDecode(await _loader(name)) as List<dynamic>;
      return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }

    _users = await read('users.json');
    _specialties = await read('specialties.json');
    _doctors = await read('doctors.json');
    _schedules = await read('schedules.json');
    _appointments = await read('appointments.json');
  }

  /// Ponto de entrada único, no formato de uma requisição HTTP.
  ///
  /// [path] pode conter query string (`/doctors?featured=true`); valores em
  /// [query] têm prioridade. [authorization] é o valor do header
  /// `Authorization` (`Bearer <token>`).
  Future<MockResponse> handle(
    String method,
    String path, {
    Map<String, String> query = const {},
    Object? body,
    String? authorization,
  }) async {
    await _ensureLoaded();
    _refreshStatuses();

    final uri = Uri.parse(path);
    final q = {...uri.queryParameters, ...query};
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    final m = method.toUpperCase();

    try {
      switch (segments) {
        case ['auth', 'login'] when m == 'POST':
          return _login(_bodyMap(body));
        case ['auth', 'register'] when m == 'POST':
          return _register(_bodyMap(body));
        case ['specialties'] when m == 'GET':
          return _listSpecialties();
        case ['doctors'] when m == 'GET':
          return _listDoctors(q);
        case ['doctors', final id] when m == 'GET':
          return _getDoctor(id);
        case ['doctors', final id, 'availability'] when m == 'GET':
          return _availability(id, q);
        case ['appointments'] when m == 'GET':
          return _listAppointments(_auth(authorization), q);
        case ['appointments'] when m == 'POST':
          return _createAppointment(_auth(authorization), _bodyMap(body));
        case ['appointments', final id, 'cancel'] when m == 'PATCH':
          return _cancelAppointment(_auth(authorization), id);
      }
      throw _HttpError(
        404,
        'ROUTE_NOT_FOUND',
        'Rota não encontrada: $m ${uri.path}',
      );
    } on _HttpError catch (e) {
      return MockResponse(e.status, {
        'error': {
          'code': e.code,
          'message': e.message,
          if (e.fields != null) 'fields': e.fields,
        },
      });
    }
  }

  // ---------------------------------------------------------------- auth

  MockResponse _login(Map<String, dynamic> body) {
    final email = _str(body['email']).toLowerCase();
    final password = _str(body['password']);

    final fields = <String, String>{
      if (email.isEmpty) 'email': 'Informe o e-mail.',
      if (password.isEmpty) 'password': 'Informe a senha.',
    };
    if (fields.isNotEmpty) throw _validation(fields);

    final user = _users
        .where((u) => u['email'] == email && u['password'] == password)
        .firstOrNull;
    if (user == null) {
      throw _HttpError(
        401,
        'INVALID_CREDENTIALS',
        'E-mail ou senha incorretos.',
      );
    }
    return MockResponse(200, _session(user));
  }

  MockResponse _register(Map<String, dynamic> body) {
    final name = _str(body['name']);
    final email = _str(body['email']).toLowerCase();
    final phone = _str(body['phone']).replaceAll(RegExp(r'\D'), '');
    final password = _str(body['password']);
    final acceptedTerms = body['acceptedTerms'] == true;

    final fields = <String, String>{
      if (name.length < 3) 'name': 'Informe o nome completo.',
      if (!_emailRe.hasMatch(email)) 'email': 'E-mail inválido.',
      if (phone.length < 10 || phone.length > 11)
        'phone': 'Telefone deve ter DDD + número (10 ou 11 dígitos).',
      if (password.length < 6)
        'password': 'A senha deve ter pelo menos 6 caracteres.',
      if (!acceptedTerms)
        'acceptedTerms': 'É preciso aceitar os termos de uso.',
    };
    if (fields.isNotEmpty) throw _validation(fields);

    if (_users.any((u) => u['email'] == email)) {
      throw _HttpError(
        409,
        'EMAIL_ALREADY_IN_USE',
        'Já existe uma conta com este e-mail.',
      );
    }

    final user = <String, dynamic>{
      'id': _nextId('u', _users),
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'createdAt': _clock().toIso8601String(),
    };
    _users.add(user);
    return MockResponse(201, _session(user));
  }

  Map<String, dynamic> _session(Map<String, dynamic> user) {
    final token = 'mock-${user['id']}-${++_tokenSeq}';
    _tokens[token] = user['id'] as String;
    return {'token': token, 'user': _publicUser(user)};
  }

  String _auth(String? authorization) {
    const prefix = 'Bearer ';
    final token = (authorization != null && authorization.startsWith(prefix))
        ? authorization.substring(prefix.length).trim()
        : null;
    final userId = token == null ? null : _tokens[token];
    if (userId == null) {
      throw _HttpError(401, 'UNAUTHORIZED', 'Faça login para continuar.');
    }
    return userId;
  }

  // ------------------------------------------------- especialidades/médicos

  MockResponse _listSpecialties() {
    final list = _specialties
        .map(
          (s) => {
            ...s,
            'doctorCount': _doctors
                .where((d) => d['specialtyId'] == s['id'])
                .length,
          },
        )
        .toList();
    return MockResponse(200, list);
  }

  MockResponse _listDoctors(Map<String, String> q) {
    final specialtyId = q['specialtyId'];
    final search = _normalize(q['q'] ?? '');
    final featured = q['featured'];

    if (featured != null && featured != 'true' && featured != 'false') {
      throw _HttpError(
        400,
        'INVALID_PARAMETER',
        'featured deve ser true ou false.',
      );
    }

    final list = _doctors
        .where((d) {
          if (specialtyId != null && d['specialtyId'] != specialtyId) {
            return false;
          }
          if (featured != null && d['featured'] != (featured == 'true')) {
            return false;
          }
          if (search.isNotEmpty) {
            final haystack = _normalize(
              '${d['name']} ${_specialtyName(d['specialtyId'])}',
            );
            if (!haystack.contains(search)) return false;
          }
          return true;
        })
        .map(_publicDoctor)
        .toList();

    return MockResponse(200, list);
  }

  MockResponse _getDoctor(String id) =>
      MockResponse(200, _publicDoctor(_findDoctor(id)));

  MockResponse _availability(String doctorId, Map<String, String> q) {
    _findDoctor(doctorId);
    final schedule = _scheduleOf(doctorId);
    final now = _clock();

    final DateTime from;
    if (q['from'] == null) {
      from = DateTime(now.year, now.month, now.day);
    } else {
      final parsed = _parseDate(q['from']!);
      if (parsed == null) {
        throw _HttpError(
          400,
          'INVALID_PARAMETER',
          'from deve estar no formato AAAA-MM-DD.',
        );
      }
      from = parsed;
    }

    final days = int.tryParse(q['days'] ?? '5');
    if (days == null || days < 1 || days > 14) {
      throw _HttpError(
        400,
        'INVALID_PARAMETER',
        'days deve ser um número entre 1 e 14.',
      );
    }

    final weekdays = (schedule['weekdays'] as List).cast<int>();
    final result = <Map<String, dynamic>>[];
    // Percorre no máximo 60 dias corridos procurando dias de atendimento.
    for (var i = 0; i < 60 && result.length < days; i++) {
      final day = DateTime(from.year, from.month, from.day + i);
      if (!weekdays.contains(day.weekday)) continue;
      final date = _formatDate(day);
      final slots = (schedule['slots'] as List)
          .cast<String>()
          .map(
            (time) => {
              'time': time,
              'available': _isSlotFree(doctorId, date, time, now),
            },
          )
          .toList();
      result.add({'date': date, 'slots': slots});
    }

    return MockResponse(200, {'doctorId': doctorId, 'days': result});
  }

  // ------------------------------------------------------------ consultas

  MockResponse _listAppointments(String userId, Map<String, String> q) {
    final statuses = q['status']
        ?.split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toSet();
    const valid = {'confirmed', 'completed', 'cancelled'};
    if (statuses != null && !statuses.every(valid.contains)) {
      throw _HttpError(
        400,
        'INVALID_PARAMETER',
        'status aceita: confirmed, completed, cancelled.',
      );
    }
    final order = q['order'] ?? 'asc';
    if (order != 'asc' && order != 'desc') {
      throw _HttpError(400, 'INVALID_PARAMETER', 'order deve ser asc ou desc.');
    }

    final list =
        _appointments
            .where((a) => a['userId'] == userId)
            .where((a) => statuses == null || statuses.contains(a['status']))
            .toList()
          ..sort((a, b) {
            final c = '${a['date']} ${a['time']}'.compareTo(
              '${b['date']} ${b['time']}',
            );
            return order == 'asc' ? c : -c;
          });

    return MockResponse(200, list.map(_publicAppointment).toList());
  }

  MockResponse _createAppointment(String userId, Map<String, dynamic> body) {
    final doctorId = _str(body['doctorId']);
    final date = _str(body['date']);
    final time = _str(body['time']);
    final notes =
        body['notes'] is String && (body['notes'] as String).trim().isNotEmpty
        ? (body['notes'] as String).trim()
        : null;

    final fields = <String, String>{
      if (doctorId.isEmpty) 'doctorId': 'Informe o médico.',
      if (_parseDate(date) == null)
        'date': 'Data deve estar no formato AAAA-MM-DD.',
      if (!_timeRe.hasMatch(time))
        'time': 'Horário deve estar no formato HH:mm.',
    };
    if (fields.isNotEmpty) throw _validation(fields);

    _findDoctor(doctorId);
    final now = _clock();

    if (_toDateTime(date, time).isBefore(now)) {
      throw _HttpError(
        422,
        'DATE_IN_PAST',
        'Não é possível agendar em uma data ou horário que já passou.',
      );
    }
    if (!_isSlotFree(doctorId, date, time, now)) {
      throw _HttpError(
        409,
        'SLOT_UNAVAILABLE',
        'Este horário não está disponível. Escolha outro.',
      );
    }
    final clash = _appointments.any(
      (a) =>
          a['userId'] == userId &&
          a['status'] == 'confirmed' &&
          a['date'] == date &&
          a['time'] == time,
    );
    if (clash) {
      throw _HttpError(
        409,
        'PATIENT_TIME_CONFLICT',
        'Você já tem uma consulta neste dia e horário.',
      );
    }

    final appointment = <String, dynamic>{
      'id': _nextId('a', _appointments),
      'userId': userId,
      'doctorId': doctorId,
      'date': date,
      'time': time,
      'status': 'confirmed',
      'notes': notes,
      'createdAt': now.toIso8601String(),
      'cancelledAt': null,
    };
    _appointments.add(appointment);
    return MockResponse(201, _publicAppointment(appointment));
  }

  MockResponse _cancelAppointment(String userId, String id) {
    final appointment = _appointments
        .where((a) => a['id'] == id && a['userId'] == userId)
        .firstOrNull;
    if (appointment == null) {
      throw _HttpError(
        404,
        'APPOINTMENT_NOT_FOUND',
        'Consulta não encontrada.',
      );
    }
    switch (appointment['status']) {
      case 'cancelled':
        throw _HttpError(
          409,
          'APPOINTMENT_ALREADY_CANCELLED',
          'Esta consulta já foi cancelada.',
        );
      case 'completed':
        throw _HttpError(
          409,
          'APPOINTMENT_COMPLETED',
          'Não é possível cancelar uma consulta já realizada.',
        );
    }
    appointment['status'] = 'cancelled';
    appointment['cancelledAt'] = _clock().toIso8601String();
    return MockResponse(200, _publicAppointment(appointment));
  }

  // ------------------------------------------------------------ auxiliares

  /// Consultas confirmadas cujo horário já passou viram "completed".
  void _refreshStatuses() {
    final now = _clock();
    for (final a in _appointments) {
      if (a['status'] == 'confirmed' &&
          _toDateTime(a['date'] as String, a['time'] as String).isBefore(now)) {
        a['status'] = 'completed';
      }
    }
  }

  bool _isSlotFree(String doctorId, String date, String time, DateTime now) {
    final schedule = _scheduleOf(doctorId);
    final day = _parseDate(date);
    if (day == null) return false;
    if (!(schedule['weekdays'] as List).contains(day.weekday)) return false;
    if (!(schedule['slots'] as List).contains(time)) return false;
    if (_toDateTime(date, time).isBefore(now)) return false;
    final blocked = (schedule['blocked'] as List).cast<Map>().any(
      (b) => b['date'] == date && b['time'] == time,
    );
    if (blocked) return false;
    return !_appointments.any(
      (a) =>
          a['doctorId'] == doctorId &&
          a['status'] == 'confirmed' &&
          a['date'] == date &&
          a['time'] == time,
    );
  }

  Map<String, dynamic> _findDoctor(String id) {
    final doctor = _doctors.where((d) => d['id'] == id).firstOrNull;
    if (doctor == null) {
      throw _HttpError(404, 'DOCTOR_NOT_FOUND', 'Médico não encontrado.');
    }
    return doctor;
  }

  Map<String, dynamic> _scheduleOf(String doctorId) =>
      _schedules.where((s) => s['doctorId'] == doctorId).firstOrNull ??
      {
        'doctorId': doctorId,
        'weekdays': <int>[],
        'slots': <String>[],
        'blocked': <Map>[],
      };

  String? _specialtyName(Object? specialtyId) =>
      _specialties.where((s) => s['id'] == specialtyId).firstOrNull?['name']
          as String?;

  Map<String, dynamic> _publicUser(Map<String, dynamic> u) => {
    'id': u['id'],
    'name': u['name'],
    'email': u['email'],
    'phone': u['phone'],
    'createdAt': u['createdAt'],
  };

  Map<String, dynamic> _publicDoctor(Map<String, dynamic> d) => {
    ...d,
    'specialtyName': _specialtyName(d['specialtyId']),
  };

  Map<String, dynamic> _publicAppointment(Map<String, dynamic> a) {
    final doctor = _doctors.where((d) => d['id'] == a['doctorId']).firstOrNull;
    return {
      'id': a['id'],
      'doctorId': a['doctorId'],
      'doctorName': doctor?['name'],
      'specialtyId': doctor?['specialtyId'],
      'specialtyName': _specialtyName(doctor?['specialtyId']),
      'date': a['date'],
      'time': a['time'],
      'status': a['status'],
      'notes': a['notes'],
      'createdAt': a['createdAt'],
      'cancelledAt': a['cancelledAt'],
    };
  }

  Map<String, dynamic> _bodyMap(Object? body) {
    if (body is Map) return Map<String, dynamic>.from(body);
    throw _HttpError(
      400,
      'INVALID_BODY',
      'O corpo da requisição deve ser um objeto JSON.',
    );
  }

  _HttpError _validation(Map<String, String> fields) => _HttpError(
    422,
    'VALIDATION_ERROR',
    'Verifique os campos informados.',
    fields,
  );

  static String _str(Object? v) => v is String ? v.trim() : '';

  static String _nextId(String prefix, List<Map<String, dynamic>> items) {
    var max = 0;
    for (final item in items) {
      final n =
          int.tryParse((item['id'] as String).substring(prefix.length)) ?? 0;
      if (n > max) max = n;
    }
    return '$prefix${max + 1}';
  }

  static DateTime? _parseDate(String value) {
    if (!_dateRe.hasMatch(value)) return null;
    final p = value.split('-').map(int.parse).toList();
    final d = DateTime(p[0], p[1], p[2]);
    // Rejeita datas como 2026-02-31.
    if (d.year != p[0] || d.month != p[1] || d.day != p[2]) return null;
    return d;
  }

  static DateTime _toDateTime(String date, String time) {
    final d = _parseDate(date)!;
    final t = time.split(':').map(int.parse).toList();
    return DateTime(d.year, d.month, d.day, t[0], t[1]);
  }

  static String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Minúsculas e sem acentos, para a busca ("cardio" acha "Cardiologia").
  static String _normalize(String s) {
    const from = 'áàâãäéèêëíìîïóòôõöúùûüç';
    const to = 'aaaaaeeeeiiiiooooouuuuc';
    final lower = s.toLowerCase().trim();
    final buffer = StringBuffer();
    for (final ch in lower.split('')) {
      final i = from.indexOf(ch);
      buffer.write(i >= 0 ? to[i] : ch);
    }
    return buffer.toString();
  }
}

class _HttpError implements Exception {
  final int status;
  final String code;
  final String message;
  final Map<String, String>? fields;

  _HttpError(this.status, this.code, this.message, [this.fields]);
}
