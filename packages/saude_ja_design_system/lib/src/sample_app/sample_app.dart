import 'package:flutter/material.dart';

import '../components/app_bottom_navigation.dart';
import '../components/app_button.dart';
import '../components/app_card.dart';
import '../components/app_dialog.dart';
import '../components/app_skeleton.dart';
import '../components/app_text_field.dart';
import '../components/appointment_card.dart';
import '../components/date_chip.dart';
import '../components/doctor_card.dart';
import '../components/specialty_card.dart';
import '../components/time_slot_button.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';

/// Vitrine do design system: tokens e todos os componentes, com os seus
/// estados (normal, escolhido, desabilitado, erro, carregando).
///
/// Para abrir direto: flutter run -t lib/main_design_system.dart
class SampleApp extends StatefulWidget {
  const SampleApp({super.key});

  @override
  State<SampleApp> createState() => _SampleAppState();
}

class _SampleAppState extends State<SampleApp> {
  int _navIndex = 0;
  int _selectedDay = 26;
  String? _selectedTime = '09:30';
  bool _loading = false;

  final _nameController = TextEditingController();

  static const _navItems = [
    AppNavItem(
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
    ),
    AppNavItem(
      label: 'Consultas',
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month,
    ),
    AppNavItem(
      label: 'Histórico',
      icon: Icons.history,
      selectedIcon: Icons.history,
    ),
    AppNavItem(
      label: 'Perfil',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
    ),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _toast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _simulateLoading() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _loading = false);
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Bem-vindo ao SaúdeJá!',
                  style: context.typography.heading,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Sua saúde em primeiro lugar.',
                  style: context.typography.subtitle,
                ),
                ..._colors(),
                ..._typography(),
                ..._buttons(),
                ..._fields(),
                ..._cards(),
                ..._scheduling(),
                ..._dialogs(),
                const _Section('Carregando'),
                Text(
                  'AppSkeleton e SkeletonCard: brilho animado no formato do conteúdo',
                  style: context.typography.caption,
                ),
                const SizedBox(height: AppSpacing.sm),
                const SkeletonCard(),
                const _Section('Menu inferior'),
                Text(
                  'AppBottomNavigation: o menu no rodapé desta tela.',
                  style: context.typography.body,
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigation(
        items: _navItems,
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }

  List<Widget> _colors() => [
    const _Section('Paleta de cores'),
    Row(
      children: [
        _ColorSwatch(context.colors.primary, 'Principal'),
        _ColorSwatch(context.colors.secondary, 'Secundária'),
        _ColorSwatch(context.colors.background, 'Fundo'),
        _ColorSwatch(context.colors.textPrimary, 'Texto'),
      ],
    ),
    const SizedBox(height: AppSpacing.md),
    Row(
      children: [
        _ColorSwatch(context.colors.success, 'Sucesso'),
        _ColorSwatch(context.colors.warning, 'Atenção'),
        _ColorSwatch(context.colors.error, 'Erro'),
        _ColorSwatch(context.colors.border, 'Borda'),
      ],
    ),
  ];

  List<Widget> _typography() => [
    const _Section('Tipografia'),
    Text('Título principal 26', style: context.typography.heading),
    Text('Título 20', style: context.typography.title),
    Text('Subtítulo 16', style: context.typography.subtitle),
    Text('Texto 14', style: context.typography.body),
    Text('Legenda 12', style: context.typography.caption),
  ];

  List<Widget> _buttons() => [
    const _Section('Botões'),
    AppButton(
      label: 'Agendar consulta',
      icon: Icons.calendar_month,
      onPressed: () => _toast('Botão principal funcionando!'),
    ),
    const SizedBox(height: AppSpacing.md),
    AppButton(label: 'Cancelar', isSecondary: true, onPressed: () {}),
    const SizedBox(height: AppSpacing.md),
    AppButton(
      label: 'Toque para ver o carregando',
      isLoading: _loading,
      onPressed: _simulateLoading,
    ),
    const SizedBox(height: AppSpacing.md),
    const AppButton(label: 'Desabilitado', onPressed: null),
  ];

  List<Widget> _fields() => [
    const _Section('Campos de formulário'),
    AppTextField(
      label: 'Nome completo',
      hint: 'Digite seu nome',
      prefixIcon: Icons.person_outline,
      controller: _nameController,
    ),
    const SizedBox(height: AppSpacing.md),
    const AppTextField(
      label: 'E-mail',
      hint: 'exemplo@email.com',
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      errorText: 'E-mail inválido.',
    ),
    const SizedBox(height: AppSpacing.md),
    const AppTextField(
      hint: 'Buscar médico ou especialidade',
      prefixIcon: Icons.search,
    ),
  ];

  List<Widget> _cards() => [
    const _Section('Cards'),
    AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.medical_services_outlined,
                color: context.colors.primary,
                size: 30,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text('Consulta médica', style: context.typography.title),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'AppCard: base dos cards, com borda e cantos arredondados.',
            style: context.typography.body,
          ),
          const SizedBox(height: 16),
          AppButton(label: 'Ver consultas', onPressed: () {}),
        ],
      ),
    ),
    const SizedBox(height: AppSpacing.md),
    Text('SpecialtyCard', style: context.typography.caption),
    const SizedBox(height: AppSpacing.sm),
    SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, s) in const [
              ('Cardiologia', Icons.favorite_outline),
              ('Dermatologia', Icons.face_outlined),
              ('Pediatria', Icons.child_care),
            ].indexed) ...[
              if (i > 0) const SizedBox(width: AppSpacing.sm),
              SpecialtyCard(title: s.$1, icon: s.$2, onTap: () => _toast(s.$1)),
            ],
          ],
        ),
      ),
    ),
    const SizedBox(height: AppSpacing.md),
    Text('DoctorCard', style: context.typography.caption),
    const SizedBox(height: AppSpacing.sm),
    DoctorCard(
      name: 'Dra. Helena Ribeiro',
      specialty: 'Cardiologia',
      rating: 4.9,
      onTap: () => _toast('Dra. Helena Ribeiro'),
    ),
    const SizedBox(height: AppSpacing.md),
    Text(
      'AppointmentCard: confirmada (com ação), realizada e cancelada',
      style: context.typography.caption,
    ),
    const SizedBox(height: AppSpacing.sm),
    AppointmentCard(
      doctorName: 'Dra. Helena Ribeiro',
      specialty: 'Cardiologia',
      date: 'Qui, 26 nov 2026',
      time: 'Às 09:30',
      footer: Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          style: TextButton.styleFrom(foregroundColor: context.colors.error),
          onPressed: () {},
          icon: const Icon(Icons.close),
          label: const Text('Cancelar consulta'),
        ),
      ),
    ),
    const SizedBox(height: AppSpacing.sm),
    const AppointmentCard(
      doctorName: 'Dr. Carlos Mendes',
      specialty: 'Dermatologia',
      date: 'Seg, 9 nov 2026',
      time: 'Às 14:00',
      status: 'Realizada',
    ),
    const SizedBox(height: AppSpacing.sm),
    const AppointmentCard(
      doctorName: 'Dr. Rafael Costa',
      specialty: 'Ortopedia',
      date: 'Ter, 17 nov 2026',
      time: 'Às 15:00',
      status: 'Cancelada',
    ),
  ];

  List<Widget> _scheduling() {
    const days = [('Ter', 24, false), ('Qua', 25, true), ('Qui', 26, true)];
    const slots = [
      ('08:00', true),
      ('08:30', false),
      ('09:00', true),
      ('09:30', true),
      ('10:00', true),
      ('10:30', true),
    ];
    return [
      const _Section('Agendamento'),
      Text(
        'DateChip: sem horários (Ter), normal e escolhido',
        style: context.typography.caption,
      ),
      const SizedBox(height: AppSpacing.sm),
      Wrap(
        spacing: AppSpacing.sm,
        children: [
          for (final (weekday, day, enabled) in days)
            DateChip(
              weekday: weekday,
              day: day,
              enabled: enabled,
              selected: day == _selectedDay,
              onTap: () => setState(() => _selectedDay = day),
            ),
        ],
      ),
      const SizedBox(height: AppSpacing.md),
      Text(
        'TimeSlotButton: livre, ocupado (08:30) e escolhido',
        style: context.typography.caption,
      ),
      const SizedBox(height: AppSpacing.sm),
      LayoutBuilder(
        builder: (context, constraints) {
          const gap = 12.0;
          final width = (constraints.maxWidth - gap * 2) / 3;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final (time, available) in slots)
                SizedBox(
                  width: width,
                  child: TimeSlotButton(
                    time: time,
                    available: available,
                    selected: time == _selectedTime,
                    onTap: () => setState(
                      () => _selectedTime = _selectedTime == time ? null : time,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    ];
  }

  List<Widget> _dialogs() => [
    const _Section('Diálogos'),
    AppButton(
      label: 'Abrir aviso de sucesso',
      isSecondary: true,
      onPressed: () => AppDialog.show(
        context,
        title: 'Consulta agendada!',
        message: 'Dra. Helena Ribeiro\nQui, 26 nov 2026 às 09:30',
      ),
    ),
    const SizedBox(height: AppSpacing.md),
    AppButton(
      label: 'Abrir confirmação destrutiva',
      isSecondary: true,
      onPressed: () async {
        final confirmed = await AppDialog.confirm(
          context,
          title: 'Cancelar consulta?',
          message: 'Dra. Helena Ribeiro\nQui, 26 nov 2026 às 09:30',
          confirmLabel: 'Cancelar consulta',
          cancelLabel: 'Manter consulta',
          icon: Icons.event_busy_outlined,
          iconColor: context.colors.error,
          destructive: true,
        );
        if (mounted) _toast(confirmed ? 'Confirmado.' : 'Mantido.');
      },
    ),
  ];
}

class _Section extends StatelessWidget {
  final String title;

  const _Section(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.md),
      child: Text(title, style: context.typography.title),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final Color color;
  final String label;

  const _ColorSwatch(this.color, this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 48,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: context.colors.border),
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
