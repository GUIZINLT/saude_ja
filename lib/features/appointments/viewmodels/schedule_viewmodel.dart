import 'package:flutter/foundation.dart';

import '../../../core/utils/date_formatter.dart';
import '../../../data/models/appointment.dart';
import '../../../data/models/availability.dart';
import '../../../data/models/doctor.dart';
import '../../../data/repositories/appointment_repository.dart';
import '../../../data/repositories/catalog_repository.dart';
import '../../../data/services/api_exception.dart';

enum ScheduleStatus { loading, ready, error }

/// Estado da tela de Agendamento: médico, dias, horários e confirmação.
class ScheduleViewModel extends ChangeNotifier {
  ScheduleViewModel({
    required this.doctorId,
    required this._catalog,
    required this._appointments,
  });

  /// Vem da navegação. É null se a tela foi aberta sem escolher um médico.
  final String? doctorId;
  final CatalogRepository _catalog;
  final AppointmentRepository _appointments;

  ScheduleStatus _status = ScheduleStatus.loading;
  String? _errorMessage;
  Doctor? _doctor;
  List<AvailableDay> _days = const [];
  String? _selectedDate;
  String? _selectedTime;
  bool _isSubmitting = false;
  String? _submitError;
  Appointment? _created;
  bool _disposed = false;

  ScheduleStatus get status => _status;
  String? get errorMessage => _errorMessage;
  Doctor? get doctor => _doctor;
  List<AvailableDay> get days => _days;
  String? get selectedDate => _selectedDate;
  String? get selectedTime => _selectedTime;
  bool get isSubmitting => _isSubmitting;

  /// Erro ao confirmar (ex.: horário ocupado), mostrado acima do botão.
  String? get submitError => _submitError;

  /// Consulta criada, para a mensagem de sucesso.
  Appointment? get createdAppointment => _created;

  AvailableDay? get selectedDay =>
      _days.where((d) => d.date == _selectedDate).firstOrNull;

  /// "Novembro 2026", ao lado de "Escolha a data".
  String get monthLabel {
    final day = selectedDay ?? _days.firstOrNull;
    return day == null ? '' : DateFormatter.monthYear(day.dateTime);
  }

  bool get hasAnyFreeSlot => _days.any((d) => d.hasFreeSlot);

  bool get canConfirm => _selectedTime != null && !_isSubmitting;

  Future<void> load() async {
    final id = doctorId;
    if (id == null) {
      _status = ScheduleStatus.error;
      _errorMessage = 'Escolha um médico na Home para agendar.';
      _notify();
      return;
    }

    _status = ScheduleStatus.loading;
    _errorMessage = null;
    _notify();
    try {
      final results = await Future.wait([
        _catalog.getDoctor(id),
        _catalog.getAvailability(id),
      ]);
      _doctor = results[0] as Doctor;
      _setDays((results[1] as DoctorAvailability).days);
      _status = ScheduleStatus.ready;
    } on ApiException catch (e) {
      _status = ScheduleStatus.error;
      _errorMessage = e.message;
    } catch (_) {
      _status = ScheduleStatus.error;
      _errorMessage = 'Não foi possível carregar os horários.';
    }
    _notify();
  }

  void selectDate(String date) {
    if (date == _selectedDate) return;
    _selectedDate = date;
    _selectedTime = null;
    _submitError = null;
    _notify();
  }

  /// Só aceita horários livres; tocar no já escolhido desmarca.
  void selectTime(String time) {
    final slot = selectedDay?.slots.where((s) => s.time == time).firstOrNull;
    if (slot == null || !slot.available) return;
    _selectedTime = _selectedTime == time ? null : time;
    _submitError = null;
    _notify();
  }

  /// Agenda e devolve true se deu certo.
  Future<bool> confirm() async {
    final date = _selectedDate;
    final time = _selectedTime;
    if (!canConfirm || date == null || time == null) return false;

    _isSubmitting = true;
    _submitError = null;
    _notify();
    try {
      _created = await _appointments.create(
        doctorId: doctorId!,
        date: date,
        time: time,
      );
      return true;
    } on ApiException catch (e) {
      _submitError = e.message;
      if (e.statusCode == 409) {
        // Alguém ocupou o horário: atualiza a grade e pede outro.
        _selectedTime = null;
        await _refreshDays();
      }
      return false;
    } catch (_) {
      _submitError = 'Não foi possível agendar. Tente novamente.';
      return false;
    } finally {
      _isSubmitting = false;
      _notify();
    }
  }

  Future<void> _refreshDays() async {
    try {
      final availability = await _catalog.getAvailability(doctorId!);
      _setDays(availability.days);
    } catch (_) {
      // Mantém a grade atual; a mensagem de erro já está na tela.
    }
  }

  /// Guarda os dias e mantém a data escolhida se ela ainda existir;
  /// senão, escolhe o primeiro dia com horário livre.
  void _setDays(List<AvailableDay> days) {
    _days = days;
    final keep = days.any((d) => d.date == _selectedDate);
    if (!keep) {
      _selectedDate =
          (days.where((d) => d.hasFreeSlot).firstOrNull ?? days.firstOrNull)
              ?.date;
      _selectedTime = null;
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
