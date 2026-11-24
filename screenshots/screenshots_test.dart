// Gera os prints das telas usados no README (docs/screenshots/*.png).
//
//   flutter test screenshots --update-goldens
//
// Fica fora da pasta test/ para não rodar junto com `flutter test`.
// Cada tela é renderizada em 390x844 (celular), com as fontes Roboto e
// Material Icons que vêm no próprio SDK do Flutter e os dados do mock com
// o relógio fixo em ter, 24/11/2026 07:00.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saude_ja/core/routes/app_routes.dart';
import 'package:saude_ja/design_system/components/date_chip.dart';
import 'package:saude_ja/design_system/components/doctor_card.dart';
import 'package:saude_ja/design_system/components/time_slot_button.dart';
import 'package:saude_ja/main.dart';

import '../test/helpers/test_api.dart';

const _phone = Size(390, 844);
const _pixelRatio = 2.0;

void main() {
  setUpAll(() async {
    await loadMockAssets();
    await _loadFonts();
  });

  Future<void> open(WidgetTester tester, {String? route}) async {
    tester.view.physicalSize = _phone * _pixelRatio;
    tester.view.devicePixelRatio = _pixelRatio;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      SaudeJaApp(
        api: createTestApi(),
        initialRoute: route ?? AppRoutes.initial,
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> login(WidgetTester tester) async {
    await open(tester);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'E-mail'),
      'maria@saudeja.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Senha'),
      '123456',
    );
    await tap(tester, find.widgetWithText(FilledButton, 'Entrar'));
  }

  Future<void> shoot(WidgetTester tester, String name) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../docs/screenshots/$name.png'),
    );
  }

  testWidgets('01 login', (tester) async {
    await open(tester);
    await shoot(tester, '01_login');
  });

  testWidgets('02 cadastro', (tester) async {
    await open(tester);
    await tap(tester, find.widgetWithText(OutlinedButton, 'Criar conta'));
    await shoot(tester, '02_cadastro');
  });

  testWidgets('03 home', (tester) async {
    await login(tester);
    await shoot(tester, '03_home');
  });

  testWidgets('04 busca por especialidade', (tester) async {
    await login(tester);
    await tap(tester, find.text('Cardiologia').first);
    await shoot(tester, '04_busca');
  });

  testWidgets('05 agendamento', (tester) async {
    await login(tester);
    await tap(tester, find.widgetWithText(DoctorCard, 'Dra. Helena Ribeiro'));
    // Qua, 25: 08:30 bloqueado na agenda e 09:30 escolhido, como no
    // protótipo.
    await tap(tester, find.widgetWithText(DateChip, '25'));
    await tap(tester, find.widgetWithText(TimeSlotButton, '09:30'));
    await shoot(tester, '05_agendamento');
  });

  testWidgets('06 consultas', (tester) async {
    await login(tester);
    await tap(tester, find.text('Consultas'));
    await shoot(tester, '06_consultas');
  });

  testWidgets('07 historico', (tester) async {
    await login(tester);
    await tap(tester, find.text('Histórico'));
    await shoot(tester, '07_historico');
  });

  testWidgets('08 perfil', (tester) async {
    await login(tester);
    await tap(tester, find.text('Perfil'));
    await shoot(tester, '08_perfil');
  });

  testWidgets('09 design system', (tester) async {
    await open(tester, route: AppRoutes.designSystem);
    await shoot(tester, '09_design_system');
  });

  testWidgets('10 design system completo', (tester) async {
    // Tela bem alta para caber o Sample App inteiro numa imagem só.
    await open(tester, route: AppRoutes.designSystem);
    tester.view.physicalSize = const Size(390, 3150) * _pixelRatio;
    await tester.pumpAndSettle();
    await shoot(tester, '10_design_system_completo');
  });
}

/// Carrega Roboto e Material Icons do SDK do Flutter. Sem isso, os testes
/// desenham o texto com a fonte de teste (quadradinhos).
Future<void> _loadFonts() async {
  final fontsDir = Directory(
    '${_flutterRoot()}/bin/cache/artifacts/material_fonts',
  );

  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      final bytes = File('${fontsDir.path}/$f').readAsBytesSync();
      loader.addFont(Future.value(ByteData.view(bytes.buffer)));
    }
    await loader.load();
  }

  await load('Roboto', [
    'roboto-regular.ttf',
    'roboto-medium.ttf',
    'roboto-bold.ttf',
  ]);
  await load('MaterialIcons', ['materialicons-regular.otf']);
}

String _flutterRoot() {
  final fromEnv = Platform.environment['FLUTTER_ROOT'];
  if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
  // flutter_tester fica em <raiz>/bin/cache/artifacts/engine/...
  final exe = Platform.resolvedExecutable.replaceAll('\\', '/');
  final i = exe.indexOf('/bin/cache/');
  if (i < 0) {
    throw StateError('Não achei o SDK do Flutter. Defina FLUTTER_ROOT.');
  }
  return exe.substring(0, i);
}
