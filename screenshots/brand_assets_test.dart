// Gera as imagens da marca a partir do design system:
//
//   flutter test screenshots/brand_assets_test.dart --update-goldens
//
// Saída em assets/brand/. Depois:
//   dart run flutter_launcher_icons   (ícones do app)
//   dart run flutter_native_splash:create   (tela de abertura)
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saude_ja_design_system/saude_ja_design_system.dart';

const _size = 1024.0;

void main() {
  setUpAll(_loadIconFont);

  Future<void> render(WidgetTester tester, String name, Widget child) async {
    tester.view.physicalSize = const Size(_size, _size);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(
            child: SizedBox.square(dimension: _size, child: child),
          ),
        ),
      ),
    );
    await expectLater(
      find.byType(RepaintBoundary).first,
      matchesGoldenFile('../assets/brand/$name.png'),
    );
  }

  // Ícone completo (iOS, web e Android antigo): fundo verde, escudo branco.
  testWidgets('icon', (tester) async {
    await render(
      tester,
      'icon',
      ColoredBox(
        color: AppColors.light.primary,
        child: Center(
          child: Icon(
            Icons.health_and_safety_outlined,
            size: _size * 0.62,
            color: AppColors.light.onPrimary,
          ),
        ),
      ),
    );
  });

  // Frente do ícone adaptativo do Android: só o escudo, menor, porque o
  // sistema recorta a imagem em círculo, gota etc.
  testWidgets('icon_foreground', (tester) async {
    await render(
      tester,
      'icon_foreground',
      Center(
        child: Icon(
          Icons.health_and_safety_outlined,
          size: _size * 0.42,
          color: AppColors.light.onPrimary,
        ),
      ),
    );
  });

  // Tela de abertura: escudo verde num círculo verde-claro, como o logo
  // da tela de Login.
  testWidgets('splash', (tester) async {
    await render(
      tester,
      'splash',
      Center(
        child: Container(
          width: _size * 0.6,
          height: _size * 0.6,
          decoration: BoxDecoration(
            color: AppColors.light.secondary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.health_and_safety_outlined,
            size: _size * 0.33,
            color: AppColors.light.primary,
          ),
        ),
      ),
    );
  });
}

Future<void> _loadIconFont() async {
  final root =
      Platform.environment['FLUTTER_ROOT'] ??
      Platform.resolvedExecutable
          .replaceAll('\\', '/')
          .split('/bin/cache/')
          .first;
  final bytes = File(
    '$root/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
  ).readAsBytesSync();
  final loader = FontLoader('MaterialIcons')
    ..addFont(Future.value(ByteData.view(bytes.buffer)));
  await loader.load();
}
