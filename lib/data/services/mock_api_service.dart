import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/appointment.dart';
import '../models/auth_session.dart';
import '../models/availability.dart';
import '../models/doctor.dart';
import '../models/register_request.dart';
import '../models/specialty.dart';
import '../models/user.dart';
import 'api_exception.dart';
import 'api_service.dart';
import 'mock/mock_backend.dart';

/// Implementação de [ApiService] sem servidor: lê `assets/mock/*.json` e
/// simula a latência da rede com `Future.delayed`.
///
/// Cada método monta a mesma requisição que iria para o backend real
/// (método, rota, query, corpo, header Authorization) e converte a resposta
/// JSON nos models. Assim, o formato é exatamente o de docs/API.md.
class MockApiService implements ApiService {
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

  String? _token;

  bool get isLoggedIn => _token != null;

  Future<Object?> _send(
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
      authorization: _token == null ? null : 'Bearer $_token',
    );
    if (!response.isSuccess) {
      throw ApiException.fromResponse(response.statusCode, response.body);
    }
    return response.body;
  }

  List<Map<String, dynamic>> _list(Object? body) =>
      (body as List).cast<Map<String, dynamic>>();

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final body = await _send(
      'POST',
      '/auth/login',
      body: {'email': email, 'password': password},
    );
    final session = AuthSession.fromJson(body as Map<String, dynamic>);
    _token = session.token;
    return session;
  }

  @override
  Future<AuthSession> register(RegisterRequest request) async {
    final body = await _send('POST', '/auth/register', body: request.toJson());
    final session = AuthSession.fromJson(body as Map<String, dynamic>);
    _token = session.token;
    return session;
  }

  @override
  Future<User> restoreSession(String token) async {
    _token = token;
    try {
      final body = await _send('GET', '/users/me');
      return User.fromJson(body as Map<String, dynamic>);
    } catch (_) {
      _token = null;
      rethrow;
    }
  }

  @override
  void logout() => _token = null;

  @override
  Future<List<Specialty>> getSpecialties() async {
    final body = await _send('GET', '/specialties');
    return _list(body).map(Specialty.fromJson).toList();
  }

  @override
  Future<List<Doctor>> getDoctors({
    String? specialtyId,
    String? query,
    bool? featured,
  }) async {
    final body = await _send(
      'GET',
      '/doctors',
      query: {
        'specialtyId': ?specialtyId,
        if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        if (featured != null) 'featured': '$featured',
      },
    );
    return _list(body).map(Doctor.fromJson).toList();
  }

  @override
  Future<Doctor> getDoctor(String id) async {
    final body = await _send('GET', '/doctors/$id');
    return Doctor.fromJson(body as Map<String, dynamic>);
  }

  @override
  Future<DoctorAvailability> getAvailability(
    String doctorId, {
    DateTime? from,
    int days = 5,
  }) async {
    final body = await _send(
      'GET',
      '/doctors/$doctorId/availability',
      query: {if (from != null) 'from': _formatDate(from), 'days': '$days'},
    );
    return DoctorAvailability.fromJson(body as Map<String, dynamic>);
  }

  @override
  Future<Appointment> createAppointment({
    required String doctorId,
    required String date,
    required String time,
    String? notes,
  }) async {
    final body = await _send(
      'POST',
      '/appointments',
      body: {'doctorId': doctorId, 'date': date, 'time': time, 'notes': ?notes},
    );
    return Appointment.fromJson(body as Map<String, dynamic>);
  }

  @override
  Future<List<Appointment>> getAppointments({
    List<AppointmentStatus>? status,
    bool newestFirst = false,
  }) async {
    final body = await _send(
      'GET',
      '/appointments',
      query: {
        if (status != null && status.isNotEmpty)
          'status': status.map((s) => s.value).join(','),
        'order': newestFirst ? 'desc' : 'asc',
      },
    );
    return _list(body).map(Appointment.fromJson).toList();
  }

  @override
  Future<Appointment> cancelAppointment(String id) async {
    final body = await _send('PATCH', '/appointments/$id/cancel');
    return Appointment.fromJson(body as Map<String, dynamic>);
  }

  static String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
