// Run from the Activity root: dart run tool/check_doc_examples.dart [--format]
// Add --chrome to compile and execute the exact Dartdoc examples in Chrome.
import 'dart:io';

Future<void> main(List<String> args) async {
  final directory = Directory('test/.api_snippets');
  if (directory.existsSync()) await directory.delete(recursive: true);
  await directory.create(recursive: true);
  final snippets = <({String id, String source, File owner})>[];
  final pattern = RegExp(
    r'/// <!-- activity-snippet: ([a-z0-9-]+) -->\r?\n/// ```dart\r?\n([\s\S]*?)/// ```',
  );
  for (final file
      in Directory('lib').listSync(recursive: true).whereType<File>()) {
    if (!file.path.endsWith('.dart')) continue;
    for (final match in pattern.allMatches(file.readAsStringSync())) {
      final source = match[2]!
          .split('\n')
          .where((line) => line.startsWith('///'))
          .map((line) => line.replaceFirst(RegExp(r'^/// ?'), ''))
          .join('\n');
      snippets.add((id: match[1]!, source: source, owner: file));
    }
  }
  if (args.contains('--include-pub-example')) {
    final owner = File('example/activity_example.dart');
    final source = owner.readAsStringSync();
    if (!File(
      'example/example.md',
    ).readAsStringSync().contains(source.trim())) {
      throw StateError(
        'example/example.md must show the current standalone source',
      );
    }
    snippets.add((id: 'published-counter', source: source, owner: owner));
  }
  if (snippets.isEmpty) throw StateError('No marked Dartdoc examples found');
  if (snippets.map((s) => s.id).toSet().length != snippets.length) {
    throw StateError('Snippet IDs must be unique');
  }
  try {
    for (var i = 0; i < snippets.length; i++) {
      await File(
        '${directory.path}/sample_$i.dart',
      ).writeAsString(snippets[i].source);
    }
    final formatted = await Process.run(Platform.resolvedExecutable, [
      'format',
      directory.path,
    ]);
    if (formatted.exitCode != 0) throw StateError('${formatted.stderr}');
    if (args.contains('--format')) {
      for (var i = 0; i < snippets.length; i++) {
        final snippet = snippets[i];
        if (snippet.id == 'published-counter') continue;
        final code =
            File(
              '${directory.path}/sample_$i.dart',
            ).readAsStringSync().trimRight();
        final block = code
            .split('\n')
            .map((line) => line.isEmpty ? '///' : '/// $line')
            .join('\n');
        final owner = snippet.owner.readAsStringSync();
        final target = pattern
            .allMatches(owner)
            .singleWhere((m) => m[1] == snippet.id);
        final replacement =
            '/// <!-- activity-snippet: ${snippet.id} -->\n/// ```dart\n$block\n/// ```';
        snippet.owner.writeAsStringSync(
          owner.replaceRange(target.start, target.end, replacement),
        );
      }
    }
    final suite = StringBuffer(
      "import 'dart:async';\nimport 'package:flutter/material.dart';\nimport 'package:flutter_test/flutter_test.dart';\n",
    );
    for (var i = 0; i < snippets.length; i++) {
      suite.writeln("import 'sample_$i.dart' as sample$i;");
    }
    suite.writeln(
      'void main() { TestWidgetsFlutterBinding.ensureInitialized();',
    );
    for (var i = 0; i < snippets.length; i++) {
      final snippet = snippets[i];
      if (snippet.source.contains('runApp(')) {
        suite.writeln(
          "testWidgets('${snippet.id}', (tester) async { sample$i.main(); await tester.pumpAndSettle(); expect(tester.takeException(), isNull); await tester.pumpWidget(const SizedBox()); await tester.pumpAndSettle(); });",
        );
      } else {
        suite.writeln(
          "test('${snippet.id}', () async { await Future<void>.sync(() async { await Future.sync(sample$i.main); }); });",
        );
      }
    }
    suite.writeln('}');
    final test = File('${directory.path}/api_examples_test.dart');
    await test.writeAsString(suite.toString());
    stdout.writeln('Checking ${snippets.length} exact-source examples.');
    final process = await Process.start('flutter', [
      'test',
      '--no-pub',
      if (args.contains('--chrome')) ...['--platform', 'chrome'],
      test.path,
    ], runInShell: Platform.isWindows);
    await Future.wait([
      stdout.addStream(process.stdout),
      stderr.addStream(process.stderr),
    ]);
    exitCode = await process.exitCode;
  } finally {
    if (directory.existsSync()) await directory.delete(recursive: true);
  }
}
