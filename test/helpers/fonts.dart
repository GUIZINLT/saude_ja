import 'dart:io';

import 'package:flutter/services.dart';

/// Carrega as fontes reais (Roboto e Material Icons) que vêm no SDK do
/// Flutter. Sem isso, os testes desenham o texto com uma fonte de teste
/// em blocos, mais larga, que não mede o layout como no aparelho.
Future<void> loadRealFonts() async {
  final dir = _materialFontsDir();
  // No Linux, maiúsculas e minúsculas contam nos nomes de arquivo; então
  // procura cada fonte ignorando a diferença.
  final files = {
    for (final f in dir.listSync().whereType<File>())
      f.uri.pathSegments.last.toLowerCase(): f,
  };

  Future<void> load(String family, List<String> names) async {
    final loader = FontLoader(family);
    for (final name in names) {
      final file = files[name];
      if (file == null) {
        throw StateError(
          'Fonte $name não encontrada em ${dir.path}. '
          'Arquivos: ${files.keys.join(', ')}',
        );
      }
      final bytes = file.readAsBytesSync();
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

/// Pasta das fontes do SDK: `(raiz do Flutter)/bin/cache/artifacts/
/// material_fonts`. Tenta pelo executável dos testes e pela variável
/// FLUTTER_ROOT.
Directory _materialFontsDir() {
  final candidates = <String>[];
  final exe = Platform.resolvedExecutable.replaceAll(r'\', '/');
  final i = exe.indexOf('/bin/cache/');
  if (i >= 0) candidates.add(exe.substring(0, i));
  final env = Platform.environment['FLUTTER_ROOT'];
  if (env != null && env.isNotEmpty) candidates.add(env.replaceAll(r'\', '/'));

  for (final root in candidates) {
    final dir = Directory('$root/bin/cache/artifacts/material_fonts');
    if (dir.existsSync()) return dir;
  }
  throw StateError(
    'Pasta material_fonts do Flutter não encontrada. Procurei em: '
    '${candidates.map((r) => '$r/bin/cache/artifacts/material_fonts').join(', ')}',
  );
}
