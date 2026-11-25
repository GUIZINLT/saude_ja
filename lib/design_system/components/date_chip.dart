import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

/// Botão de dia do seletor de datas ("Qui / 26").
class DateChip extends StatelessWidget {
  final String weekday;
  final int day;
  final bool selected;

  /// false quando o dia não tem nenhum horário livre.
  final bool enabled;
  final VoidCallback? onTap;

  const DateChip({
    super.key,
    required this.weekday,
    required this.day,
    this.selected = false,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color background;
    final Color foreground;
    final Color border;
    if (selected) {
      background = AppColors.primary;
      foreground = AppColors.onPrimary;
      border = AppColors.primary;
    } else if (enabled) {
      background = AppColors.surface;
      foreground = AppColors.textPrimary;
      border = AppColors.border;
    } else {
      background = AppColors.disabled.withValues(alpha: 0.18);
      foreground = AppColors.textSecondary;
      border = AppColors.border;
    }

    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.chip),
          side: BorderSide(color: border),
        ),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          child: SizedBox(
            width: 58,
            height: 72,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  weekday,
                  style: AppTypography.labelSmall.copyWith(color: foreground),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '$day',
                  style: AppTypography.number.copyWith(color: foreground),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
