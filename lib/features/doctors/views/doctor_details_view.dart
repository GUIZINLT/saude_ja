import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saude_ja_design_system/saude_ja_design_system.dart';

import '../../../core/routes/app_routes.dart';
import '../../../data/models/doctor.dart';
import '../viewmodels/doctor_details_viewmodel.dart';

/// Detalhes do médico, antes de agendar. Fecha devolvendo `true` quando uma
/// consulta é marcada, para a Home se atualizar.
class DoctorDetailsView extends StatelessWidget {
  const DoctorDetailsView({super.key});

  void _goBack(BuildContext context, [bool scheduled = false]) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop(scheduled);
    } else {
      unawaited(navigator.pushReplacementNamed(AppRoutes.home));
    }
  }

  Future<void> _schedule(BuildContext context, Doctor doctor) async {
    final scheduled = await Navigator.of(
      context,
    ).pushNamed(AppRoutes.schedule, arguments: doctor.id);
    if (scheduled == true && context.mounted) _goBack(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DoctorDetailsViewModel>();
    final doctor = vm.doctor;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Voltar',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _goBack(context),
        ),
        title: Text('Médico', style: context.typography.title),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: switch (vm.status) {
              DoctorDetailsStatus.loading => const _DetailsSkeleton(),
              DoctorDetailsStatus.error => _ErrorState(
                message: vm.errorMessage!,
                onRetry: vm.doctorId == null ? null : vm.load,
              ),
              DoctorDetailsStatus.ready => Column(
                children: [
                  Expanded(
                    child: _Details(vm: vm, doctor: doctor!),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: AppButton(
                      label: 'Agendar consulta',
                      icon: Icons.calendar_month,
                      onPressed: () => _schedule(context, doctor),
                    ),
                  ),
                ],
              ),
            },
          ),
        ),
      ),
    );
  }
}

class _Details extends StatelessWidget {
  final DoctorDetailsViewModel vm;
  final Doctor doctor;

  const _Details({required this.vm, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final nextSlot = vm.nextFreeSlot;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      children: [
        const SizedBox(height: AppSpacing.sm),
        Center(
          child: CircleAvatar(
            radius: 48,
            backgroundColor: context.colors.secondary.withValues(alpha: 0.2),
            child: Icon(Icons.person, color: context.colors.primary, size: 52),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          doctor.name,
          textAlign: TextAlign.center,
          style: context.typography.title,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          doctor.specialtyName,
          textAlign: TextAlign.center,
          style: context.typography.subtitle,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          doctor.crm,
          textAlign: TextAlign.center,
          style: context.typography.caption,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, color: context.colors.rating, size: 20),
            const SizedBox(width: AppSpacing.xs),
            Text(
              doctor.rating.toStringAsFixed(1),
              style: context.typography.bodyStrong,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '(${doctor.reviewCount} avaliações)',
              style: context.typography.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Sobre', style: context.typography.title),
        const SizedBox(height: AppSpacing.sm),
        Text(doctor.bio, style: context.typography.body),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          child: Column(
            children: [
              _InfoRow(
                icon: Icons.event_outlined,
                label: 'Dias de atendimento',
                value: vm.attendanceDays.isEmpty
                    ? 'Sem agenda nos próximos dias'
                    : vm.attendanceDays,
              ),
              const Divider(height: AppSpacing.lg),
              _InfoRow(
                icon: Icons.schedule,
                label: 'Próximo horário livre',
                value: nextSlot ?? 'Nenhum nos próximos dias',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

class _DetailsSkeleton extends StatelessWidget {
  const _DetailsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Carregando',
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: const [
          Center(child: AppSkeleton.circle(size: 96)),
          SizedBox(height: AppSpacing.md),
          Center(child: AppSkeleton(width: 200, height: 20)),
          SizedBox(height: AppSpacing.sm),
          Center(child: AppSkeleton(width: 120, height: 14)),
          SizedBox(height: AppSpacing.xl),
          AppSkeleton(width: 80, height: 18),
          SizedBox(height: AppSpacing.sm),
          AppSkeleton(height: 14),
          SizedBox(height: AppSpacing.xs),
          AppSkeleton(width: 240, height: 14),
          SizedBox(height: AppSpacing.lg),
          SkeletonCard(showAvatar: false, lines: 4),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: context.colors.primary),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: context.typography.caption),
              const SizedBox(height: AppSpacing.xxs),
              Text(value, style: context.typography.bodyStrong),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function()? onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off_outlined,
            size: 48,
            color: context.colors.error,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.typography.body,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.lg),
            AppButton(label: 'Tentar novamente', onPressed: onRetry),
          ],
        ],
      ),
    );
  }
}
