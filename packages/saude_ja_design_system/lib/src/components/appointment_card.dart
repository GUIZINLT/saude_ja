import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

class AppointmentCard extends StatelessWidget {
  final String doctorName;
  final String specialty;
  final String date;
  final String time;
  final String status;
  final VoidCallback? onTap;

  /// Área opcional no fim do card, por exemplo um botão de ação.
  final Widget? footer;

  const AppointmentCard({
    super.key,
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.time,
    this.status = 'Confirmada',
    this.onTap,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.colors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: context.colors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                label:
                    'Consulta $status, $date, $time, $doctorName, '
                    '$specialty',
                excludeSemantics: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month,
                          color: context.colors.primary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            date,
                            style: context.typography.body.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _buildStatus(context),
                      ],
                    ),
                    const Divider(height: AppSpacing.lg),
                    Text(doctorName, style: context.typography.titleSmall),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      specialty,
                      style: context.typography.body.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.ms),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: context.colors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(time, style: context.typography.body),
                      ],
                    ),
                  ],
                ),
              ),
              if (footer != null) ...[
                const Divider(height: AppSpacing.lg),
                footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatus(BuildContext context) {
    final normalized = status.toLowerCase();
    final (Color background, Color foreground) = switch (normalized) {
      'confirmada' => (
        context.colors.secondary.withValues(alpha: 0.2),
        context.colors.primary,
      ),
      'cancelada' => (
        context.colors.error.withValues(alpha: 0.1),
        context.colors.error,
      ),
      _ => (context.colors.background, context.colors.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + AppSpacing.xxs,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Text(
        status,
        style: context.typography.badge.copyWith(color: foreground),
      ),
    );
  }
}
