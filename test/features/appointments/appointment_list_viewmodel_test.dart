import 'package:flutter_test/flutter_test.dart';
import 'package:saude_ja/data/models/appointment.dart';
import 'package:saude_ja/data/repositories/appointment_repository.dart';
import 'package:saude_ja/data/repositories/auth_repository.dart';
import 'package:saude_ja/data/services/mock_api_service.dart';
import 'package:saude_ja/features/appointments/viewmodels/appointment_list_viewmodel.dart';

import '../../helpers/test_api.dart';

// Relógio dos testes: ter, 24/11/2026 07:00 (ver test_api.dart).
void main() {
  late MockApiService api;
  late AuthRepository auth;
  late AppointmentRepository repository;

  setUpAll(loadMockAssets);

  setUp(() async {
    api = createTestApi();
    auth = AuthRepository(api);
    await auth.login(email: 'maria@saudeja.com', password: '123456');
    repository = AppointmentRepository(api);
  });

  group('Consultas', () {
    test('lista as confirmadas', () async {
      final vm = UpcomingAppointmentsViewModel(repository);
      expect(vm.status, AppointmentListStatus.loading);
      await vm.load();

      expect(vm.status, AppointmentListStatus.ready);
      expect(vm.items.map((a) => a.id), ['a1']);
      expect(vm.items.single.status, AppointmentStatus.confirmed);
    });

    test('cancelar tira da lista e vai para o histórico', () async {
      final vm = UpcomingAppointmentsViewModel(repository);
      await vm.load();

      final error = await vm.cancel(vm.items.single);
      expect(error, isNull);
      expect(vm.isEmpty, isTrue);
      expect(vm.cancellingId, isNull);

      final history = AppointmentHistoryViewModel(repository);
      await history.load();
      final a1 = history.items.firstWhere((a) => a.id == 'a1');
      expect(a1.status, AppointmentStatus.cancelled);
      expect(a1.cancelledAt, isNotNull);
    });

    test('erro ao cancelar devolve a mensagem e recarrega', () async {
      final vm = UpcomingAppointmentsViewModel(repository);
      await vm.load();
      final a1 = vm.items.single;

      // Cancelada por fora antes do toque (ex.: em outro aparelho).
      await api.cancelAppointment('a1');

      final error = await vm.cancel(a1);
      expect(error, 'Esta consulta já foi cancelada.');
      expect(vm.isEmpty, isTrue);
    });

    test('sem login mostra erro', () async {
      auth.logout();
      final vm = UpcomingAppointmentsViewModel(repository);
      await vm.load();
      expect(vm.status, AppointmentListStatus.error);
      expect(vm.errorMessage, 'Faça login para continuar.');
    });
  });

  group('Histórico', () {
    test(
      'realizadas e canceladas, da mais recente para a mais antiga',
      () async {
        final vm = AppointmentHistoryViewModel(repository);
        await vm.load();

        expect(vm.items.map((a) => a.id), ['a3', 'a2']);
        expect(vm.items.map((a) => a.status), [
          AppointmentStatus.cancelled,
          AppointmentStatus.completed,
        ]);
      },
    );
  });
}
