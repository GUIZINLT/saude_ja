import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saude_ja_design_system/saude_ja_design_system.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/appointment.dart';
import '../viewmodels/appointment_list_viewmodel.dart';
import '../viewmodels/schedule_viewmodel.dart';
import 'widgets/appointment_list_body.dart';

/// Aba Consultas: consultas confirmadas, com opção de remarcar e
/// cancelar.
class AppointmentsView extends StatelessWidget {
  /// Chamado no botão da lista vazia (vai para a Home escolher um médico).
  final VoidCallback? onSchedule;

  const AppointmentsView({super.key, this.onSchedule});

  /// Abre o Agendamento no modo de remarcar e atualiza a lista na volta.
  Future<void> _reschedule(BuildContext context, Appointment a) async {
    final vm = context.read<UpcomingAppointmentsViewModel>();
    final changed = await Navigator.of(context).pushNamed(
      AppRoutes.schedule,
      arguments: ScheduleArgs(doctorId: a.doctorId, reschedule: a),
    );
    if (changed != true) return;
    await vm.load();
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Consulta remarcada.')));
  }

  Future<void> _cancel(BuildContext context, Appointment a) async {
    final confirmed = await AppDialog.confirm(
      context,
      title: 'Cancelar consulta?',
      message:
          '${a.doctorName}\n'
          '${DateFormatter.shortDate(a.startsAt)} às ${a.time}',
      confirmLabel: 'Cancelar consulta',
      cancelLabel: 'Manter consulta',
      icon: Icons.event_busy_outlined,
      iconColor: context.colors.error,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;

    final error = await context.read<UpcomingAppointmentsViewModel>().cancel(a);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error ?? 'Consulta cancelada.')));
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UpcomingAppointmentsViewModel>();

    return AppointmentListBody(
      vm: vm,
      title: 'Minhas consultas',
      subtitle: 'Consultas confirmadas, da mais próxima para a mais distante.',
      emptyIcon: Icons.event_available_outlined,
      emptyMessage: 'Você não tem consultas agendadas.',
      emptyActionLabel: 'Agendar consulta',
      onEmptyAction: onSchedule,
      footerBuilder: (a) {
        final cancelling = vm.cancellingId == a.id;
        final busy = vm.cancellingId != null;
        // Ocupa a largura toda do card para os botões irem para a direita.
        return SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: AppSpacing.sm,
            children: [
              TextButton.icon(
                onPressed: busy ? null : () => _reschedule(context, a),
                icon: const Icon(Icons.event_repeat),
                label: const Text('Remarcar'),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: context.colors.error,
                ),
                onPressed: busy ? null : () => _cancel(context, a),
                icon: cancelling
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.close),
                label: const Text('Cancelar consulta'),
              ),
            ],
          ),
        );
      },
    );
  }
}
