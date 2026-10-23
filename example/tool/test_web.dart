// Run from example/: dart run tool/test_web.dart
import 'dart:io';

Future<void> main(List<String> args) async {
  final fixtures = Directory('test/.web-assets');
  await fixtures.create(recursive: true);
  try {
    for (final name in ['sqlite3.wasm', 'sqflite_sw.js']) {
      await File('web/$name').copy('${fixtures.path}/$name');
    }
    await Directory('${fixtures.path}/lib').create(recursive: true);
    await File('lib/main.dart').copy('${fixtures.path}/lib/main.dart');
    for (final directory in ['assets', 'lib/gallery']) {
      for (final entry in Directory(directory).listSync(recursive: true)) {
        if (entry is! File) continue;
        final target = File('${fixtures.path}/${entry.path}');
        await target.parent.create(recursive: true);
        await entry.copy(target.path);
      }
    }
    final process = await Process.start('flutter', [
      'test',
      '--no-pub',
      '--platform',
      'chrome',
      ...(args.isEmpty ? ['test/widget_test.dart', 'test/gallery'] : args),
    ]);
    await Future.wait([
      stdout.addStream(process.stdout),
      stderr.addStream(process.stderr),
    ]);
    exitCode = await process.exitCode;
  } finally {
    await fixtures.delete(recursive: true);
  }
}
