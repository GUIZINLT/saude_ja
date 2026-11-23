import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'design_system/sample_app/sample_app.dart';

void main() {
  runApp(const SaudeJaApp());
}

class SaudeJaApp extends StatelessWidget {
  const SaudeJaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SaúdeJá',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SampleApp(),
    );
  }
}
