import 'package:flutter/foundation.dart';

import '../models/appointment.dart';
import '../models/auth_session.dart';
import '../models/availability.dart';
import '../models/doctor.dart';
import '../models/register_request.dart';
import '../models/specialty.dart';
import '../models/user.dart';
import 'api_service.dart';

/// Base comum das implementações de [ApiService] que falam o JSON de
/// docs/API.md.
///
/// Aqui ficam as rotas, os parâmetros, o token e a conversão das respostas
/// nos models. Cada implementação só diz como a requisição é enviada
/// ([send]): o [MockApiService] entrega ao backend simulado na memória, o
/// [HttpApiService] manda pela rede.
abstract class JsonApiService implements ApiService {
  String? _token;

  /// Valor do header Authorization, ou null sem login.
  @protected
  String? get authorization => _token == null ? null : 'Bearer $_token';

  /// Envia uma requisição e devolve o corpo JSON da resposta (Map, List ou
  /// null). Lança ApiException quando a resposta é de erro.
  @protected
  Future<Object?> send(
    String method,
    String path, {
    Map<String, String> query = const {},
    Map<String, dynamic>? body,
  });

  Map<String, dynamic> _object(Object? body) => body! as Map<String, dynamic>;

  List<Map<String, dynamic>> _list(Object? body) =>
      (body! as List).cast<Map<String, dynamic>>();

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final body = await send(
      'POST',
      '/auth/login',
      body: {'email': email, 'password': password},
    );
    final session = AuthSession.fromJson(_object(body));
    _token = session.token;
    return session;
  }

  @override
  Future<AuthSession> register(RegisterRequest request) async {
    final body = await send('POST', '/auth/register', body: request.toJson());
    final session = AuthSession.fromJson(_object(body));
    _token = session.token;
    return session;
  }

  @override
  Future<User> restoreSession(String token) async {
    _token = token;
    try {
      final body = await send('GET', '/users/me');
      return User.fromJson(_object(body));
    } catch (_) {
      _token = null;
      rethrow;
    }
  }

  @override
  void logout() => _token = null;

  @override
  Future<List<Specialty>> getSpecialties() async {
    final body = await send('GET', '/specialties');
    return _list(body).map(Specialty.fromJson).toList();
  }

  @override
  Future<List<Doctor>> getDoctors({
    String? specialtyId,
    String? query,
    bool? featured,
  }) async {
    final body = await send(
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
    final body = await send('GET', '/doctors/$id');
    return Doctor.fromJson(_object(body));
  }

  @override
  Future<DoctorAvailability> getAvailability(
    String doctorId, {
    DateTime? from,
    int days = 5,
  }) async {
    final body = await send(
      'GET',
      '/doctors/$doctorId/availability',
      query: {if (from != null) 'from': _formatDate(from), 'days': '$days'},
    );
    return DoctorAvailability.fromJson(_object(body));
  }

  @override
  Future<Appointment> createAppointment({
    required String doctorId,
    required String date,
    required String time,
    String? notes,
  }) async {
    final body = await send(
      'POST',
      '/appointments',
      body: {'doctorId': doctorId, 'date': date, 'time': time, 'notes': ?notes},
    );
    return Appointment.fromJson(_object(body));
  }

  @override
  Future<List<Appointment>> getAppointments({
    List<AppointmentStatus>? status,
    bool newestFirst = false,
  }) async {
    final body = await send(
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
    final body = await send('PATCH', '/appointments/$id/cancel');
    return Appointment.fromJson(_object(body));
  }

  @override
  Future<Appointment> rescheduleAppointment(
    String id, {
    required String date,
    required String time,
  }) async {
    final body = await send(
      'PATCH',
      '/appointments/$id/reschedule',
      body: {'date': date, 'time': time},
    );
    return Appointment.fromJson(_object(body));
  }

  static String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
