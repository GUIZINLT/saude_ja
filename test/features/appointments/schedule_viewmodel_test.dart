import 'package:flutter_test/flutter_test.dart';
import 'package:saude_ja/data/repositories/appointment_repository.dart';
import 'package:saude_ja/data/repositories/auth_repository.dart';
import 'package:saude_ja/data/repositories/catalog_repository.dart';
import 'package:saude_ja/data/services/mock_api_service.dart';
import 'package:saude_ja/features/appointments/viewmodels/schedule_viewmodel.dart';

import '../../helpers/test_api.dart';

// Relógio dos testes: ter, 24/11/2026 07:00 (ver test_api.dart).
void main() {
  late MockApiService api;

  setUpAll(loadMockAssets);

  setUp(() async {
    api = createTestApi();
    await AuthRepository(
      api,
    ).login(email: 'maria@saudeja.com', password: '123456');
  });

  ScheduleViewModel create(String? doctorId) => ScheduleViewModel(
    doctorId: doctorId,
    catalog: CatalogRepository(api),
    appointments: AppointmentRepository(api),
  );

  bool available(ScheduleViewModel vm, String time) =>
      vm.selectedDay!.slots.firstWhere((s) => s.time == time).available;

  test('carrega médico, 5 dias e escolhe o primeiro dia livre', () async {
    final vm = create('d1');
    await vm.load();

    expect(vm.status, ScheduleStatus.ready);
    expect(vm.doctor?.name, 'Dra. Helena Ribeiro');
    expect(vm.days.map((d) => d.date), [
      '2026-11-24',
      '2026-11-25',
      '2026-11-26',
      '2026-11-27',
      '2026-11-30',
    ]);
    expect(vm.selectedDate, '2026-11-24');
    expect(vm.monthLabel, 'Novembro 2026');
    expect(vm.canConfirm, isFalse);
  });

  test('horário ocupado não pode ser escolhido', () async {
    final vm = create('d1');
    await vm.load();
    vm.selectDate('2026-11-26');

    expect(available(vm, '09:30'), isFalse); // consulta a1 da Maria
    vm.selectTime('09:30');
    expect(vm.selectedTime, isNull);

    vm.selectTime('10:00');
    expect(vm.selectedTime, '10:00');
    expect(vm.canConfirm, isTrue);

    vm.selectTime('10:00'); // tocar de novo desmarca
    expect(vm.selectedTime, isNull);
  });

  test('trocar de dia limpa o horário escolhido', () async {
    final vm = create('d1');
    await vm.load();
    vm.selectTime('09:00');
    vm.selectDate('2026-11-25');
    expect(vm.selectedTime, isNull);
  });

  test('confirmar cria a consulta', () async {
    final vm = create('d1');
    await vm.load();
    vm
      ..selectDate('2026-11-27')
      ..selectTime('10:00');

    expect(await vm.confirm(), isTrue);
    expect(vm.createdAppointment?.date, '2026-11-27');
    expect(vm.createdAppointment?.time, '10:00');
    expect(vm.isSubmitting, isFalse);

    final upcoming = await AppointmentRepository(api).getUpcoming();
    expect(upcoming.map((a) => a.id), contains(vm.createdAppointment!.id));
  });

  test(
    'se o horário for ocupado antes de confirmar, atualiza a grade',
    () async {
      final vm = create('d1');
      await vm.load();
      vm.selectTime('09:00'); // dia 24

      // Outra reserva ocupa o mesmo horário antes da confirmação.
      await api.createAppointment(
        doctorId: 'd1',
        date: '2026-11-24',
        time: '09:00',
      );

      expect(await vm.confirm(), isFalse);
      expect(vm.submitError, isNotNull);
      expect(vm.selectedTime, isNull);
      expect(available(vm, '09:00'), isFalse);
    },
  );

  test('modo remarcar troca a data da consulta existente', () async {
    final repository = AppointmentRepository(api);
    final current = (await repository.getUpcoming()).single; // a1, 26/11
    final vm = ScheduleViewModel(
      doctorId: current.doctorId,
      rescheduling: current,
      catalog: CatalogRepository(api),
      appointments: repository,
    );
    await vm.load();
    expect(vm.isRescheduling, isTrue);

    vm
      ..selectDate('2026-11-27')
      ..selectTime('10:00');
    expect(await vm.confirm(), isTrue);
    expect(vm.createdAppointment?.id, current.id);

    final upcoming = await repository.getUpcoming();
    expect(upcoming.single.id, current.id); // não criou outra consulta
    expect(upcoming.single.date, '2026-11-27');
    expect(upcoming.single.time, '10:00');
  });

  test('ScheduleArgs aceita id ou objeto', () {
    expect(ScheduleArgs.from('d1')?.doctorId, 'd1');
    expect(ScheduleArgs.from('d1')?.reschedule, isNull);
    expect(ScheduleArgs.from(null), isNull);
  });

  test('médico inexistente e médico não informado', () async {
    final unknown = create('d999');
    await unknown.load();
    expect(unknown.status, ScheduleStatus.error);
    expect(unknown.errorMessage, 'Médico não encontrado.');

    final none = create(null);
    await none.load();
    expect(none.status, ScheduleStatus.error);
  });
}
