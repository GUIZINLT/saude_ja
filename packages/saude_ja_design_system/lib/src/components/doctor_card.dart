import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

class DoctorCard extends StatelessWidget {
  final String name;
  final String specialty;
  final double rating;
  final VoidCallback? onTap;

  const DoctorCard({
    super.key,
    required this.name,
    required this.specialty,
    this.rating = 5.0,
    this.onTap,
  });

  /// Nota com uma casa e vírgula: 4,9.
  String get _ratingText => rating.toStringAsFixed(1).replaceAll('.', ',');

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: '$name, $specialty, nota $_ratingText',
      onTap: onTap,
      excludeSemantics: true,
      child: Card(
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
            padding: const EdgeInsets.all(AppSpacing.ms),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: context.colors.secondary.withValues(
                    alpha: 0.2,
                  ),
                  child: Icon(
                    Icons.person,
                    color: context.colors.primary,
                    size: 30,
                  ),
                ),
                const SizedBox(width: AppSpacing.ms),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: context.typography.bodyStrong),
                      const SizedBox(height: AppSpacing.xs),
                      Text(specialty, style: context.typography.bodySmall),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: context.colors.rating,
                            size: 17,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(_ratingText, style: context.typography.body),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: context.colors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
