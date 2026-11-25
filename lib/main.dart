import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/appointment_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/catalog_repository.dart';
import 'data/services/api_service.dart';
import 'data/services/mock_api_service.dart';
import 'data/services/session_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final api = MockApiService();
  final auth = AuthRepository(api, await SharedPrefsSessionStorage.create());
  // Se o usuário já entrou antes, abre direto na Home.
  await auth.restoreSession();

  runApp(
    SaudeJaApp(
      api: api,
      auth: auth,
      initialRoute: auth.isLoggedIn ? AppRoutes.home : AppRoutes.login,
    ),
  );
}

class SaudeJaApp extends StatelessWidget {
  /// Implementação da API. Hoje é o MockApiService; para o backend real,
  /// basta passar outra implementação de ApiService aqui.
  final ApiService api;

  /// Sessão já restaurada pelo main(). Se for null (testes, Sample App),
  /// cria uma nova, sem sessão salva.
  final AuthRepository? auth;

  /// Tela inicial. O Sample App do design system usa [AppRoutes.designSystem].
  final String initialRoute;

  const SaudeJaApp({
    super.key,
    required this.api,
    this.auth,
    this.initialRoute = AppRoutes.initial,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>.value(value: api),
        if (auth != null)
          ChangeNotifierProvider.value(value: auth!)
        else
          ChangeNotifierProvider(create: (_) => AuthRepository(api)),
        Provider(create: (_) => CatalogRepository(api)),
        Provider(create: (_) => AppointmentRepository(api)),
      ],
      child: MaterialApp(
        title: 'SaúdeJá',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: initialRoute,
        routes: AppRoutes.routes,
      ),
    );
  }
}
