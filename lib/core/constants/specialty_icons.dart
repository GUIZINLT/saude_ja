import 'package:flutter/material.dart';

/// Converte o campo `icon` da API (nome de um ícone do Material) em
/// IconData. Ícones desconhecidos caem no genérico.
class SpecialtyIcons {
  SpecialtyIcons._();

  static const Map<String, IconData> _icons = {
    'favorite': Icons.favorite_outline,
    'face': Icons.face_outlined,
    'child_care': Icons.child_care,
    'accessibility_new': Icons.accessibility_new,
    'psychology': Icons.psychology_outlined,
    'visibility': Icons.visibility_outlined,
  };

  static IconData of(String name) =>
      _icons[name] ?? Icons.medical_services_outlined;
}
