import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/repositories/appointment_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../design_system/sample_app/sample_app.dart';
import '../../features/appointments/viewmodels/schedule_viewmodel.dart';
import '../../features/appointments/views/schedule_view.dart';
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

  /// Argumento: id do médico (String).
  static const schedule = '/schedule';
  static const designSystem = '/design-system';

  static const initial = login;

  /// Cada tela ganha um ViewModel novo, criado com os repositórios que
  /// estão no topo da árvore (main.dart).
  static Map<String, WidgetBuilder> get routes => {
    login: (_) => _loginPage(),
    register: (_) => ChangeNotifierProvider(
      create: (context) => RegisterViewModel(context.read<AuthRepository>()),
      child: const RegisterView(),
    ),
    home: _requireLogin(
      (_) => ChangeNotifierProvider(
        create: (context) => HomeViewModel(
          auth: context.read<AuthRepository>(),
          catalog: context.read<CatalogRepository>(),
          appointments: context.read<AppointmentRepository>(),
        )..load(),
        child: const MainView(),
      ),
    ),
    schedule: _requireLogin(
      (routeContext) => ChangeNotifierProvider(
        create: (context) => ScheduleViewModel(
          doctorId: ModalRoute.of(routeContext)?.settings.arguments as String?,
          catalog: context.read<CatalogRepository>(),
          appointments: context.read<AppointmentRepository>(),
        )..load(),
        child: const ScheduleView(),
      ),
    ),
    designSystem: (_) => const SampleApp(),
  };

  static Widget _loginPage() => ChangeNotifierProvider(
    create: (context) => LoginViewModel(context.read<AuthRepository>()),
    child: const LoginView(),
  );

  /// Telas que precisam de login mostram o Login se não houver sessão
  /// (por exemplo, ao recarregar a página no navegador, já que o mock
  /// guarda a sessão só na memória).
  static WidgetBuilder _requireLogin(WidgetBuilder builder) =>
      (context) => context.read<AuthRepository>().isLoggedIn
      ? builder(context)
      : _loginPage();
}
