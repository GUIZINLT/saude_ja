import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_typography.dart';

/// Botão de horário da grade de agendamento.
///
/// Livre: branco com borda clara. Ocupado: cinza claro e riscado.
/// Escolhido: verde.
class TimeSlotButton extends StatelessWidget {
  final String time;
  final bool available;
  final bool selected;
  final VoidCallback? onTap;

  const TimeSlotButton({
    super.key,
    required this.time,
    this.available = true,
    this.selected = false,
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
    } else if (available) {
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
      enabled: available,
      label: available ? 'Horário $time' : 'Horário $time indisponível',
      excludeSemantics: true,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: border),
        ),
        child: InkWell(
          onTap: available ? onTap : null,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: SizedBox(
            height: 44,
            child: Center(
              child: Text(
                time,
                style: AppTypography.titleSmall.copyWith(
                  color: foreground,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  decoration: available ? null : TextDecoration.lineThrough,
                  decorationColor: foreground,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
