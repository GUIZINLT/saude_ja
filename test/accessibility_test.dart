import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saude_ja/core/routes/app_routes.dart';
import 'package:saude_ja/core/theme/theme_controller.dart';
import 'package:saude_ja/main.dart';
import 'package:saude_ja_design_system/saude_ja_design_system.dart';

import 'helpers/fonts.dart';
import 'helpers/test_api.dart';

/// Diretrizes de acessibilidade do Flutter nas telas principais, nos dois
/// temas, e as mesmas telas com a fonte do aparelho em 200%.
void main() {
  setUpAll(() async {
    await loadMockAssets();
    await loadRealFonts();
  });

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> open(
    WidgetTester tester, {
    ThemeMode themeMode = ThemeMode.light,
    double textScale = 1.0,
  }) async {
    tester.view.physicalSize = const Size(390, 844) * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      SaudeJaApp(
        api: createTestApi(),
        themeController: ThemeController()..setMode(themeMode),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> login(WidgetTester tester) async {
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

  /// Confere as três diretrizes na tela atual.
  Future<void> checkGuidelines(WidgetTester tester, String screen) async {
    await expectLater(
      tester,
      meetsGuideline(androidTapTargetGuideline),
      reason: '$screen: área de toque',
    );
    await expectLater(
      tester,
      meetsGuideline(labeledTapTargetGuideline),
      reason: '$screen: botões sem nome',
    );
    await expectLater(
      tester,
      meetsGuideline(textContrastGuideline),
      reason: '$screen: contraste do texto',
    );
  }

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    final theme = mode == ThemeMode.light ? 'claro' : 'escuro';

    testWidgets('diretrizes nas telas principais (tema $theme)', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await open(tester, themeMode: mode);
      await checkGuidelines(tester, 'Login');

      await tap(tester, find.widgetWithText(OutlinedButton, 'Criar conta'));
      await checkGuidelines(tester, 'Cadastro');
      await tap(tester, find.byTooltip('Voltar'));

      await tap(tester, find.text('Esqueci minha senha'));
      await checkGuidelines(tester, 'Esqueci minha senha');
      await tap(tester, find.byTooltip('Voltar'));

      await login(tester);
      await checkGuidelines(tester, 'Home');

      await tap(tester, find.widgetWithText(DoctorCard, 'Dra. Helena Ribeiro'));
      await checkGuidelines(tester, 'Detalhes do médico');

      await tap(tester, find.widgetWithText(FilledButton, 'Agendar consulta'));
      await checkGuidelines(tester, 'Agendamento');
      await tap(tester, find.byTooltip('Voltar'));
      await tap(tester, find.byTooltip('Voltar'));

      await tap(tester, find.text('Consultas'));
      await checkGuidelines(tester, 'Consultas');
      await tap(tester, find.text('Histórico'));
      await checkGuidelines(tester, 'Histórico');
      await tap(tester, find.text('Perfil'));
      await checkGuidelines(tester, 'Perfil');
      semantics.dispose();
    });
  }

  testWidgets('telas sem estouro com fonte em 200%', (tester) async {
    await open(tester, textScale: 2);
    await tap(tester, find.widgetWithText(OutlinedButton, 'Criar conta'));
    await tap(tester, find.byTooltip('Voltar'));
    await login(tester);
    // O toque no card já é testado nas outras telas; aqui interessa o
    // layout de cada tela com a fonte grande, então abre direto pela rota.
    unawaited(
      tester
          .state<NavigatorState>(find.byType(Navigator))
          .pushNamed(AppRoutes.doctor, arguments: 'd1'),
    );
    await tester.pumpAndSettle();
    await tap(tester, find.widgetWithText(FilledButton, 'Agendar consulta'));
    await tap(tester, find.byTooltip('Voltar'));
    await tap(tester, find.byTooltip('Voltar'));
    await tap(tester, find.text('Consultas'));
    await tap(tester, find.text('Histórico'));
    await tap(tester, find.text('Perfil'));
    // Qualquer "RenderFlex overflowed" faz o teste falhar sozinho.
    expect(tester.takeException(), isNull);
  });

  testWidgets('cards são lidos como uma frase só', (tester) async {
    final semantics = tester.ensureSemantics();
    await open(tester);
    await login(tester);

    expect(
      find.bySemanticsLabel(
        RegExp('Dra. Helena Ribeiro, Cardiologia, nota 4,9'),
      ),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(
        RegExp(r'Consulta Confirmada.*Qui, 26 nov 2026.*09:30.*Helena'),
      ),
      findsOneWidget,
    );
    semantics.dispose();
  });
}
