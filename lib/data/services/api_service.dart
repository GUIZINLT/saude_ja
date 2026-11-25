import '../models/appointment.dart';
import '../models/auth_session.dart';
import '../models/availability.dart';
import '../models/doctor.dart';
import '../models/register_request.dart';
import '../models/specialty.dart';
import '../models/user.dart';

/// Contrato da API do SaúdeJá (ver docs/API.md).
///
/// Os repositórios dependem desta interface, nunca de uma implementação.
/// Hoje quem implementa é o [MockApiService]; quando existir backend real,
/// basta criar um `HttpApiService` com os mesmos métodos e trocar na
/// injeção de dependência (main.dart / Provider).
///
/// Todos os métodos lançam [ApiException] quando a API responde com erro.
abstract interface class ApiService {
  /// POST /auth/login. Guarda o token para as próximas chamadas.
  Future<AuthSession> login({required String email, required String password});

  /// POST /auth/register. Já devolve a sessão (usuário entra logado).
  Future<AuthSession> register(RegisterRequest request);

  /// Usa um token salvo antes (ao reabrir o app) e confere com
  /// GET /users/me. Se o token não valer mais, descarta e lança
  /// ApiException (401).
  Future<User> restoreSession(String token);

  /// Descarta o token guardado (sem chamada à API).
  void logout();

  /// GET /specialties
  Future<List<Specialty>> getSpecialties();

  /// GET /doctors
  Future<List<Doctor>> getDoctors({
    String? specialtyId,
    String? query,
    bool? featured,
  });

  /// GET /doctors/{id}
  Future<Doctor> getDoctor(String id);

  /// GET /doctors/{id}/availability
  Future<DoctorAvailability> getAvailability(
    String doctorId, {
    DateTime? from,
    int days = 5,
  });

  /// POST /appointments (requer login)
  Future<Appointment> createAppointment({
    required String doctorId,
    required String date,
    required String time,
    String? notes,
  });

  /// GET /appointments (requer login)
  Future<List<Appointment>> getAppointments({
    List<AppointmentStatus>? status,
    bool newestFirst = false,
  });

  /// PATCH /appointments/{id}/cancel (requer login)
  Future<Appointment> cancelAppointment(String id);
}
