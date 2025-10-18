import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:activity/core/events/deamon.dart';

void main() {
  group('Deamon Tests', () {
    late Deamon deamon;

    setUp(() {
      deamon = Deamon();
    });

    tearDown(() async {
      await deamon.close();
    });

    test('emits and receives string event', () async {
      final completer = Completer<String>();

      deamon.on<String>().listen(completer.complete);
      deamon.emit('hello');

      expect(await completer.future.timeout(Duration(seconds: 2)), 'hello');
    });

    test('emits and receives integer event', () async {
      final completer = Completer<int>();

      deamon.on<int>().listen(completer.complete);
      deamon.emit(42);

      expect(await completer.future.timeout(Duration(seconds: 2)), 42);
    });

    test('throws error when emitting after close', () async {
      await deamon.close();

      expect(() => deamon.emit('should fail'), throwsStateError);
    });

    test('emits sticky event and receives it immediately', () async {
      deamon.emitSticky<String>('sticky');

      final result = await deamon.onSticky<String>().first.timeout(Duration(seconds: 2));
      expect(result, 'sticky');
    });

    test('clears sticky event', () async {
      deamon.emitSticky<String>('should clear');
      deamon.clearSticky<String>();

      bool wasCalled = false;

      final sub = deamon.onSticky<String>().listen((_) {
        wasCalled = true;
      });

      await Future.delayed(const Duration(milliseconds: 300));
      await sub.cancel();

      expect(wasCalled, isFalse, reason: 'No sticky event should be replayed after clearing.');
    });

    test('supports multiple listeners', () async {
      final results = <String>[];

      deamon.on<String>().listen(results.add);
      deamon.on<String>().listen(results.add);

      deamon.emit('multi');

      await Future.delayed(Duration(milliseconds: 100));
      expect(results, containsAll(['multi', 'multi']));
    });

    test('next returns first emitted event', () async {
      Future<String> future = deamon.next<String>();
      deamon.emit('nextTest');

      expect(await future.timeout(Duration(seconds: 2)), 'nextTest');
    });

    test('emitError forwards error to listener', () async {
      final completer = Completer();

      deamon.on<String>().listen(
            (_) {},
        onError: completer.complete,
      );

      deamon.emitError('errorTest');

      expect(await completer.future.timeout(Duration(seconds: 2)), 'errorTest');
    });

    test('destroy does not crash even if not awaited', () {
      expect(() => deamon.destroy(), returnsNormally);
    });
  });
}
