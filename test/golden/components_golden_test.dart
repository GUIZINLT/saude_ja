// Testes visuais dos componentes do design system.
//
// Cada componente, nos seus estados, é comparado com uma imagem de
// referência em test/golden/goldens/. Depois de mudar um componente de
// propósito, atualize as referências com:
//
//   flutter test test/golden --update-goldens
//
// O texto usa a fonte de teste do Flutter (blocos), que sai igual no
// Windows e no Linux do CI. A comparação aceita até 1% de pixels
// diferentes, por causa do antisserrilhado de bordas entre sistemas.
@Tags(['golden'])
library;

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saude_ja/core/theme/app_theme.dart';
import 'package:saude_ja/design_system/components/app_bottom_navigation.dart';
import 'package:saude_ja/design_system/components/app_button.dart';
import 'package:saude_ja/design_system/components/app_dialog.dart';
import 'package:saude_ja/design_system/components/app_skeleton.dart';
import 'package:saude_ja/design_system/components/app_text_field.dart';
import 'package:saude_ja/design_system/components/appointment_card.dart';
import 'package:saude_ja/design_system/components/date_chip.dart';
import 'package:saude_ja/design_system/components/doctor_card.dart';
import 'package:saude_ja/design_system/components/specialty_card.dart';
import 'package:saude_ja/design_system/components/time_slot_button.dart';
import 'package:saude_ja/design_system/tokens/app_spacing.dart';

void main() {
  setUpAll(() {
    final base = (goldenFileComparator as LocalFileComparator).basedir;
    goldenFileComparator = _TolerantComparator(
      base.resolve('components_golden_test.dart'),
    );
  });

  /// Desenha [child] numa área de [width] px (360 por padrão), com o tema do app,
  /// e compara com goldens/[name].png.
  Future<void> golden(
    WidgetTester tester,
    String name,
    Widget child, {
    double width = 360,
    double height = 400,
  }) async {
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // Skeleton parado, para a imagem ser sempre a mesma.
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: child,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/$name.png'),
    );
  }

  testWidgets('AppButton', (tester) async {
    await golden(
      tester,
      'app_button',
      Column(
        children: [
          AppButton(label: 'Principal', icon: Icons.add, onPressed: () {}),
          const SizedBox(height: AppSpacing.md),
          AppButton(label: 'Secundário', isSecondary: true, onPressed: () {}),
          const SizedBox(height: AppSpacing.md),
          const AppButton(label: 'Desabilitado', onPressed: null),
        ],
      ),
      height: 240,
    );
  });

  testWidgets('AppTextField', (tester) async {
    await golden(
      tester,
      'app_text_field',
      const Column(
        children: [
          AppTextField(label: 'Nome', hint: 'Digite', prefixIcon: Icons.person),
          SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'E-mail',
            hint: 'Digite',
            prefixIcon: Icons.email,
            errorText: 'E-mail inválido.',
          ),
          SizedBox(height: AppSpacing.md),
          AppTextField(hint: 'Buscar', prefixIcon: Icons.search),
        ],
      ),
      height: 280,
    );
  });

  testWidgets('Cards', (tester) async {
    await golden(
      tester,
      'cards',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SpecialtyCard(
            title: 'Cardiologia',
            icon: Icons.favorite,
            onTap: () {},
          ),
          const SizedBox(height: AppSpacing.md),
          DoctorCard(
            name: 'Dra. Helena Ribeiro',
            specialty: 'Cardiologia',
            rating: 4.9,
            onTap: () {},
          ),
        ],
      ),
      height: 300,
    );
  });

  testWidgets('AppointmentCard', (tester) async {
    await golden(
      tester,
      'appointment_card',
      Column(
        children: [
          AppointmentCard(
            doctorName: 'Dra. Helena Ribeiro',
            specialty: 'Cardiologia',
            date: 'Qui, 26 nov 2026',
            time: 'Às 09:30',
            footer: TextButton(onPressed: () {}, child: const Text('Ação')),
          ),
          const SizedBox(height: AppSpacing.sm),
          const AppointmentCard(
            doctorName: 'Dr. Rafael Costa',
            specialty: 'Ortopedia',
            date: 'Ter, 17 nov 2026',
            time: 'Às 15:00',
            status: 'Cancelada',
          ),
        ],
      ),
      height: 600,
    );
  });

  testWidgets('DateChip e TimeSlotButton', (tester) async {
    await golden(
      tester,
      'scheduling',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            children: [
              const DateChip(weekday: 'Ter', day: 24, enabled: false),
              DateChip(weekday: 'Qua', day: 25, onTap: () {}),
              DateChip(weekday: 'Qui', day: 26, selected: true, onTap: () {}),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: TimeSlotButton(time: '08:00', onTap: () {}),
              ),
              const SizedBox(width: AppSpacing.ms),
              const Expanded(
                child: TimeSlotButton(time: '08:30', available: false),
              ),
              const SizedBox(width: AppSpacing.ms),
              Expanded(
                child: TimeSlotButton(
                  time: '09:00',
                  selected: true,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
      height: 200,
    );
  });

  testWidgets('AppDialog de confirmação', (tester) async {
    await golden(
      tester,
      'app_dialog',
      const AppDialog(
        title: 'Cancelar consulta?',
        message: 'Dra. Helena Ribeiro',
        buttonLabel: 'Cancelar consulta',
        secondaryLabel: 'Manter consulta',
        icon: Icons.event_busy,
        destructive: true,
      ),
      width: 520,
      height: 460,
    );
  });

  testWidgets('AppBottomNavigation e SkeletonCard', (tester) async {
    await golden(
      tester,
      'navigation_skeleton',
      Column(
        children: [
          const SkeletonCard(),
          const Spacer(),
          AppBottomNavigation(
            currentIndex: 1,
            onTap: (_) {},
            items: const [
              AppNavItem(
                label: 'Home',
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
              ),
              AppNavItem(
                label: 'Consultas',
                icon: Icons.calendar_month_outlined,
                selectedIcon: Icons.calendar_month,
              ),
              AppNavItem(
                label: 'Perfil',
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
              ),
            ],
          ),
        ],
      ),
      height: 300,
    );
  });
}

/// Comparador que aceita uma pequena diferença de pixels.
class _TolerantComparator extends LocalFileComparator {
  _TolerantComparator(super.testFile);

  static const _maxDiff = 0.01; // 1%

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (result.passed || result.diffPercent <= _maxDiff) {
      result.dispose();
      return true;
    }
    final error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError(error);
  }
}
