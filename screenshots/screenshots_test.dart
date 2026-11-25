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
import 'package:saude_ja/core/theme/theme_controller.dart';
import 'package:saude_ja/main.dart';
import 'package:saude_ja_design_system/saude_ja_design_system.dart';

import '../test/helpers/test_api.dart';

const _phone = Size(390, 844);
const _pixelRatio = 2.0;

void main() {
  setUpAll(() async {
    await loadMockAssets();
    await _loadFonts();
  });

  Future<void> open(
    WidgetTester tester, {
    String? route,
    ThemeMode themeMode = ThemeMode.light,
  }) async {
    tester.view.physicalSize = _phone * _pixelRatio;
    tester.view.devicePixelRatio = _pixelRatio;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      SaudeJaApp(
        api: createTestApi(),
        themeController: ThemeController()..setMode(themeMode),
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

  Future<void> login(
    WidgetTester tester, {
    ThemeMode themeMode = ThemeMode.light,
  }) async {
    await open(tester, themeMode: themeMode);
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
    await tap(tester, find.widgetWithText(FilledButton, 'Agendar consulta'));
    // Qua, 25: 08:30 bloqueado na agenda e 09:30 escolhido, como no
    // protótipo.
    await tap(tester, find.widgetWithText(DateChip, '25'));
    await tap(tester, find.widgetWithText(TimeSlotButton, '09:30'));
    await shoot(tester, '05_agendamento');
  });

  testWidgets('11 detalhes do médico', (tester) async {
    await login(tester);
    await tap(tester, find.widgetWithText(DoctorCard, 'Dra. Helena Ribeiro'));
    await shoot(tester, '11_medico');
  });

  testWidgets('14 esqueci minha senha', (tester) async {
    await open(tester);
    await tap(tester, find.text('Esqueci minha senha'));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'E-mail'),
      'maria@saudeja.com',
    );
    await tap(tester, find.widgetWithText(FilledButton, 'Enviar código'));
    await shoot(tester, '14_esqueci_senha');
  });

  testWidgets('15 perfil escuro', (tester) async {
    await login(tester, themeMode: ThemeMode.dark);
    await tap(tester, find.text('Perfil'));
    await shoot(tester, '15_perfil_escuro');
  });

  testWidgets('12 home escuro', (tester) async {
    await login(tester, themeMode: ThemeMode.dark);
    await shoot(tester, '12_home_escuro');
  });

  testWidgets('13 agendamento escuro', (tester) async {
    await login(tester, themeMode: ThemeMode.dark);
    await tap(tester, find.widgetWithText(DoctorCard, 'Dra. Helena Ribeiro'));
    await tap(tester, find.widgetWithText(FilledButton, 'Agendar consulta'));
    await tap(tester, find.widgetWithText(DateChip, '25'));
    await tap(tester, find.widgetWithText(TimeSlotButton, '09:30'));
    await shoot(tester, '13_agendamento_escuro');
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

  // O Sample App tem um skeleton animado; com "reduzir animações" ele fica
  // parado e o print sai sempre igual.
  void stillAnimations(WidgetTester tester) {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  }

  testWidgets('09 design system', (tester) async {
    stillAnimations(tester);
    await open(tester, route: AppRoutes.designSystem);
    await shoot(tester, '09_design_system');
  });

  testWidgets('10 design system completo', (tester) async {
    // Tela bem alta para caber o Sample App inteiro numa imagem só.
    stillAnimations(tester);
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
