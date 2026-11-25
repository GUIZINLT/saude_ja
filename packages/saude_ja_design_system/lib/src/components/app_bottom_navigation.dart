import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';
import '../tokens/app_typography.dart';

/// Item do menu inferior.
class AppNavItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const AppNavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}

/// Menu inferior do app (Home, Consultas, Histórico, Perfil).
class AppBottomNavigation extends StatelessWidget {
  final List<AppNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavigation({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.colors.border)),
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: context.colors.surface,
          indicatorColor: context.colors.secondary.withValues(alpha: 0.2),
          elevation: 0,
          height: 72,
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => context.typography.labelSmall.copyWith(
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w500,
              color: states.contains(WidgetState.selected)
                  ? context.colors.primary
                  : context.colors.textSecondary,
            ),
          ),
          iconTheme: WidgetStateProperty.resolveWith(
            (states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? context.colors.primary
                  : context.colors.textSecondary,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: onTap,
          destinations: [
            for (final item in items)
              NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: item.label,
              ),
          ],
        ),
      ),
    );
  }
}
