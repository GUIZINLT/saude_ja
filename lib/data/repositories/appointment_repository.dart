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

  /// Agenda uma consulta. Lança ApiException (409 se o horário foi ocupado).
  Future<Appointment> create({
    required String doctorId,
    required String date,
    required String time,
  }) => _api.createAppointment(doctorId: doctorId, date: date, time: time);

  /// Cancela uma consulta confirmada e devolve a versão atualizada.
  Future<Appointment> cancel(String id) => _api.cancelAppointment(id);

  /// Troca data e horário de uma consulta confirmada.
  Future<Appointment> reschedule(
    String id, {
    required String date,
    required String time,
  }) => _api.rescheduleAppointment(id, date: date, time: time);

  /// A próxima consulta confirmada, ou null se não houver.
  Future<Appointment?> getNext() async {
    final upcoming = await getUpcoming();
    return upcoming.isEmpty ? null : upcoming.first;
  }
}
