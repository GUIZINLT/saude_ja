import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Estilos de texto do SaúdeJá, já com a cor certa para o tema atual.
///
/// Fica no tema do Flutter (ThemeExtension). Nos widgets, use:
///
/// ```dart
/// context.typography.title
/// ```
@immutable
class AppTypography extends ThemeExtension<AppTypography> {
  const AppTypography({
    required this.heading,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.caption,
    required this.titleSmall,
    required this.bodyStrong,
    required this.bodySmall,
    required this.label,
    required this.labelSmall,
    required this.badge,
    required this.number,
  });

  /// Cria os estilos com as cores de [colors].
  factory AppTypography.fromColors(AppColors colors) {
    TextStyle style(double size, FontWeight weight, Color color) =>
        TextStyle(fontSize: size, fontWeight: weight, color: color);
    final primary = colors.textPrimary;
    final secondary = colors.textSecondary;
    return AppTypography(
      heading: style(26, FontWeight.bold, primary),
      title: style(20, FontWeight.w600, primary),
      subtitle: style(16, FontWeight.w500, secondary),
      body: style(14, FontWeight.normal, primary),
      caption: style(12, FontWeight.normal, secondary),
      titleSmall: style(16, FontWeight.bold, primary),
      bodyStrong: style(15, FontWeight.bold, primary),
      bodySmall: style(13, FontWeight.normal, secondary),
      label: style(13, FontWeight.w600, primary),
      labelSmall: style(12, FontWeight.w600, primary),
      badge: style(11, FontWeight.w600, secondary),
      number: style(20, FontWeight.bold, primary),
    );
  }

  /// Título da tela (26, negrito).
  final TextStyle heading;

  /// Título de seção (20, semibold).
  final TextStyle title;

  /// Texto de apoio abaixo do título (16, secundário).
  final TextStyle subtitle;

  /// Texto comum (14).
  final TextStyle body;

  /// Legenda (12, secundário).
  final TextStyle caption;

  /// Nome do médico no card de consulta (16, negrito).
  final TextStyle titleSmall;

  /// Nome em cards compactos (15, negrito).
  final TextStyle bodyStrong;

  /// Informação secundária, como a especialidade (13).
  final TextStyle bodySmall;

  /// Rótulo de item, como o nome da especialidade (13, semibold).
  final TextStyle label;

  /// Rótulo pequeno: menu inferior e dia da semana (12, semibold).
  final TextStyle labelSmall;

  /// Selo de status ("Confirmada") (11, semibold).
  final TextStyle badge;

  /// Número em destaque, como o dia no seletor de datas (20, negrito).
  final TextStyle number;

  static final light = AppTypography.fromColors(AppColors.light);
  static final dark = AppTypography.fromColors(AppColors.dark);

  static AppTypography of(BuildContext context) =>
      Theme.of(context).extension<AppTypography>() ?? light;

  @override
  AppTypography copyWith({
    TextStyle? heading,
    TextStyle? title,
    TextStyle? subtitle,
    TextStyle? body,
    TextStyle? caption,
    TextStyle? titleSmall,
    TextStyle? bodyStrong,
    TextStyle? bodySmall,
    TextStyle? label,
    TextStyle? labelSmall,
    TextStyle? badge,
    TextStyle? number,
  }) => AppTypography(
    heading: heading ?? this.heading,
    title: title ?? this.title,
    subtitle: subtitle ?? this.subtitle,
    body: body ?? this.body,
    caption: caption ?? this.caption,
    titleSmall: titleSmall ?? this.titleSmall,
    bodyStrong: bodyStrong ?? this.bodyStrong,
    bodySmall: bodySmall ?? this.bodySmall,
    label: label ?? this.label,
    labelSmall: labelSmall ?? this.labelSmall,
    badge: badge ?? this.badge,
    number: number ?? this.number,
  );

  @override
  AppTypography lerp(AppTypography? other, double t) {
    if (other == null) return this;
    TextStyle mix(TextStyle a, TextStyle b) => TextStyle.lerp(a, b, t)!;
    return AppTypography(
      heading: mix(heading, other.heading),
      title: mix(title, other.title),
      subtitle: mix(subtitle, other.subtitle),
      body: mix(body, other.body),
      caption: mix(caption, other.caption),
      titleSmall: mix(titleSmall, other.titleSmall),
      bodyStrong: mix(bodyStrong, other.bodyStrong),
      bodySmall: mix(bodySmall, other.bodySmall),
      label: mix(label, other.label),
      labelSmall: mix(labelSmall, other.labelSmall),
      badge: mix(badge, other.badge),
      number: mix(number, other.number),
    );
  }
}

/// Atalho para os estilos de texto do tema atual.
extension AppTypographyContext on BuildContext {
  AppTypography get typography => AppTypography.of(this);
}
