import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../design_system/components/app_bottom_navigation.dart';
import '../../appointments/viewmodels/appointment_list_viewmodel.dart';
import '../../appointments/views/appointments_view.dart';
import '../../history/views/history_view.dart';
import '../../profile/views/profile_view.dart';
import '../viewmodels/home_viewmodel.dart';
import 'home_view.dart';

/// Tela principal depois do login: as 4 abas do menu inferior.
///
/// Usa IndexedStack para cada aba manter o estado (busca, rolagem) ao
/// trocar de aba.
class MainView extends StatefulWidget {
  const MainView({super.key});

  static const items = [
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
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _index = 0;

  /// Troca de aba e atualiza os dados dela, para refletir o que mudou
  /// nas outras (agendou na Home, cancelou em Consultas...).
  void _select(int index) {
    if (index != _index) {
      switch (index) {
        case 0:
          context.read<HomeViewModel>().load();
        case 1:
          context.read<UpcomingAppointmentsViewModel>().load();
        case 2:
          context.read<AppointmentHistoryViewModel>().load();
      }
    }
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeView(onOpenAppointments: () => _select(1)),
          AppointmentsView(onSchedule: () => _select(0)),
          const HistoryView(),
          const ProfileView(),
        ],
      ),
      bottomNavigationBar: AppBottomNavigation(
        items: MainView.items,
        currentIndex: _index,
        onTap: _select,
      ),
    );
  }
}
