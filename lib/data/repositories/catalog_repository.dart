import '../models/doctor.dart';
import '../models/specialty.dart';
import '../services/api_service.dart';

/// Especialidades e médicos (dados públicos, sem login).
class CatalogRepository {
  CatalogRepository(this._api);

  final ApiService _api;

  List<Specialty>? _specialtiesCache;

  /// As especialidades quase não mudam, então ficam em cache na memória.
  Future<List<Specialty>> getSpecialties({bool forceRefresh = false}) async {
    if (!forceRefresh && _specialtiesCache != null) return _specialtiesCache!;
    return _specialtiesCache = await _api.getSpecialties();
  }

  Future<List<Doctor>> getFeaturedDoctors() => _api.getDoctors(featured: true);

  Future<List<Doctor>> searchDoctors(String query) =>
      _api.getDoctors(query: query);

  Future<List<Doctor>> getDoctorsBySpecialty(String specialtyId) =>
      _api.getDoctors(specialtyId: specialtyId);
}
