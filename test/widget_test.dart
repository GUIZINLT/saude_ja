import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saude_ja/core/routes/app_routes.dart';
import 'package:saude_ja/main.dart';

import 'helpers/test_api.dart';

void main() {
  setUpAll(loadMockAssets);

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('abre na tela de Login', (tester) async {
    await tester.pumpWidget(SaudeJaApp(api: createTestApi()));

    expect(find.text('SaúdeJá'), findsOneWidget);
    expect(find.text('Sua saúde em primeiro lugar.'), findsOneWidget);
    expect(field('E-mail'), findsOneWidget);
    expect(field('Senha'), findsOneWidget);
  });

  testWidgets('login válido leva para a Home', (tester) async {
    await tester.pumpWidget(SaudeJaApp(api: createTestApi()));

    await tester.enterText(field('E-mail'), 'maria@saudeja.com');
    await tester.enterText(field('Senha'), '123456');
    await tapAndSettle(tester, find.widgetWithText(FilledButton, 'Entrar'));

    expect(find.text('Olá, Maria'), findsOneWidget);

    // Seções da Home, com os dados do mock.
    expect(find.text('Especialidades'), findsOneWidget);
    expect(find.text('Cardiologia'), findsWidgets);
    expect(find.text('Próxima consulta'), findsOneWidget);
    expect(find.text('Qui, 26 nov 2026'), findsOneWidget);
    expect(find.text('Confirmada'), findsOneWidget);

    // Busca com espera de digitação.
    await tester.enterText(find.byType(TextFormField), 'carlos');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.text('Resultados (1)'), findsOneWidget);
    expect(find.text('Dr. Carlos Mendes'), findsOneWidget);
    expect(find.text('Próxima consulta'), findsNothing);

    await tapAndSettle(tester, find.byTooltip('Limpar busca'));
    expect(find.text('Próxima consulta'), findsOneWidget);

    // Menu inferior: Perfil > Sair volta para o Login.
    await tapAndSettle(tester, find.text('Perfil'));
    expect(find.text('maria@saudeja.com'), findsOneWidget);
    await tapAndSettle(tester, find.text('Sair'));
    expect(find.widgetWithText(FilledButton, 'Entrar'), findsOneWidget);
  });

  testWidgets('campos vazios e senha errada mostram erro', (tester) async {
    await tester.pumpWidget(SaudeJaApp(api: createTestApi()));
    final entrar = find.widgetWithText(FilledButton, 'Entrar');

    await tapAndSettle(tester, entrar);
    expect(find.text('Informe o e-mail.'), findsOneWidget);
    expect(find.text('Informe a senha.'), findsOneWidget);

    await tester.enterText(field('E-mail'), 'maria@saudeja.com');
    await tester.enterText(field('Senha'), 'errada');
    await tapAndSettle(tester, entrar);
    expect(find.text('E-mail ou senha incorretos.'), findsOneWidget);
    expect(find.text('Olá, Maria'), findsNothing);
  });

  testWidgets('cadastro cria a conta e abre a Home', (tester) async {
    await tester.pumpWidget(SaudeJaApp(api: createTestApi()));

    await tapAndSettle(
      tester,
      find.widgetWithText(OutlinedButton, 'Criar conta'),
    );
    expect(
      find.text('Preencha seus dados para agendar consultas.'),
      findsOneWidget,
    );

    await tester.enterText(field('Nome completo'), 'João Silva');
    await tester.enterText(field('E-mail'), 'joao@email.com');
    await tester.enterText(field('Telefone'), '63988887777');
    await tester.enterText(field('Senha'), 'segredo1');
    await tester.enterText(field('Confirmar senha'), 'segredo1');
    await tapAndSettle(tester, find.byType(Checkbox));
    await tapAndSettle(
      tester,
      find.widgetWithText(FilledButton, 'Criar conta'),
    );

    expect(find.text('Olá, João'), findsOneWidget);
  });

  testWidgets('Sample App do design system continua acessível', (tester) async {
    await tester.pumpWidget(
      SaudeJaApp(api: createTestApi(), initialRoute: AppRoutes.designSystem),
    );

    expect(find.text('SaúdeJá | Design System'), findsOneWidget);
    expect(find.text('Bem-vindo ao SaúdeJá!'), findsOneWidget);
  });
}
