import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:saude_ja_design_system/saude_ja_design_system.dart';

import '../viewmodels/forgot_password_viewmodel.dart';
import 'widgets/form_error_banner.dart';

/// "Esqueci minha senha": pede um código por e-mail e troca a senha.
class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  Future<void> _requestCode(BuildContext context) async {
    FocusScope.of(context).unfocus();
    await context.read<ForgotPasswordViewModel>().requestCode();
  }

  Future<void> _reset(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final ok = await context.read<ForgotPasswordViewModel>().resetPassword();
    if (!ok || !context.mounted) return;
    await AppDialog.show(
      context,
      title: 'Senha alterada!',
      message: 'Entre com o seu e-mail e a nova senha.',
      buttonLabel: 'Ir para o login',
    );
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ForgotPasswordViewModel>();

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
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AutofillGroup(
                child: vm.step == ForgotPasswordStep.email
                    ? _EmailStep(onSubmit: () => _requestCode(context))
                    : _ResetStep(onSubmit: () => _reset(context)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailStep extends StatelessWidget {
  final VoidCallback onSubmit;

  const _EmailStep({required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ForgotPasswordViewModel>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Esqueci minha senha', style: context.typography.heading),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Informe o e-mail da sua conta. Vamos enviar um código para você '
          'criar uma nova senha.',
          style: context.typography.subtitle,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: 'E-mail',
          hint: 'seuemail@exemplo.com',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.send,
          autofillHints: const [AutofillHints.email],
          errorText: vm.emailError,
          onChanged: vm.setEmail,
          onSubmitted: (_) => onSubmit(),
          enabled: !vm.isLoading,
        ),
        if (vm.errorMessage != null) ...[
          const SizedBox(height: AppSpacing.md),
          FormErrorBanner(message: vm.errorMessage!),
        ],
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: 'Enviar código',
          isLoading: vm.isLoading,
          onPressed: onSubmit,
        ),
      ],
    );
  }
}

class _ResetStep extends StatelessWidget {
  final VoidCallback onSubmit;

  const _ResetStep({required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ForgotPasswordViewModel>();
    final passwordToggle = IconButton(
      tooltip: vm.obscurePassword ? 'Mostrar senha' : 'Ocultar senha',
      icon: Icon(
        vm.obscurePassword
            ? Icons.visibility_outlined
            : Icons.visibility_off_outlined,
      ),
      onPressed: vm.togglePasswordVisibility,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Nova senha', style: context.typography.heading),
        const SizedBox(height: AppSpacing.xs),
        Text(
          vm.info ?? 'Digite o código que enviamos para ${vm.email}.',
          style: context.typography.subtitle,
        ),
        if (vm.devCode != null) ...[
          const SizedBox(height: AppSpacing.md),
          _DemoCodeBanner(code: vm.devCode!),
        ],
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          label: 'Código',
          hint: '6 dígitos',
          prefixIcon: Icons.pin_outlined,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.oneTimeCode],
          errorText: vm.codeError,
          onChanged: vm.setCode,
          enabled: !vm.isLoading,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Nova senha',
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
          label: 'Confirmar nova senha',
          hint: 'Repita a senha',
          prefixIcon: Icons.lock_outline,
          obscureText: vm.obscurePassword,
          textInputAction: TextInputAction.done,
          errorText: vm.confirmPasswordError,
          onChanged: vm.setConfirmPassword,
          onSubmitted: (_) => onSubmit(),
          enabled: !vm.isLoading,
        ),
        if (vm.errorMessage != null) ...[
          const SizedBox(height: AppSpacing.md),
          FormErrorBanner(message: vm.errorMessage!),
        ],
        const SizedBox(height: AppSpacing.lg),
        AppButton(
          label: 'Redefinir senha',
          isLoading: vm.isLoading,
          onPressed: onSubmit,
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: vm.isLoading ? null : vm.restart,
          child: const Text('Pedir outro código'),
        ),
      ],
    );
  }
}

/// No mock não há envio de e-mail: o código aparece aqui para dar para
/// testar o fluxo.
class _DemoCodeBanner extends StatelessWidget {
  final String code;

  const _DemoCodeBanner({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.ms),
      decoration: BoxDecoration(
        color: context.colors.secondary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(Icons.science_outlined, color: context.colors.primary),
          const SizedBox(width: AppSpacing.ms),
          Expanded(
            child: Text(
              'Modo de demonstração: o código é $code. Com um servidor '
              'real, ele chegaria por e-mail.',
              style: context.typography.body,
            ),
          ),
        ],
      ),
    );
  }
}
