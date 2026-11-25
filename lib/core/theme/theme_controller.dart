import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tema escolhido pelo usuário (Sistema, Claro ou Escuro), salvo no
/// aparelho. O padrão é seguir o sistema.
class ThemeController extends ChangeNotifier {
  ThemeController([this._prefs]);

  static const _key = 'saude_ja.theme_mode';

  /// null nos testes: guarda só na memória.
  final SharedPreferences? _prefs;

  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  static Future<ThemeController> load() async {
    final prefs = await SharedPreferences.getInstance();
    final controller = ThemeController(prefs);
    final saved = prefs.getString(_key);
    controller._mode =
        ThemeMode.values.where((m) => m.name == saved).firstOrNull ??
        ThemeMode.system;
    return controller;
  }

  void setMode(ThemeMode mode) {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
    final prefs = _prefs;
    if (prefs != null) unawaited(prefs.setString(_key, mode.name));
  }
}
