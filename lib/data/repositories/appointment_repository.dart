import '../models/appointment.dart';
import '../services/api_service.dart';

/// Consultas do paciente logado.
class AppointmentRepository {
  AppointmentRepository(this._api);

  final ApiService _api;

  /// Consultas confirmadas, da mais próxima para a mais distante.
  Future<List<Appointment>> getUpcoming() =>
      _api.getAppointments(status: [AppointmentStatus.confirmed]);

  /// Realizadas e canceladas, da mais recente para a mais antiga.
  Future<List<Appointment>> getHistory() => _api.getAppointments(
    status: [AppointmentStatus.completed, AppointmentStatus.cancelled],
    newestFirst: true,
  );

  /// A próxima consulta confirmada, ou null se não houver.
  Future<Appointment?> getNext() async {
    final upcoming = await getUpcoming();
    return upcoming.isEmpty ? null : upcoming.first;
  }
}
