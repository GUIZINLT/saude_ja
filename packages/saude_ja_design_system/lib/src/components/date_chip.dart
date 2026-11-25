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
      background = context.colors.primary;
      foreground = context.colors.onPrimary;
      border = context.colors.primary;
    } else if (enabled) {
      background = context.colors.surface;
      foreground = context.colors.textPrimary;
      border = context.colors.border;
    } else {
      background = context.colors.disabled.withValues(alpha: 0.18);
      foreground = context.colors.textSecondary;
      border = context.colors.border;
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
          // Tamanho mínimo de 58x72; cresce com a fonte do aparelho.
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 58, minHeight: 72),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weekday,
                    style: context.typography.labelSmall.copyWith(
                      color: foreground,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '$day',
                    style: context.typography.number.copyWith(
                      color: foreground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
