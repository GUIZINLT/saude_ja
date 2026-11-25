import 'package:flutter/material.dart';

/// Paleta de cores do SaúdeJá, com versão clara e escura.
///
/// Fica no tema do Flutter (ThemeExtension). Nos widgets, use:
///
/// ```dart
/// context.colors.primary
/// ```
///
/// Todas as combinações de texto e fundo têm contraste mínimo de 4,5:1
/// (WCAG AA), conferido em test/accessibility/contrast_test.dart.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.success,
    required this.warning,
    required this.error,
    required this.border,
    required this.disabled,
    required this.onPrimary,
    required this.onError,
    required this.rating,
  });

  // Cores principais
  final Color primary;
  final Color secondary;

  // Fundos
  final Color background;
  final Color surface;

  // Texto
  final Color textPrimary;
  final Color textSecondary;

  // Estados
  final Color success;
  final Color warning;
  final Color error;

  // Elementos
  final Color border;
  final Color disabled;

  /// Texto e ícones sobre a cor principal (botões, item escolhido).
  final Color onPrimary;

  /// Texto sobre a cor de erro (botão destrutivo).
  final Color onError;

  /// Estrela da nota dos médicos.
  final Color rating;

  static const light = AppColors(
    primary: Color(0xFF137E66),
    secondary: Color(0xFF66C6A5),
    background: Color(0xFFF3FAF7),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF263D37),
    textSecondary: Color(0xFF5F706A),
    success: Color(0xFF2E9D67),
    warning: Color(0xFFE8A23A),
    error: Color(0xFFC0392B),
    border: Color(0xFFE1EBE6),
    disabled: Color(0xFFB8C8C0),
    onPrimary: Color(0xFFFFFFFF),
    onError: Color(0xFFFFFFFF),
    rating: Color(0xFFF5B301),
  );

  static const dark = AppColors(
    primary: Color(0xFF4FC9A3),
    secondary: Color(0xFF66C6A5),
    background: Color(0xFF0F1A17),
    surface: Color(0xFF172521),
    textPrimary: Color(0xFFE3EFEA),
    textSecondary: Color(0xFF9DB2AA),
    success: Color(0xFF4CC08A),
    warning: Color(0xFFF0B357),
    error: Color(0xFFF07B76),
    border: Color(0xFF2A3B36),
    disabled: Color(0xFF4A5C56),
    onPrimary: Color(0xFF0B2620),
    onError: Color(0xFF0B2620),
    rating: Color(0xFFF5B301),
  );

  /// Paleta do tema atual (clara se o tema não tiver a extensão).
  static AppColors of(BuildContext context) =>
      Theme.of(context).extension<AppColors>() ?? light;

  @override
  AppColors copyWith({
    Color? primary,
    Color? secondary,
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? success,
    Color? warning,
    Color? error,
    Color? border,
    Color? disabled,
    Color? onPrimary,
    Color? onError,
    Color? rating,
  }) => AppColors(
    primary: primary ?? this.primary,
    secondary: secondary ?? this.secondary,
    background: background ?? this.background,
    surface: surface ?? this.surface,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    error: error ?? this.error,
    border: border ?? this.border,
    disabled: disabled ?? this.disabled,
    onPrimary: onPrimary ?? this.onPrimary,
    onError: onError ?? this.onError,
    rating: rating ?? this.rating,
  );

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      primary: mix(primary, other.primary),
      secondary: mix(secondary, other.secondary),
      background: mix(background, other.background),
      surface: mix(surface, other.surface),
      textPrimary: mix(textPrimary, other.textPrimary),
      textSecondary: mix(textSecondary, other.textSecondary),
      success: mix(success, other.success),
      warning: mix(warning, other.warning),
      error: mix(error, other.error),
      border: mix(border, other.border),
      disabled: mix(disabled, other.disabled),
      onPrimary: mix(onPrimary, other.onPrimary),
      onError: mix(onError, other.onError),
      rating: mix(rating, other.rating),
    );
  }
}

/// Atalhos para os tokens do tema atual.
extension AppThemeContext on BuildContext {
  AppColors get colors => AppColors.of(this);
}
