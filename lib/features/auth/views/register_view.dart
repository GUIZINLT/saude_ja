import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/app_routes.dart';
import '../../../design_system/components/app_button.dart';
import '../../../design_system/components/app_text_field.dart';
import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../../../design_system/tokens/app_typography.dart';
import '../viewmodels/register_viewmodel.dart';
import 'widgets/form_error_banner.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  Future<void> _submit(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final ok = await context.read<RegisterViewModel>().submit();
    if (ok && context.mounted) {
      // A conta já entra logada: vai para a Home e limpa a pilha.
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegisterViewModel>();

    final passwordToggle = IconButton(
      tooltip: vm.obscurePassword ? 'Mostrar senha' : 'Ocultar senha',
      icon: Icon(
        vm.obscurePassword
            ? Icons.visibility_outlined
            : Icons.visibility_off_outlined,
      ),
      onPressed: vm.togglePasswordVisibility,
    );

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Criar conta', style: AppTypography.heading),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Preencha seus dados para agendar consultas.',
                  style: AppTypography.subtitle,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'Nome completo',
                  hint: 'Como está no documento',
                  prefixIcon: Icons.person_outline,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  errorText: vm.nameError,
                  onChanged: vm.setName,
                  enabled: !vm.isLoading,
                ),
                const SizedBox(height: AppSpacing.md),
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
                  label: 'Telefone',
                  hint: '(63) 99999-0000',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  errorText: vm.phoneError,
                  onChanged: vm.setPhone,
                  enabled: !vm.isLoading,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Senha',
                  hint: 'Mínimo de 6 caracteres',
                  prefixIcon: Icons.lock_outline,
                  obscureText: vm.obscurePassword,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  errorText: vm.passwordError,
                  onChanged: vm.setPassword,
                  enabled: !vm.isLoading,
                  suffixIcon: passwordToggle,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Confirmar senha',
                  hint: 'Repita a senha',
                  prefixIcon: Icons.lock_outline,
                  obscureText: vm.obscurePassword,
                  textInputAction: TextInputAction.done,
                  errorText: vm.confirmPasswordError,
                  onChanged: vm.setConfirmPassword,
                  onSubmitted: (_) => _submit(context),
                  enabled: !vm.isLoading,
                ),
                const SizedBox(height: AppSpacing.sm),
                _TermsCheckbox(
                  value: vm.acceptedTerms,
                  errorText: vm.termsError,
                  onChanged: vm.isLoading ? null : vm.setAcceptedTerms,
                ),
                if (vm.errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  FormErrorBanner(message: vm.errorMessage!),
                ],
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Criar conta',
                  isLoading: vm.isLoading,
                  onPressed: () => _submit(context),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Já tem conta?', style: AppTypography.body),
                    TextButton(
                      onPressed: vm.isLoading
                          ? null
                          : () => Navigator.of(
                              context,
                            ).pushReplacementNamed(AppRoutes.login),
                      child: const Text('Entrar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TermsCheckbox extends StatelessWidget {
  final bool value;
  final String? errorText;
  final ValueChanged<bool>? onChanged;

  const _TermsCheckbox({
    required this.value,
    required this.errorText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onChanged == null ? null : () => onChanged!(!value),
          child: Row(
            children: [
              Checkbox(
                value: value,
                activeColor: AppColors.primary,
                onChanged: onChanged == null
                    ? null
                    : (v) => onChanged!(v ?? false),
              ),
              const Expanded(
                child: Text(
                  'Li e aceito os termos de uso',
                  style: AppTypography.body,
                ),
              ),
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.md),
            child: Text(
              errorText!,
              style: AppTypography.caption.copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }
}
