import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saude_ja_design_system/saude_ja_design_system.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/appointment.dart';
import '../../../data/models/availability.dart';
import '../../../data/models/doctor.dart';
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
      title: vm.isRescheduling ? 'Consulta remarcada!' : 'Consulta agendada!',
      message:
          '${a.doctorName}\n'
          '${DateFormatter.shortDate(a.startsAt)} às ${a.time}',
      buttonLabel: vm.isRescheduling ? 'Voltar' : 'Voltar para a Home',
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
                          backgroundColor: context.colors.surface,
                          side: BorderSide(color: context.colors.border),
                        ),
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => _goBack(context),
                      ),
                      const SizedBox(width: AppSpacing.ms),
                      Expanded(
                        child: Text(
                          vm.isRescheduling
                              ? 'Remarcar consulta'
                              : 'Agendar consulta',
                          style: context.typography.heading,
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
        return Semantics(
          label: 'Carregando',
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              const SkeletonCard(lines: 2),
              const SizedBox(height: AppSpacing.lg),
              const AppSkeleton(width: 160, height: 20),
              const SizedBox(height: AppSpacing.ms),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  for (var i = 0; i < 5; i++)
                    const AppSkeleton(
                      width: 58,
                      height: 72,
                      radius: AppRadius.chip,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const AppSkeleton(width: 200, height: 20),
              const SizedBox(height: AppSpacing.ms),
              for (var i = 0; i < 2; i++) ...[
                const Row(
                  children: [
                    Expanded(child: AppSkeleton(height: 44)),
                    SizedBox(width: AppSpacing.ms),
                    Expanded(child: AppSkeleton(height: 44)),
                    SizedBox(width: AppSpacing.ms),
                    Expanded(child: AppSkeleton(height: 44)),
                  ],
                ),
                const SizedBox(height: AppSpacing.ms),
              ],
            ],
          ),
        );
      case ScheduleStatus.error:
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_busy_outlined,
                size: 48,
                color: context.colors.error,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                vm.errorMessage!,
                textAlign: TextAlign.center,
                style: context.typography.body,
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
                  if (vm.rescheduling case final current?) ...[
                    const SizedBox(height: AppSpacing.md),
                    _CurrentAppointment(appointment: current),
                  ],
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
                    label: vm.isRescheduling
                        ? 'Confirmar nova data'
                        : 'Confirmar agendamento',
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
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.ms),
      // Wrap: com fonte grande, o mês desce para a linha de baixo.
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.end,
        spacing: AppSpacing.sm,
        children: [
          Text(text, style: context.typography.title),
          if (trailing != null && trailing!.isNotEmpty) ...[
            Text(
              trailing!,
              style: context.typography.body.copyWith(
                color: context.colors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Aviso com a data atual, no modo de remarcar.
class _CurrentAppointment extends StatelessWidget {
  final Appointment appointment;

  const _CurrentAppointment({required this.appointment});

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
          Icon(Icons.event_repeat, color: context.colors.primary),
          const SizedBox(width: AppSpacing.ms),
          Expanded(
            child: Text(
              'Data atual: ${DateFormatter.shortDate(appointment.startsAt)} '
              'às ${appointment.time}. Escolha a nova data e horário.',
              style: context.typography.body,
            ),
          ),
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
      padding: const EdgeInsets.all(AppSpacing.ms),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: context.colors.secondary.withValues(alpha: 0.2),
            child: Icon(Icons.person, color: context.colors.primary, size: 30),
          ),
          const SizedBox(width: AppSpacing.ms),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  style: context.typography.body.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  doctor.specialtyName,
                  style: context.typography.body.copyWith(
                    fontSize: 13,
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(doctor.crm, style: context.typography.caption),
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
      return Text(
        'Este médico não tem agenda nos próximos dias.',
        style: context.typography.subtitle,
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
      return Text(
        'Não há horários livres neste dia. Escolha outra data.',
        style: context.typography.subtitle,
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
