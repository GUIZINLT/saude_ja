import 'package:flutter/material.dart';
import 'package:saude_ja_design_system/saude_ja_design_system.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../../../data/models/appointment.dart';
import '../../viewmodels/appointment_list_viewmodel.dart';

/// Estrutura comum das abas Consultas e Histórico: título, carregando,
/// erro, lista vazia e a lista de cards, com "puxar para atualizar".
class AppointmentListBody extends StatelessWidget {
  final AppointmentListViewModel vm;
  final String title;
  final String subtitle;
  final IconData emptyIcon;
  final String emptyMessage;

  /// Botão opcional da lista vazia (ex.: "Agendar consulta").
  final String? emptyActionLabel;
  final VoidCallback? onEmptyAction;

  /// Rodapé opcional de cada card (ex.: botão Cancelar).
  final Widget? Function(Appointment appointment)? footerBuilder;

  const AppointmentListBody({
    super.key,
    required this.vm,
    required this.title,
    required this.subtitle,
    required this.emptyIcon,
    required this.emptyMessage,
    this.emptyActionLabel,
    this.onEmptyAction,
    this.footerBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: RefreshIndicator(
            onRefresh: vm.load,
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Text(title, style: context.typography.heading),
                const SizedBox(height: AppSpacing.xs),
                Text(subtitle, style: context.typography.subtitle),
                const SizedBox(height: AppSpacing.lg),
                ..._content(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _content(BuildContext context) {
    switch (vm.status) {
      case AppointmentListStatus.loading:
        return const [
          SkeletonCard(showAvatar: false, lines: 4),
          SizedBox(height: AppSpacing.md),
          SkeletonCard(showAvatar: false, lines: 4),
        ];
      case AppointmentListStatus.error:
        return [
          const SizedBox(height: AppSpacing.lg),
          Icon(Icons.cloud_off_outlined, size: 48, color: context.colors.error),
          const SizedBox(height: AppSpacing.md),
          Text(
            vm.errorMessage!,
            textAlign: TextAlign.center,
            style: context.typography.body,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(label: 'Tentar novamente', onPressed: vm.load),
        ];
      case AppointmentListStatus.ready:
        if (vm.isEmpty) {
          return [
            const SizedBox(height: AppSpacing.xl),
            Icon(emptyIcon, size: 56, color: context.colors.secondary),
            const SizedBox(height: AppSpacing.md),
            Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: context.typography.subtitle,
            ),
            if (emptyActionLabel != null && onEmptyAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(label: emptyActionLabel!, onPressed: onEmptyAction),
            ],
          ];
        }
        return [
          for (final a in vm.items) ...[
            AppointmentCard(
              doctorName: a.doctorName,
              specialty: a.specialtyName,
              date: DateFormatter.shortDate(a.startsAt),
              time: 'Às ${a.time}',
              status: a.status.label,
              footer: footerBuilder?.call(a),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ];
    }
  }
}
