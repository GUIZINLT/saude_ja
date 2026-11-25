import 'dart:io';

import 'package:saude_ja/data/services/mock/mock_backend.dart';
import 'package:saude_ja/data/services/mock_api_service.dart';

const _mockFiles = [
  'users.json',
  'specialties.json',
  'doctors.json',
  'schedules.json',
  'appointments.json',
];

final Map<String, String> _cache = {};

/// Lê os JSONs de assets/mock uma vez. Chame em setUpAll, fora do
/// testWidgets, porque leitura de arquivo não roda no relógio falso.
Future<void> loadMockAssets() async {
  for (final f in _mockFiles) {
    _cache[f] ??= await File('assets/mock/$f').readAsString();
  }
}

/// MockBackend com os dados de assets/mock e relógio fixo
/// (ter, 24/11/2026 07:00).
MockBackend createTestBackend() => MockBackend(
  loader: (f) async => _cache[f]!,
  clock: () => DateTime(2026, 11, 24, 7),
);

/// MockApiService sem atraso, sobre o [createTestBackend].
MockApiService createTestApi() =>
    MockApiService(latency: Duration.zero, backend: createTestBackend());
