import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import 'app_button.dart';

/// Diálogo de confirmação ou aviso do app.
class AppDialog extends StatelessWidget {
  final IconData icon;

  /// Cor do ícone (padrão: verde de sucesso do tema).
  final Color? iconColor;
  final String title;
  final String message;
  final String buttonLabel;

  /// Com valor, mostra um segundo botão (ex.: "Voltar") e o diálogo vira
  /// uma confirmação: fecha com true no botão principal e false no outro.
  final String? secondaryLabel;

  /// Pinta o botão principal de vermelho (ações como cancelar).
  final bool destructive;

  const AppDialog({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.check_circle_outline,
    this.iconColor,
    this.buttonLabel = 'OK',
    this.secondaryLabel,
    this.destructive = false,
  });

  /// Pergunta antes de uma ação. Devolve true se o usuário confirmou.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    String cancelLabel = 'Voltar',
    IconData icon = Icons.help_outline,
    Color? iconColor,
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AppDialog(
        title: title,
        message: message,
        icon: icon,
        iconColor: iconColor,
        buttonLabel: confirmLabel,
        secondaryLabel: cancelLabel,
        destructive: destructive,
      ),
    );
    return result ?? false;
  }

  /// Mostra o diálogo e espera o usuário fechar.
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    IconData icon = Icons.check_circle_outline,
    Color? iconColor,
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
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: iconColor ?? context.colors.success),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                textAlign: TextAlign.center,
                style: context.typography.title,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: context.typography.body,
              ),
              const SizedBox(height: AppSpacing.lg),
              _PrimaryButton(
                label: buttonLabel,
                destructive: destructive,
                onPressed: () => Navigator.of(
                  context,
                ).pop(secondaryLabel == null ? null : true),
              ),
              if (secondaryLabel != null) ...[
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: secondaryLabel!,
                  isSecondary: true,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool destructive;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.label,
    required this.destructive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (!destructive) return AppButton(label: label, onPressed: onPressed);
    // O AppButton fixa a cor primária; para ações destrutivas usamos o
    // mesmo formato com a cor de erro.
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: context.colors.error,
          foregroundColor: context.colors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
