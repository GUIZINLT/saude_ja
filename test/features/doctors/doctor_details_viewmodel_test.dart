import 'package:flutter_test/flutter_test.dart';
import 'package:saude_ja/data/repositories/catalog_repository.dart';
import 'package:saude_ja/features/doctors/viewmodels/doctor_details_viewmodel.dart';

import '../../helpers/test_api.dart';

// Relógio dos testes: ter, 24/11/2026 07:00 (ver test_api.dart).
void main() {
  setUpAll(loadMockAssets);

  DoctorDetailsViewModel create(String? id) => DoctorDetailsViewModel(
    doctorId: id,
    catalog: CatalogRepository(createTestApi()),
  );

  test('carrega médico, dias de atendimento e próximo horário', () async {
    final vm = create('d1');
    expect(vm.status, DoctorDetailsStatus.loading);
    await vm.load();

    expect(vm.status, DoctorDetailsStatus.ready);
    expect(vm.doctor?.name, 'Dra. Helena Ribeiro');
    expect(vm.attendanceDays, 'Seg, Ter, Qua, Qui, Sex');
    expect(vm.nextFreeSlot, 'Ter, 24 nov 2026 às 08:00');
  });

  test('médico que atende só alguns dias', () async {
    final vm = create('d2'); // Dr. Carlos: seg, qua e sex à tarde
    await vm.load();
    expect(vm.attendanceDays, 'Seg, Qua, Sex');
    expect(vm.nextFreeSlot, 'Qua, 25 nov 2026 às 13:00');
  });

  test('médico inexistente ou não informado', () async {
    final unknown = create('d999');
    await unknown.load();
    expect(unknown.status, DoctorDetailsStatus.error);
    expect(unknown.errorMessage, 'Médico não encontrado.');

    final none = create(null);
    await none.load();
    expect(none.status, DoctorDetailsStatus.error);
  });
}
