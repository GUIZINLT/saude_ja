// Resumo da cobertura de testes, a partir do coverage/lcov.info gerado por
// `flutter test --coverage`.
//
//   dart run tool/coverage_summary.dart              (tabela em Markdown)
//   dart run tool/coverage_summary.dart --min 80     (falha abaixo de 80%)
//
// No CI, a tabela vai para o resumo da execução no GitHub Actions.
import 'dart:io';

void main(List<String> args) {
  final minIndex = args.indexOf('--min');
  final min = minIndex >= 0 && minIndex + 1 < args.length
      ? double.parse(args[minIndex + 1])
      : null;

  final file = File('coverage/lcov.info');
  if (!file.existsSync()) {
    stderr.writeln('coverage/lcov.info não encontrado. Rode antes:');
    stderr.writeln('  flutter test --coverage');
    exit(2);
  }

  // Linhas encontradas (LF) e cobertas (LH) por pasta de lib/.
  final found = <String, int>{};
  final hit = <String, int>{};
  String? group;
  for (final line in file.readAsLinesSync()) {
    if (line.startsWith('SF:')) {
      group = _groupOf(line.substring(3).replaceAll(r'\', '/'));
    } else if (group != null && line.startsWith('LF:')) {
      found[group] = (found[group] ?? 0) + int.parse(line.substring(3));
    } else if (group != null && line.startsWith('LH:')) {
      hit[group] = (hit[group] ?? 0) + int.parse(line.substring(3));
    }
  }

  final totalFound = found.values.fold(0, (a, b) => a + b);
  final totalHit = hit.values.fold(0, (a, b) => a + b);
  final total = totalFound == 0 ? 0.0 : totalHit * 100 / totalFound;

  stdout
    ..writeln('## Cobertura de testes: ${total.toStringAsFixed(1)}%')
    ..writeln()
    ..writeln('| Pasta | Linhas cobertas | Cobertura |')
    ..writeln('|---|---:|---:|');
  for (final g in found.keys.toList()..sort()) {
    final f = found[g]!;
    final h = hit[g] ?? 0;
    final pct = f == 0 ? 0.0 : h * 100 / f;
    stdout.writeln('| `$g` | $h / $f | ${pct.toStringAsFixed(1)}% |');
  }
  stdout.writeln(
    '| **Total** | **$totalHit / $totalFound** | '
    '**${total.toStringAsFixed(1)}%** |',
  );

  if (min != null && total < min) {
    stderr.writeln(
      'Cobertura de ${total.toStringAsFixed(1)}% abaixo do mínimo de $min%.',
    );
    exit(1);
  }
}

/// Agrupa por pasta: lib/features/home/... -> features/home.
String _groupOf(String path) {
  final i = path.indexOf('lib/');
  final rel = i >= 0 ? path.substring(i + 4) : path;
  final parts = rel.split('/');
  if (parts.length <= 1) return 'lib';
  if (parts.length == 2) return parts.first;
  return '${parts[0]}/${parts[1]}';
}
