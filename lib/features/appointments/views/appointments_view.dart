import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/date_formatter.dart';
import '../../../data/models/appointment.dart';
import '../../../design_system/components/app_dialog.dart';
import '../../../design_system/tokens/app_colors.dart';
import '../viewmodels/appointment_list_viewmodel.dart';
import 'widgets/appointment_list_body.dart';

/// Aba Consultas: consultas confirmadas, com opção de cancelar.
class AppointmentsView extends StatelessWidget {
  /// Chamado no botão da lista vazia (vai para a Home escolher um médico).
  final VoidCallback? onSchedule;

  const AppointmentsView({super.key, this.onSchedule});

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
      iconColor: AppColors.error,
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
        return Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: vm.cancellingId == null
                ? () => _cancel(context, a)
                : null,
            icon: cancelling
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.close),
            label: const Text('Cancelar consulta'),
          ),
        );
      },
    );
  }
}
