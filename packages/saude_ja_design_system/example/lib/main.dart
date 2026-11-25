// Sample App do design system, rodando sozinho, sem o app SaúdeJá:
//
//   cd packages/saude_ja_design_system/example
//   flutter run -d chrome
import 'package:flutter/material.dart';
import 'package:saude_ja_design_system/saude_ja_design_system.dart';

void main() => runApp(const DesignSystemExample());

class DesignSystemExample extends StatelessWidget {
  const DesignSystemExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SaúdeJá | Design System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const SampleApp(),
    );
  }
}
