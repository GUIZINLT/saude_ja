import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/app_routes.dart';
import '../../../design_system/components/app_button.dart';
import '../../../design_system/components/app_text_field.dart';
import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../../../design_system/tokens/app_typography.dart';
import '../viewmodels/login_viewmodel.dart';
import 'widgets/form_error_banner.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  Future<void> _submit(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final ok = await context.read<LoginViewModel>().submit();
    if (ok && context.mounted) {
      unawaited(Navigator.of(context).pushReplacementNamed(AppRoutes.home));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _Logo(),
                      const SizedBox(height: AppSpacing.xl),
                      AppTextField(
                        label: 'E-mail',
                        hint: 'seuemail@exemplo.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        errorText: vm.emailError,
                        onChanged: vm.setEmail,
                        enabled: !vm.isLoading,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        label: 'Senha',
                        hint: 'Digite sua senha',
                        prefixIcon: Icons.lock_outline,
                        obscureText: vm.obscurePassword,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        errorText: vm.passwordError,
                        onChanged: vm.setPassword,
                        onSubmitted: (_) => _submit(context),
                        enabled: !vm.isLoading,
                        suffixIcon: IconButton(
                          tooltip: vm.obscurePassword
                              ? 'Mostrar senha'
                              : 'Ocultar senha',
                          icon: Icon(
                            vm.obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: vm.togglePasswordVisibility,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () =>
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Recuperação de senha ainda não disponível.',
                                  ),
                                ),
                              ),
                          child: const Text('Esqueci minha senha'),
                        ),
                      ),
                      if (vm.errorMessage != null) ...[
                        FormErrorBanner(message: vm.errorMessage!),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      const SizedBox(height: AppSpacing.sm),
                      AppButton(
                        label: 'Entrar',
                        isLoading: vm.isLoading,
                        onPressed: () => _submit(context),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppButton(
                        label: 'Criar conta',
                        isSecondary: true,
                        onPressed: vm.isLoading
                            ? null
                            : () => Navigator.of(
                                context,
                              ).pushNamed(AppRoutes.register),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.health_and_safety_outlined,
            color: AppColors.primary,
            size: 48,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'SaúdeJá',
          style: AppTypography.heading.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: AppSpacing.xs),
        const Text(
          'Sua saúde em primeiro lugar.',
          style: AppTypography.subtitle,
        ),
      ],
    );
  }
}
