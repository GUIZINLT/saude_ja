import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saude_ja_design_system/saude_ja_design_system.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/utils/phone_formatter.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/auth_repository.dart';

/// Perfil simples: dados do paciente e botão Sair.
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthRepository>().currentUser;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: _buildContent(context, user),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, User? user) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('Perfil', style: context.typography.heading),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoRow(icon: Icons.person_outline, text: user?.name ?? '-'),
              const Divider(height: AppSpacing.lg),
              _InfoRow(icon: Icons.email_outlined, text: user?.email ?? '-'),
              const Divider(height: AppSpacing.lg),
              _InfoRow(
                icon: Icons.phone_outlined,
                text: user == null ? '-' : PhoneFormatter.format(user.phone),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Aparência', style: context.typography.title),
        const SizedBox(height: AppSpacing.sm),
        const _ThemeSelector(),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: 'Sair',
          isSecondary: true,
          icon: Icons.logout,
          onPressed: () {
            context.read<AuthRepository>().logout();
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
          },
        ),
      ],
    );
  }
}

/// Escolha do tema: Sistema, Claro ou Escuro.
class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector();

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<ThemeMode>(
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(
            value: ThemeMode.system,
            icon: Icon(Icons.brightness_auto_outlined),
            label: Text('Sistema'),
          ),
          ButtonSegment(
            value: ThemeMode.light,
            icon: Icon(Icons.light_mode_outlined),
            label: Text('Claro'),
          ),
          ButtonSegment(
            value: ThemeMode.dark,
            icon: Icon(Icons.dark_mode_outlined),
            label: Text('Escuro'),
          ),
        ],
        selected: {theme.mode},
        onSelectionChanged: (selection) => theme.setMode(selection.first),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: context.colors.primary, size: 20),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: Text(text, style: context.typography.body)),
      ],
    );
  }
}
