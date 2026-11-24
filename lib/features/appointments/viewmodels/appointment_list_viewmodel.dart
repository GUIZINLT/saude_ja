import 'package:flutter/foundation.dart';

import '../../../data/models/appointment.dart';
import '../../../data/repositories/appointment_repository.dart';
import '../../../data/services/api_exception.dart';

enum AppointmentListStatus { loading, ready, error }

/// Base das abas Consultas e Histórico: carrega uma lista de consultas e
/// controla carregando, erro e lista vazia.
abstract class AppointmentListViewModel extends ChangeNotifier {
  AppointmentListViewModel(this.repository);

  final AppointmentRepository repository;

  AppointmentListStatus _status = AppointmentListStatus.loading;
  String? _errorMessage;
  List<Appointment> _items = const [];
  bool _disposed = false;

  AppointmentListStatus get status => _status;
  String? get errorMessage => _errorMessage;
  List<Appointment> get items => _items;
  bool get isEmpty => _items.isEmpty;

  /// Qual lista buscar (próximas ou histórico).
  @protected
  Future<List<Appointment>> fetch();

  /// Carrega a lista. Se já houver dados, atualiza sem mostrar o
  /// carregando de novo (usado ao voltar para a aba).
  Future<void> load() async {
    if (_status != AppointmentListStatus.ready) {
      _status = AppointmentListStatus.loading;
      _errorMessage = null;
      notify();
    }
    try {
      _items = await fetch();
      _status = AppointmentListStatus.ready;
      _errorMessage = null;
    } on ApiException catch (e) {
      _status = AppointmentListStatus.error;
      _errorMessage = e.message;
    } catch (_) {
      _status = AppointmentListStatus.error;
      _errorMessage = 'Não foi possível carregar as consultas.';
    }
    notify();
  }

  @protected
  set items(List<Appointment> value) => _items = value;

  @protected
  void notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// Aba Consultas: consultas confirmadas, da mais próxima para a mais
/// distante, com opção de cancelar.
class UpcomingAppointmentsViewModel extends AppointmentListViewModel {
  UpcomingAppointmentsViewModel(super.repository);

  String? _cancellingId;

  /// Id da consulta sendo cancelada (para mostrar o carregando no card).
  String? get cancellingId => _cancellingId;

  @override
  Future<List<Appointment>> fetch() => repository.getUpcoming();

  /// Cancela e tira a consulta da lista. Devolve a mensagem de erro, ou
  /// null se deu certo.
  Future<String?> cancel(Appointment appointment) async {
    if (_cancellingId != null) return null;
    _cancellingId = appointment.id;
    notify();
    try {
      await repository.cancel(appointment.id);
      items = items.where((a) => a.id != appointment.id).toList();
      return null;
    } on ApiException catch (e) {
      // A consulta pode ter mudado (ex.: já realizada): recarrega a lista.
      await load();
      return e.message;
    } catch (_) {
      return 'Não foi possível cancelar. Tente novamente.';
    } finally {
      _cancellingId = null;
      notify();
    }
  }
}

/// Aba Histórico: realizadas e canceladas, da mais recente para a mais
/// antiga.
class AppointmentHistoryViewModel extends AppointmentListViewModel {
  AppointmentHistoryViewModel(super.repository);

  @override
  Future<List<Appointment>> fetch() => repository.getHistory();
}
