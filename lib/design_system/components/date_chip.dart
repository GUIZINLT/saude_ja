import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';

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
      foreground = Colors.white;
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
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: border),
        ),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            width: 58,
            height: 72,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  weekday,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$day',
                  style: TextStyle(
                    color: foreground,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
