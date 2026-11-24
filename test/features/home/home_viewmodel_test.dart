import 'package:flutter_test/flutter_test.dart';
import 'package:saude_ja/data/repositories/appointment_repository.dart';
import 'package:saude_ja/data/repositories/auth_repository.dart';
import 'package:saude_ja/data/repositories/catalog_repository.dart';
import 'package:saude_ja/data/services/mock_api_service.dart';
import 'package:saude_ja/features/home/viewmodels/home_viewmodel.dart';

import '../../helpers/test_api.dart';

void main() {
  late MockApiService api;
  late AuthRepository auth;
  late HomeViewModel vm;

  setUpAll(loadMockAssets);

  setUp(() async {
    api = createTestApi();
    auth = AuthRepository(api);
    await auth.login(email: 'maria@saudeja.com', password: '123456');
    vm = HomeViewModel(
      auth: auth,
      catalog: CatalogRepository(api),
      appointments: AppointmentRepository(api),
      searchDelay: Duration.zero,
    );
  });

  tearDown(() => vm.dispose());

  test('começa carregando e depois mostra as seções', () async {
    expect(vm.status, HomeStatus.loading);
    await vm.load();

    expect(vm.status, HomeStatus.ready);
    expect(vm.firstName, 'Maria');
    expect(vm.specialties, hasLength(6));
    expect(vm.featuredDoctors.map((d) => d.name), [
      'Dra. Helena Ribeiro',
      'Dr. Carlos Mendes',
    ]);
    expect(vm.nextAppointment?.doctorName, 'Dra. Helena Ribeiro');
    expect(vm.nextAppointment?.date, '2026-11-26');
  });

  test('sem consulta confirmada, nextAppointment é null', () async {
    await api.cancelAppointment('a1');
    await vm.load();
    expect(vm.status, HomeStatus.ready);
    expect(vm.nextAppointment, isNull);
  });

  test('erro da API vira estado de erro com mensagem', () async {
    auth.logout(); // sem token, GET /appointments responde 401
    await vm.load();
    expect(vm.status, HomeStatus.error);
    expect(vm.errorMessage, 'Faça login para continuar.');
  });

  test('busca por nome ou especialidade', () async {
    await vm.search('helena');
    expect(vm.searchResults.single.name, 'Dra. Helena Ribeiro');

    await vm.search('cardio');
    expect(vm.searchResults, hasLength(2));

    await vm.search('xyz');
    expect(vm.searchResults, isEmpty);
    expect(vm.isSearchLoading, isFalse);
  });

  test('setQuery busca depois do atraso e clearSearch limpa', () async {
    vm.setQuery('carlos');
    expect(vm.isSearching, isTrue);
    expect(vm.isSearchLoading, isTrue);

    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(vm.isSearchLoading, isFalse);
    expect(vm.searchResults.single.name, 'Dr. Carlos Mendes');

    vm.clearSearch();
    expect(vm.isSearching, isFalse);
    expect(vm.searchResults, isEmpty);
  });

  test('tocar numa especialidade lista os médicos dela', () async {
    await vm.load();
    final cardiologia = vm.specialties.firstWhere((s) => s.id == 'cardiologia');

    await vm.selectSpecialty(cardiologia);
    expect(vm.query, 'Cardiologia');
    expect(vm.searchResults.map((d) => d.specialtyId).toSet(), {'cardiologia'});
    expect(vm.searchResults, hasLength(2));
  });

  test('resposta de uma busca antiga não sobrescreve a nova', () async {
    final old = vm.search('helena');
    final latest = vm.search('carlos');
    await Future.wait([old, latest]);
    expect(vm.searchResults.single.name, 'Dr. Carlos Mendes');
  });
}
