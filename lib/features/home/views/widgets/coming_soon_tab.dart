import 'package:flutter/material.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';

/// Aba que ainda não foi implementada (Consultas e Histórico).
class ComingSoonTab extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const ComingSoonTab({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: AppColors.secondary),
              const SizedBox(height: AppSpacing.md),
              Text(title, style: AppTypography.title),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTypography.subtitle,
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text('Em desenvolvimento.', style: AppTypography.caption),
            ],
          ),
        ),
      ),
    );
  }
}
