import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saude_ja_design_system/saude_ja_design_system.dart';

/// Contraste mínimo de 4,5:1 (WCAG AA para texto comum) em todas as
/// combinações de texto e fundo das duas paletas.
void main() {
  double luminance(Color c) {
    double channel(double v) => v <= 0.03928
        ? v / 12.92
        : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
    return 0.2126 * channel(c.r) +
        0.7152 * channel(c.g) +
        0.0722 * channel(c.b);
  }

  double contrast(Color a, Color b) {
    final la = luminance(a);
    final lb = luminance(b);
    return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
  }

  for (final (name, c) in [
    ('clara', AppColors.light),
    ('escura', AppColors.dark),
  ]) {
    group('paleta $name', () {
      final pairs = <String, (Color, Color)>{
        'texto sobre o fundo': (c.textPrimary, c.background),
        'texto sobre cards': (c.textPrimary, c.surface),
        'texto secundário sobre o fundo': (c.textSecondary, c.background),
        'texto secundário sobre cards': (c.textSecondary, c.surface),
        'texto dos botões principais': (c.onPrimary, c.primary),
        'links e botões de texto sobre o fundo': (c.primary, c.background),
        'links e botões de texto sobre cards': (c.primary, c.surface),
        'mensagens de erro sobre cards': (c.error, c.surface),
        'texto do botão destrutivo': (c.onError, c.error),
      };
      for (final MapEntry(key: label, value: (fg, bg)) in pairs.entries) {
        test(label, () {
          final ratio = contrast(fg, bg);
          expect(
            ratio,
            greaterThanOrEqualTo(4.5),
            reason: '$label: ${ratio.toStringAsFixed(2)}:1',
          );
        });
      }
    });
  }
}
