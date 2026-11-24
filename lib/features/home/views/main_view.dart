import 'package:flutter/material.dart';

import '../../../design_system/components/app_bottom_navigation.dart';
import '../../profile/views/profile_view.dart';
import 'home_view.dart';
import 'widgets/coming_soon_tab.dart';

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

  void _select(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeView(onOpenAppointments: () => _select(1)),
          const ComingSoonTab(
            icon: Icons.calendar_month_outlined,
            title: 'Consultas',
            message: 'Aqui vão aparecer suas consultas confirmadas.',
          ),
          const ComingSoonTab(
            icon: Icons.history,
            title: 'Histórico',
            message: 'Aqui vão aparecer as consultas realizadas e canceladas.',
          ),
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
