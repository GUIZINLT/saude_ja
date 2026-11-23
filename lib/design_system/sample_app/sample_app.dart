import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../components/app_button.dart';
import '../components/app_text_field.dart';
import '../components/app_card.dart';

class SampleApp extends StatefulWidget {
  const SampleApp({super.key});

  @override
  State<SampleApp> createState() => _SampleAppState();
}

class _SampleAppState extends State<SampleApp> {
  int selectedIndex = 0;

  final TextEditingController nameController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SaúdeJá | Design System',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.md),

            const Text(
              'Bem-vindo ao SaúdeJá!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Sua saúde em primeiro lugar.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
            ),

            const SizedBox(height: AppSpacing.xl),

            _buildSectionTitle('Paleta de cores'),

            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                _buildColor(AppColors.primary, 'Principal'),
                _buildColor(AppColors.secondary, 'Secundária'),
                _buildColor(AppColors.background, 'Fundo'),
                _buildColor(AppColors.textPrimary, 'Texto'),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            _buildSectionTitle('Botões'),

            const SizedBox(height: AppSpacing.md),

            AppButton(
              label: 'Agendar consulta',
              icon: Icons.calendar_month,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Botão principal funcionando!')),
                );
              },
            ),

            const SizedBox(height: AppSpacing.md),

            AppButton(label: 'Cancelar', isSecondary: true, onPressed: () {}),

            const SizedBox(height: AppSpacing.xl),

            _buildSectionTitle('Campos de formulário'),

            const SizedBox(height: AppSpacing.md),

            AppTextField(
              label: 'Nome completo',
              hint: 'Digite seu nome',
              prefixIcon: Icons.person_outline,
              controller: nameController,
            ),

            const SizedBox(height: AppSpacing.md),

            const AppTextField(
              label: 'E-mail',
              hint: 'exemplo@email.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: AppSpacing.xl),

            _buildSectionTitle('Cards'),

            const SizedBox(height: AppSpacing.md),

            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.medical_services_outlined,
                        color: AppColors.primary,
                        size: 30,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Consulta médica',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Agende suas consultas de maneira simples '
                    'e acompanhe seus atendimentos.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),

                  const SizedBox(height: 16),

                  AppButton(label: 'Ver consultas', onPressed: () {}),
                ],
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Consultas',
          ),
          NavigationDestination(icon: Icon(Icons.history), label: 'Histórico'),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildColor(Color color, String label) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 48,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }
}
