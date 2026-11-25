import 'dart:io';

import 'package:flutter/services.dart';

/// Carrega as fontes reais (Roboto e Material Icons) que vêm no SDK do
/// Flutter. Sem isso, os testes desenham o texto com uma fonte de teste
/// em blocos, mais larga, que não mede o layout como no aparelho.
Future<void> loadRealFonts() async {
  final dir = '${_flutterRoot()}/bin/cache/artifacts/material_fonts';

  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      final bytes = File('$dir/$f').readAsBytesSync();
      loader.addFont(Future.value(ByteData.view(bytes.buffer)));
    }
    await loader.load();
  }

  await load('Roboto', [
    'roboto-regular.ttf',
    'roboto-medium.ttf',
    'roboto-bold.ttf',
  ]);
  await load('MaterialIcons', ['materialicons-regular.otf']);
}

String _flutterRoot() {
  final fromEnv = Platform.environment['FLUTTER_ROOT'];
  if (fromEnv != null && fromEnv.isNotEmpty) return fromEnv;
  // flutter_tester fica em <raiz>/bin/cache/artifacts/engine/...
  final exe = Platform.resolvedExecutable.replaceAll(r'\', '/');
  final i = exe.indexOf('/bin/cache/');
  if (i < 0) {
    throw StateError('Não achei o SDK do Flutter. Defina FLUTTER_ROOT.');
  }
  return exe.substring(0, i);
}
