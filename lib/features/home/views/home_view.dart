import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../design_system/components/app_button.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../../../design_system/tokens/app_typography.dart';

/// Home provisória, só para fechar o fluxo de Login/Cadastro.
/// A Home completa (busca, especialidades, próxima consulta e menu
/// inferior) é a próxima etapa.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthRepository>().currentUser;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Olá, ${user?.firstName ?? 'paciente'}',
                style: AppTypography.heading,
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Como podemos ajudar hoje?',
                style: AppTypography.subtitle,
              ),
              const Spacer(),
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
          ),
        ),
      ),
    );
  }
}
