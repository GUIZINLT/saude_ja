import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../appointments/viewmodels/appointment_list_viewmodel.dart';
import '../../appointments/views/widgets/appointment_list_body.dart';

/// Aba Histórico: consultas realizadas e canceladas.
class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppointmentListBody(
      vm: context.watch<AppointmentHistoryViewModel>(),
      title: 'Histórico',
      subtitle: 'Consultas realizadas e canceladas.',
      emptyIcon: Icons.history,
      emptyMessage: 'Nenhuma consulta no histórico ainda.',
    );
  }
}
