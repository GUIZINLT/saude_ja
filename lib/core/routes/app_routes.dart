import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saude_ja_design_system/saude_ja_design_system.dart';

import '../../data/repositories/appointment_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../features/appointments/viewmodels/appointment_list_viewmodel.dart';
import '../../features/appointments/viewmodels/schedule_viewmodel.dart';
import '../../features/appointments/views/schedule_view.dart';
import '../../features/auth/viewmodels/forgot_password_viewmodel.dart';
import '../../features/auth/viewmodels/login_viewmodel.dart';
import '../../features/auth/viewmodels/register_viewmodel.dart';
import '../../features/auth/views/forgot_password_view.dart';
import '../../features/auth/views/login_view.dart';
import '../../features/auth/views/register_view.dart';
import '../../features/doctors/viewmodels/doctor_details_viewmodel.dart';
import '../../features/doctors/views/doctor_details_view.dart';
import '../../features/home/viewmodels/home_viewmodel.dart';
import '../../features/home/views/main_view.dart';

/// Nomes das rotas e criação de cada tela com o seu ViewModel.
class AppRoutes {
  AppRoutes._();

  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const home = '/home';

  /// Argumento: id do médico (String).
  static const schedule = '/schedule';

  /// Argumento: id do médico (String).
  static const doctor = '/doctor';
  static const designSystem = '/design-system';

  static const initial = login;

  /// Cada tela ganha um ViewModel novo, criado com os repositórios que
  /// estão no topo da árvore (main.dart).
  static Map<String, WidgetBuilder> get routes => {
    // Com sessão ativa, o endereço do Login (ex.: #/login na web) abre a
    // Home.
    login: (context) =>
        context.read<AuthRepository>().isLoggedIn ? _homePage() : _loginPage(),
    forgotPassword: (_) => ChangeNotifierProvider(
      create: (context) =>
          ForgotPasswordViewModel(context.read<AuthRepository>()),
      child: const ForgotPasswordView(),
    ),
    register: (_) => ChangeNotifierProvider(
      create: (context) => RegisterViewModel(context.read<AuthRepository>()),
      child: const RegisterView(),
    ),
    home: _requireLogin((_) => _homePage()),
    doctor: _requireLogin(
      (routeContext) => ChangeNotifierProvider(
        create: (context) => DoctorDetailsViewModel(
          doctorId: ModalRoute.of(routeContext)?.settings.arguments as String?,
          catalog: context.read<CatalogRepository>(),
        )..load(),
        child: const DoctorDetailsView(),
      ),
    ),
    schedule: _requireLogin((routeContext) {
      final args = ScheduleArgs.from(
        ModalRoute.of(routeContext)?.settings.arguments,
      );
      return ChangeNotifierProvider(
        create: (context) => ScheduleViewModel(
          doctorId: args?.doctorId,
          rescheduling: args?.reschedule,
          catalog: context.read<CatalogRepository>(),
          appointments: context.read<AppointmentRepository>(),
        )..load(),
        child: const ScheduleView(),
      );
    }),
    designSystem: (_) => const SampleApp(),
  };

  static Widget _homePage() => MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => HomeViewModel(
          auth: context.read<AuthRepository>(),
          catalog: context.read<CatalogRepository>(),
          appointments: context.read<AppointmentRepository>(),
        )..load(),
      ),
      ChangeNotifierProvider(
        create: (context) =>
            UpcomingAppointmentsViewModel(context.read<AppointmentRepository>())
              ..load(),
      ),
      ChangeNotifierProvider(
        create: (context) =>
            AppointmentHistoryViewModel(context.read<AppointmentRepository>())
              ..load(),
      ),
    ],
    child: const MainView(),
  );

  static Widget _loginPage() => ChangeNotifierProvider(
    create: (context) => LoginViewModel(context.read<AuthRepository>()),
    child: const LoginView(),
  );

  /// Telas que precisam de login mostram o Login se não houver sessão
  /// (por exemplo, depois de sair, ao abrir um endereço salvo na web).
  static WidgetBuilder _requireLogin(WidgetBuilder builder) =>
      (context) => context.read<AuthRepository>().isLoggedIn
      ? builder(context)
      : _loginPage();
}
