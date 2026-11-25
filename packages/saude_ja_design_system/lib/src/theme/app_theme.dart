import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

/// Temas claro e escuro do SaúdeJá, montados a partir dos tokens.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => _build(AppColors.light, Brightness.light);

  static ThemeData get darkTheme => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors colors, Brightness brightness) {
    final typography = AppTypography.fromColors(colors);
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: colors.border),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      extensions: [colors, typography],

      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.primary,
        brightness: brightness,
        primary: colors.primary,
        onPrimary: colors.onPrimary,
        secondary: colors.secondary,
        surface: colors.surface,
        onSurface: colors.textPrimary,
        onSurfaceVariant: colors.textSecondary,
        error: colors.error,
        onError: colors.onError,
        outline: colors.border,
      ),

      scaffoldBackgroundColor: colors.background,

      textTheme: TextTheme(
        headlineSmall: typography.heading,
        titleLarge: typography.title,
        titleMedium: typography.subtitle,
        bodyMedium: typography.body,
        bodySmall: typography.caption,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),

      dialogTheme: DialogThemeData(backgroundColor: colors.surface),

      dividerTheme: DividerThemeData(color: colors.border),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.textPrimary,
        contentTextStyle: typography.body.copyWith(color: colors.background),
        behavior: SnackBarBehavior.floating,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        hintStyle: typography.body.copyWith(color: colors.textSecondary),
        labelStyle: typography.body.copyWith(color: colors.textSecondary),
        prefixIconColor: colors.textSecondary,
        suffixIconColor: colors.textSecondary,
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
      ),
    );
  }
}
