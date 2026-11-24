import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import 'app_button.dart';

/// Diálogo de confirmação ou aviso do app.
class AppDialog extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String buttonLabel;

  const AppDialog({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.check_circle_outline,
    this.iconColor = AppColors.success,
    this.buttonLabel = 'OK',
  });

  /// Mostra o diálogo e espera o usuário fechar.
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    IconData icon = Icons.check_circle_outline,
    Color iconColor = AppColors.success,
    String buttonLabel = 'OK',
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AppDialog(
        title: title,
        message: message,
        icon: icon,
        iconColor: iconColor,
        buttonLabel: buttonLabel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: iconColor),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTypography.title,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTypography.body,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: buttonLabel,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
