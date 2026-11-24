import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/services/api_service.dart';
import 'data/services/mock_api_service.dart';

void main() {
  runApp(SaudeJaApp(api: MockApiService()));
}

class SaudeJaApp extends StatelessWidget {
  /// Implementação da API. Hoje é o MockApiService; para o backend real,
  /// basta passar outra implementação de ApiService aqui.
  final ApiService api;

  /// Tela inicial. O Sample App do design system usa [AppRoutes.designSystem].
  final String initialRoute;

  const SaudeJaApp({
    super.key,
    required this.api,
    this.initialRoute = AppRoutes.initial,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>.value(value: api),
        ChangeNotifierProvider(create: (_) => AuthRepository(api)),
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
