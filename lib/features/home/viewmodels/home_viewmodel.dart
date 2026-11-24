import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/models/appointment.dart';
import '../../../data/models/doctor.dart';
import '../../../data/models/specialty.dart';
import '../../../data/repositories/appointment_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/catalog_repository.dart';
import '../../../data/services/api_exception.dart';

enum HomeStatus { loading, ready, error }

/// Estado da Home: saudação, especialidades, próxima consulta, médicos em
/// destaque e a busca.
class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required this._auth,
    required this._catalog,
    required this._appointments,
    this.searchDelay = const Duration(milliseconds: 400),
  });

  final AuthRepository _auth;
  final CatalogRepository _catalog;
  final AppointmentRepository _appointments;

  /// Espera o usuário parar de digitar antes de buscar.
  final Duration searchDelay;

  HomeStatus _status = HomeStatus.loading;
  String? _errorMessage;
  List<Specialty> _specialties = const [];
  List<Doctor> _featuredDoctors = const [];
  Appointment? _nextAppointment;

  String _query = '';
  bool _isSearchLoading = false;
  String? _searchError;
  List<Doctor> _searchResults = const [];
  Timer? _searchTimer;
  int _searchId = 0;
  bool _disposed = false;

  HomeStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String get firstName => _auth.currentUser?.firstName ?? 'paciente';

  /// Especialidades mostradas na Home.
  List<Specialty> get specialties => _specialties;
  List<Doctor> get featuredDoctors => _featuredDoctors;
  Appointment? get nextAppointment => _nextAppointment;

  String get query => _query;
  bool get isSearching => _query.trim().isNotEmpty;
  bool get isSearchLoading => _isSearchLoading;
  String? get searchError => _searchError;
  List<Doctor> get searchResults => _searchResults;

  /// Carrega as três seções ao mesmo tempo. Também usado no "puxar para
  /// atualizar" e no botão "Tentar novamente".
  Future<void> load() async {
    if (_status != HomeStatus.ready) {
      _status = HomeStatus.loading;
      _errorMessage = null;
      _notify();
    }
    try {
      final results = await Future.wait([
        _catalog.getSpecialties(),
        _catalog.getFeaturedDoctors(),
        _appointments.getNext(),
      ]);
      _specialties = results[0] as List<Specialty>;
      _featuredDoctors = results[1] as List<Doctor>;
      _nextAppointment = results[2] as Appointment?;
      _status = HomeStatus.ready;
      _errorMessage = null;
    } on ApiException catch (e) {
      _status = HomeStatus.error;
      _errorMessage = e.message;
    } catch (_) {
      _status = HomeStatus.error;
      _errorMessage = 'Não foi possível carregar a tela. Tente novamente.';
    }
    _notify();
  }

  /// Chamado a cada letra digitada na busca.
  void setQuery(String value) {
    _query = value;
    _searchTimer?.cancel();
    if (!isSearching) {
      _clearSearchResults();
      return;
    }
    _isSearchLoading = true;
    _searchError = null;
    _notify();
    _searchTimer = Timer(searchDelay, () => search(value));
  }

  /// Busca médicos pelo nome ou pela especialidade.
  Future<void> search(String value) =>
      _runSearch(value, () => _catalog.searchDoctors(value.trim()));

  /// Toque num card de especialidade: lista os médicos dela.
  Future<void> selectSpecialty(Specialty specialty) {
    _searchTimer?.cancel();
    _query = specialty.name;
    return _runSearch(
      specialty.name,
      () => _catalog.getDoctorsBySpecialty(specialty.id),
    );
  }

  void clearSearch() {
    _searchTimer?.cancel();
    _query = '';
    _clearSearchResults();
  }

  Future<void> _runSearch(
    String value,
    Future<List<Doctor>> Function() fetch,
  ) async {
    final id = ++_searchId;
    _isSearchLoading = true;
    _searchError = null;
    _notify();
    try {
      final doctors = await fetch();
      if (id != _searchId) return; // chegou uma busca mais nova
      _searchResults = doctors;
    } on ApiException catch (e) {
      if (id != _searchId) return;
      _searchResults = const [];
      _searchError = e.message;
    } catch (_) {
      if (id != _searchId) return;
      _searchResults = const [];
      _searchError = 'Não foi possível buscar. Tente novamente.';
    }
    _isSearchLoading = false;
    _notify();
  }

  void _clearSearchResults() {
    _searchId++;
    _searchResults = const [];
    _searchError = null;
    _isSearchLoading = false;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _searchTimer?.cancel();
    super.dispose();
  }
}
