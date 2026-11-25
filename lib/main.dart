import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:saude_ja_design_system/saude_ja_design_system.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/theme_controller.dart';
import 'data/repositories/appointment_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/catalog_repository.dart';
import 'data/services/api_service.dart';
import 'data/services/http_api_service.dart';
import 'data/services/mock_api_service.dart';
import 'data/services/session_storage.dart';

/// Qual API usar, escolhida na hora de rodar:
///   flutter run                                   -> mock dentro do app
///   flutter run --dart-define=API=http            -> servidor HTTP
///   --dart-define=API_URL=http://10.0.2.2:8080    -> outro endereço
const _apiMode = String.fromEnvironment('API', defaultValue: 'mock');
const _apiUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://localhost:8080',
);

ApiService createApi() =>
    _apiMode == 'http' ? HttpApiService(baseUrl: _apiUrl) : MockApiService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final api = createApi();
  final auth = AuthRepository(api, await SharedPrefsSessionStorage.create());
  // Se o usuário já entrou antes, abre direto na Home.
  await auth.restoreSession();
  final theme = await ThemeController.load();

  runApp(
    SaudeJaApp(
      api: api,
      auth: auth,
      themeController: theme,
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

  /// Tema escolhido (Sistema, Claro ou Escuro). Se for null, segue o
  /// sistema sem salvar a escolha.
  final ThemeController? themeController;

  /// Tela inicial. O Sample App do design system usa [AppRoutes.designSystem].
  final String initialRoute;

  const SaudeJaApp({
    super.key,
    required this.api,
    this.auth,
    this.themeController,
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
        if (themeController != null)
          ChangeNotifierProvider.value(value: themeController!)
        else
          ChangeNotifierProvider(create: (_) => ThemeController()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, theme, _) => MaterialApp(
          title: 'SaúdeJá',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: theme.mode,
          // Textos dos componentes do Flutter (ex.: "Voltar", lidos pelo
          // leitor de tela) e datas em português.
          locale: const Locale('pt', 'BR'),
          supportedLocales: const [Locale('pt', 'BR')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          initialRoute: initialRoute,
          routes: AppRoutes.routes,
        ),
      ),
    );
  }
}
