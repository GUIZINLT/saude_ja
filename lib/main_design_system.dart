// Abre direto o Sample App do design system:
//
//   flutter run -t lib/main_design_system.dart
import 'package:flutter/material.dart';

import 'core/routes/app_routes.dart';
import 'data/services/mock_api_service.dart';
import 'main.dart';

void main() {
  runApp(
    SaudeJaApp(api: MockApiService(), initialRoute: AppRoutes.designSystem),
  );
}
