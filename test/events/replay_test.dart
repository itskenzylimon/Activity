import 'dart:async';
import 'package:activity/activity.dart';
import 'package:flutter_test/flutter_test.dart';

class Base {
  const Base();
}

class Child extends Base {
  const Child();
}

void main() {
  test('each subscriber reads latest sticky cache at listen time', () async {
    final bus = Deamon(sync: true);
    bus.emitSticky<int>(1);
    final stream = bus.onSticky<int>();
    final first = <int>[];
    final a = stream.listen((v) {
      first.add(v);
      if (v == 1) bus.emit(2);
    });
    await Future<void>.delayed(Duration.zero);
    expect(first, [1, 2]);
    bus.emitSticky<int>(3);
    final second = <int>[];
    final b = stream.listen(second.add);
    await Future<void>.delayed(Duration.zero);
    expect(second, [3]);
    await a.cancel();
    await b.cancel();
    await bus.close();
    expect(() => bus.emitSticky<int>(4), throwsStateError);
  });
  test(
    'sticky cache is exact emission type; live events include subtypes',
    () async {
      final bus = Deamon();
      bus.emitSticky<Child>(const Child());
      final values = <Base>[];
      final sub = bus.onSticky<Base>().listen(values.add);
      bus.emit(const Child());
      await Future<void>.delayed(Duration.zero);
      expect(values.length, 1);
      await sub.cancel();
      await bus.close();
    },
  );
  test(
    'injected bus requires broadcast and close owns supplied controller',
    () async {
      final single = StreamController<Object?>();
      expect(() => Deamon.withController(single), throwsArgumentError);
      single.stream.listen((_) {});
      await single.close();
      final source = StreamController<Object?>.broadcast();
      await Deamon.withController(source).close();
      expect(source.isClosed, isTrue);
    },
  );
}
