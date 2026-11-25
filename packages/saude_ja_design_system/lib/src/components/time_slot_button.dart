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
      background = context.colors.primary;
      foreground = context.colors.onPrimary;
      border = context.colors.primary;
    } else if (available) {
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
          // Altura mínima de 44; cresce com a fonte do aparelho.
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Center(
              child: Text(
                time,
                style: context.typography.titleSmall.copyWith(
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
