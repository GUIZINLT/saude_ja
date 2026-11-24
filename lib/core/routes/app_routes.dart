import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/appointment_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../design_system/sample_app/sample_app.dart';
import '../../features/auth/viewmodels/login_viewmodel.dart';
import '../../features/auth/viewmodels/register_viewmodel.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/auth/views/register_view.dart';
import '../../features/home/viewmodels/home_viewmodel.dart';
import '../../features/home/views/main_view.dart';

/// Nomes das rotas e criação de cada tela com o seu ViewModel.
class AppRoutes {
  AppRoutes._();

  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const designSystem = '/design-system';

  static const initial = login;

  /// Cada tela ganha um ViewModel novo, criado com o AuthRepository que está
  /// no topo da árvore (main.dart).
  static Map<String, WidgetBuilder> get routes => {
    login: (_) => ChangeNotifierProvider(
      create: (context) => LoginViewModel(context.read<AuthRepository>()),
      child: const LoginView(),
    ),
    register: (_) => ChangeNotifierProvider(
      create: (context) => RegisterViewModel(context.read<AuthRepository>()),
      child: const RegisterView(),
    ),
    home: (_) => ChangeNotifierProvider(
      create: (context) => HomeViewModel(
        auth: context.read<AuthRepository>(),
        catalog: context.read<CatalogRepository>(),
        appointments: context.read<AppointmentRepository>(),
      )..load(),
      child: const MainView(),
    ),
    designSystem: (_) => const SampleApp(),
  };
}
