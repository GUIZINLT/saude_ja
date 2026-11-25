import 'package:flutter/foundation.dart';

import '../../../core/utils/date_formatter.dart';
import '../../../data/models/availability.dart';
import '../../../data/models/doctor.dart';
import '../../../data/repositories/catalog_repository.dart';
import '../../../data/services/api_exception.dart';

enum DoctorDetailsStatus { loading, ready, error }

/// Estado da tela de detalhes do médico.
class DoctorDetailsViewModel extends ChangeNotifier {
  DoctorDetailsViewModel({required this.doctorId, required this._catalog});

  /// Vem da navegação. É null se a tela foi aberta sem escolher um médico.
  final String? doctorId;
  final CatalogRepository _catalog;

  DoctorDetailsStatus _status = DoctorDetailsStatus.loading;
  String? _errorMessage;
  Doctor? _doctor;
  List<AvailableDay> _days = const [];
  bool _disposed = false;

  DoctorDetailsStatus get status => _status;
  String? get errorMessage => _errorMessage;
  Doctor? get doctor => _doctor;

  /// Dias da semana em que o médico atende, na ordem: "Seg, Qua, Sex".
  String get attendanceDays {
    final weekdays = _days.map((d) => d.dateTime.weekday).toSet().toList()
      ..sort();
    return weekdays.map(DateFormatter.weekdayName).join(', ');
  }

  /// "Qua, 25 nov 2026 às 08:00", ou null se não houver horário livre nos
  /// próximos dias.
  String? get nextFreeSlot {
    for (final day in _days) {
      final slot = day.slots.where((s) => s.available).firstOrNull;
      if (slot != null) {
        return '${DateFormatter.shortDate(day.dateTime)} às ${slot.time}';
      }
    }
    return null;
  }

  Future<void> load() async {
    final id = doctorId;
    if (id == null) {
      _status = DoctorDetailsStatus.error;
      _errorMessage = 'Escolha um médico na Home.';
      _notify();
      return;
    }

    _status = DoctorDetailsStatus.loading;
    _errorMessage = null;
    _notify();
    try {
      final results = await Future.wait([
        _catalog.getDoctor(id),
        // Duas semanas de atendimento para descobrir os dias e o próximo
        // horário livre.
        _catalog.getAvailability(id, days: 10),
      ]);
      _doctor = results[0] as Doctor;
      _days = (results[1] as DoctorAvailability).days;
      _status = DoctorDetailsStatus.ready;
    } on ApiException catch (e) {
      _status = DoctorDetailsStatus.error;
      _errorMessage = e.message;
    } catch (_) {
      _status = DoctorDetailsStatus.error;
      _errorMessage = 'Não foi possível carregar o médico.';
    }
    _notify();
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
