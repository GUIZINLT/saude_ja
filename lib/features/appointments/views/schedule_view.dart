import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/availability.dart';
import '../../../data/models/doctor.dart';
import '../../../design_system/components/app_button.dart';
import '../../../design_system/components/app_card.dart';
import '../../../design_system/components/app_dialog.dart';
import '../../../design_system/components/date_chip.dart';
import '../../../design_system/components/time_slot_button.dart';
import '../../../design_system/tokens/app_colors.dart';
import '../../../design_system/tokens/app_spacing.dart';
import '../../../design_system/tokens/app_typography.dart';
import '../../auth/views/widgets/form_error_banner.dart';
import '../viewmodels/schedule_viewmodel.dart';

/// Tela de Agendamento. Recebe o id do médico como argumento da rota e,
/// ao agendar, fecha devolvendo `true` para a Home se atualizar.
class ScheduleView extends StatelessWidget {
  const ScheduleView({super.key});

  void _goBack(BuildContext context, [bool scheduled = false]) {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop(scheduled);
    } else {
      navigator.pushReplacementNamed(AppRoutes.home);
    }
  }

  Future<void> _confirm(BuildContext context) async {
    final vm = context.read<ScheduleViewModel>();
    final ok = await vm.confirm();
    if (!ok || !context.mounted) return;

    final a = vm.createdAppointment!;
    await AppDialog.show(
      context,
      title: 'Consulta agendada!',
      message:
          '${a.doctorName}\n'
          '${DateFormatter.shortDate(a.startsAt)} às ${a.time}',
      buttonLabel: 'Voltar para a Home',
    );
    if (context.mounted) _goBack(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ScheduleViewModel>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    0,
                  ),
                  child: Row(
                    children: [
                      IconButton.outlined(
                        tooltip: 'Voltar',
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surface,
                          side: const BorderSide(color: AppColors.border),
                        ),
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => _goBack(context),
                      ),
                      const SizedBox(width: AppSpacing.md - 4),
                      const Expanded(
                        child: Text(
                          'Agendar consulta',
                          style: AppTypography.heading,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: _buildBody(context, vm)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ScheduleViewModel vm) {
    switch (vm.status) {
      case ScheduleStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case ScheduleStatus.error:
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.event_busy_outlined,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                vm.errorMessage!,
                textAlign: TextAlign.center,
                style: AppTypography.body,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (vm.doctorId != null)
                AppButton(label: 'Tentar novamente', onPressed: vm.load)
              else
                AppButton(
                  label: 'Ir para a Home',
                  onPressed: () => _goBack(context),
                ),
            ],
          ),
        );
      case ScheduleStatus.ready:
        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  _DoctorHeader(doctor: vm.doctor!),
                  _SectionTitle('Escolha a data', trailing: vm.monthLabel),
                  _DatePicker(vm: vm),
                  const _SectionTitle('Horários disponíveis'),
                  _TimeGrid(vm: vm),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                children: [
                  if (vm.submitError != null) ...[
                    FormErrorBanner(message: vm.submitError!),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  AppButton(
                    label: 'Confirmar agendamento',
                    isLoading: vm.isSubmitting,
                    onPressed: vm.canConfirm ? () => _confirm(context) : null,
                  ),
                ],
              ),
            ),
          ],
        );
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final String? trailing;

  const _SectionTitle(this.text, {this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.lg,
        bottom: AppSpacing.md - 4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(text, style: AppTypography.title),
          if (trailing != null && trailing!.isNotEmpty) ...[
            const SizedBox(width: AppSpacing.sm),
            Text(
              trailing!,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DoctorHeader extends StatelessWidget {
  final Doctor doctor;

  const _DoctorHeader({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
            child: const Icon(Icons.person, color: AppColors.primary, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  style: AppTypography.body.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  doctor.specialtyName,
                  style: AppTypography.body.copyWith(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(doctor.crm, style: AppTypography.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DatePicker extends StatelessWidget {
  final ScheduleViewModel vm;

  const _DatePicker({required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.days.isEmpty) {
      return const Text(
        'Este médico não tem agenda nos próximos dias.',
        style: AppTypography.subtitle,
      );
    }
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final AvailableDay day in vm.days)
          DateChip(
            weekday: DateFormatter.weekdayShort(day.dateTime),
            day: day.dateTime.day,
            selected: day.date == vm.selectedDate,
            enabled: day.hasFreeSlot,
            onTap: () => vm.selectDate(day.date),
          ),
      ],
    );
  }
}

class _TimeGrid extends StatelessWidget {
  final ScheduleViewModel vm;

  const _TimeGrid({required this.vm});

  @override
  Widget build(BuildContext context) {
    final day = vm.selectedDay;
    if (day == null) return const SizedBox.shrink();
    if (!day.hasFreeSlot) {
      return const Text(
        'Não há horários livres neste dia. Escolha outra data.',
        style: AppTypography.subtitle,
      );
    }

    const columns = 3;
    const gap = 12.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final slot in day.slots)
              SizedBox(
                width: width,
                child: TimeSlotButton(
                  time: slot.time,
                  available: slot.available,
                  selected: slot.time == vm.selectedTime,
                  onTap: () => vm.selectTime(slot.time),
                ),
              ),
          ],
        );
      },
    );
  }
}
