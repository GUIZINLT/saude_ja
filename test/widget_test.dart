import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saude_ja/core/routes/app_routes.dart';
import 'package:saude_ja/data/repositories/auth_repository.dart';
import 'package:saude_ja/data/services/mock_api_service.dart';
import 'package:saude_ja/data/services/session_storage.dart';
import 'package:saude_ja/design_system/components/app_bottom_navigation.dart';
import 'package:saude_ja/design_system/components/app_skeleton.dart';
import 'package:saude_ja/design_system/components/appointment_card.dart';
import 'package:saude_ja/design_system/components/date_chip.dart';
import 'package:saude_ja/design_system/components/doctor_card.dart';
import 'package:saude_ja/design_system/components/specialty_card.dart';
import 'package:saude_ja/design_system/components/time_slot_button.dart';
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

  testWidgets('com sessão salva, abre direto na Home', (tester) async {
    final api = createTestApi();
    final storage = InMemorySessionStorage();
    await tester.runAsync(() async {
      // Login feito numa "abertura anterior" do app.
      await AuthRepository(
        createTestApi(),
        storage,
      ).login(email: 'maria@saudeja.com', password: '123456');
    });
    // Restaura no relógio do teste (como o main() faz ao abrir o app),
    // avançando o tempo até terminar.
    final auth = AuthRepository(api, storage);
    var restored = false;
    unawaited(auth.restoreSession().then((_) => restored = true));
    while (!restored) {
      await tester.pump(const Duration(milliseconds: 10));
    }

    await tester.pumpWidget(
      SaudeJaApp(
        api: api,
        auth: auth,
        initialRoute: auth.isLoggedIn ? AppRoutes.home : AppRoutes.login,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Olá, Maria'), findsOneWidget);
  });

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

  testWidgets('agendar consulta a partir da Home', (tester) async {
    await tester.pumpWidget(SaudeJaApp(api: createTestApi()));
    await tester.enterText(field('E-mail'), 'maria@saudeja.com');
    await tester.enterText(field('Senha'), '123456');
    await tapAndSettle(tester, find.widgetWithText(FilledButton, 'Entrar'));

    // Médicos em destaque > Dra. Helena (rola a Home até o card).
    final helena = find.widgetWithText(DoctorCard, 'Dra. Helena Ribeiro');
    final homeList = find
        .byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
        )
        .first;
    await tester.scrollUntilVisible(helena, 200, scrollable: homeList);
    await tapAndSettle(tester, helena);

    // Detalhes do médico.
    expect(find.text('Sobre'), findsOneWidget);
    expect(find.text('CRM/TO 12345'), findsOneWidget);
    expect(find.text('(128 avaliações)'), findsOneWidget);
    expect(find.text('Seg, Ter, Qua, Qui, Sex'), findsOneWidget);
    expect(find.text('Ter, 24 nov 2026 às 08:00'), findsOneWidget);
    await tapAndSettle(
      tester,
      find.widgetWithText(FilledButton, 'Agendar consulta'),
    );

    // Agendamento.
    expect(find.text('Agendar consulta'), findsOneWidget);
    expect(find.text('Novembro 2026'), findsOneWidget);
    expect(find.byType(DateChip), findsNWidgets(5));

    // Sem horário escolhido o botão fica desabilitado.
    final confirmar = find.widgetWithText(
      FilledButton,
      'Confirmar agendamento',
    );
    expect(tester.widget<FilledButton>(confirmar).onPressed, isNull);

    await tapAndSettle(tester, find.widgetWithText(TimeSlotButton, '09:00'));
    await tapAndSettle(tester, confirmar);

    expect(find.text('Consulta agendada!'), findsOneWidget);
    await tapAndSettle(tester, find.text('Voltar para a Home'));

    // A Home recarrega e mostra a nova próxima consulta (hoje, 09:00).
    // Volta a rolagem para o topo, onde ficam a saudação e o card.
    await tester.drag(homeList, const Offset(0, 2000));
    await tester.pumpAndSettle();
    expect(find.text('Olá, Maria'), findsOneWidget);
    expect(find.text('Ter, 24 nov 2026'), findsOneWidget);
    expect(find.text('Às 09:00'), findsOneWidget);
  });

  testWidgets('tela que exige login abre o Login sem sessão', (tester) async {
    await tester.pumpWidget(
      SaudeJaApp(api: createTestApi(), initialRoute: AppRoutes.home),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Entrar'), findsOneWidget);
    expect(find.text('Olá, Maria'), findsNothing);
  });

  testWidgets('Home mostra o carregamento animado e depois o conteúdo', (
    tester,
  ) async {
    // API com atraso, para dar tempo de ver o carregamento.
    final api = MockApiService(
      latency: const Duration(milliseconds: 300),
      backend: createTestBackend(),
    );
    await tester.pumpWidget(SaudeJaApp(api: api));
    await tester.enterText(field('E-mail'), 'maria@saudeja.com');
    await tester.enterText(field('Senha'), '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
    await tester.pump(const Duration(milliseconds: 310)); // resposta do login
    await tester.pump(); // abre a Home, que começa a carregar
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(SkeletonCard), findsWidgets);

    await tester.pumpAndSettle();
    expect(find.byType(SkeletonCard), findsNothing);
    expect(find.text('Qui, 26 nov 2026'), findsOneWidget);
  });

  testWidgets('remarcar consulta pela aba Consultas', (tester) async {
    await tester.pumpWidget(SaudeJaApp(api: createTestApi()));
    await tester.enterText(field('E-mail'), 'maria@saudeja.com');
    await tester.enterText(field('Senha'), '123456');
    await tapAndSettle(tester, find.widgetWithText(FilledButton, 'Entrar'));

    await tapAndSettle(tester, find.text('Consultas'));
    expect(find.text('Qui, 26 nov 2026'), findsOneWidget);
    await tapAndSettle(tester, find.widgetWithText(TextButton, 'Remarcar'));

    expect(find.text('Remarcar consulta'), findsOneWidget);
    expect(find.textContaining('Data atual: Qui, 26 nov 2026'), findsOneWidget);
    await tapAndSettle(tester, find.widgetWithText(DateChip, '27'));
    await tapAndSettle(tester, find.widgetWithText(TimeSlotButton, '10:00'));
    await tapAndSettle(
      tester,
      find.widgetWithText(FilledButton, 'Confirmar nova data'),
    );

    expect(find.text('Consulta remarcada!'), findsOneWidget);
    await tapAndSettle(tester, find.widgetWithText(FilledButton, 'Voltar'));

    expect(find.text('Minhas consultas'), findsOneWidget);
    expect(find.text('Sex, 27 nov 2026'), findsOneWidget);
    expect(find.text('Às 10:00'), findsOneWidget);
    expect(find.text('Consulta remarcada.'), findsOneWidget);
  });

  testWidgets('cancelar em Consultas reflete no Histórico e na Home', (
    tester,
  ) async {
    await tester.pumpWidget(SaudeJaApp(api: createTestApi()));
    await tester.enterText(field('E-mail'), 'maria@saudeja.com');
    await tester.enterText(field('Senha'), '123456');
    await tapAndSettle(tester, find.widgetWithText(FilledButton, 'Entrar'));

    // Aba Consultas.
    await tapAndSettle(tester, find.text('Consultas'));
    expect(find.text('Minhas consultas'), findsOneWidget);
    expect(find.text('Dra. Helena Ribeiro'), findsOneWidget);

    // Cancelar pede confirmação; "Manter consulta" não cancela.
    await tapAndSettle(
      tester,
      find.widgetWithText(TextButton, 'Cancelar consulta'),
    );
    expect(find.text('Cancelar consulta?'), findsOneWidget);
    await tapAndSettle(tester, find.text('Manter consulta'));
    expect(find.text('Dra. Helena Ribeiro'), findsOneWidget);

    await tapAndSettle(
      tester,
      find.widgetWithText(TextButton, 'Cancelar consulta'),
    );
    await tapAndSettle(
      tester,
      find.widgetWithText(FilledButton, 'Cancelar consulta'),
    );
    expect(find.text('Consulta cancelada.'), findsOneWidget);
    expect(find.text('Você não tem consultas agendadas.'), findsOneWidget);

    // Histórico: a1 cancelada agora + a3 cancelada + a2 realizada.
    await tapAndSettle(tester, find.text('Histórico'));
    expect(find.text('Consultas realizadas e canceladas.'), findsOneWidget);
    expect(find.text('Cancelada'), findsNWidgets(2));
    expect(find.text('Realizada'), findsOneWidget);

    // Home: sem próxima consulta.
    await tapAndSettle(tester, find.text('Home'));
    expect(find.text('Você não tem consultas agendadas.'), findsOneWidget);
  });

  testWidgets('Sample App do design system continua acessível', (tester) async {
    // Com "reduzir animações" ligado, o skeleton da vitrine fica parado
    // (e o pumpAndSettle consegue terminar).
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await tester.pumpWidget(
      SaudeJaApp(api: createTestApi(), initialRoute: AppRoutes.designSystem),
    );

    expect(find.text('SaúdeJá | Design System'), findsOneWidget);
    expect(find.text('Bem-vindo ao SaúdeJá!'), findsOneWidget);

    // Todos os componentes aparecem na vitrine.
    final sampleList = find.byType(Scrollable).first;
    for (final type in [
      SpecialtyCard,
      DoctorCard,
      AppointmentCard,
      DateChip,
      TimeSlotButton,
    ]) {
      await tester.scrollUntilVisible(
        find.byType(type).first,
        300,
        scrollable: sampleList,
      );
      expect(find.byType(type), findsWidgets, reason: '$type');
    }
    expect(find.byType(AppBottomNavigation), findsOneWidget);

    // Horário ocupado não muda a seleção; livre muda.
    TimeSlotButton slot(String time) =>
        tester.widget(find.widgetWithText(TimeSlotButton, time));
    expect(slot('09:30').selected, isTrue);
    await tapAndSettle(tester, find.widgetWithText(TimeSlotButton, '08:30'));
    expect(slot('09:30').selected, isTrue);
    await tapAndSettle(tester, find.widgetWithText(TimeSlotButton, '10:00'));
    expect(slot('10:00').selected, isTrue);
    expect(slot('09:30').selected, isFalse);

    // Diálogo de confirmação.
    await tapAndSettle(tester, find.text('Abrir confirmação destrutiva'));
    expect(find.text('Cancelar consulta?'), findsOneWidget);
    await tapAndSettle(tester, find.text('Manter consulta'));
    expect(find.text('Mantido.'), findsOneWidget);
  });
}
