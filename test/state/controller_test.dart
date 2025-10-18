import 'package:activity/activity.dart';
import 'package:activity/core/src/errors.dart';
import 'package:activity/core/src/state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:async';

class TestController extends ActiveController {
  final name = ActiveString('Bob');
  final age = ActiveInt(20);

  @override
  Iterable<ActiveType> get activities => [name, age];
}

void main() {
  late TestController testController;

  setUp(() {
    testController = TestController();
  });

  group('ActiveController Tests', () {
    test('resetAllActiveTypes restores original values', () {
      const changedName = 'Steve';
      const changedAge = 100;

      final originalName = testController.name.value;
      final originalAge = testController.age.value;

      testController.name(changedName);
      testController.age(changedAge);

      expect(testController.name.value, changedName);
      expect(testController.age.value, changedAge);

      testController.resetAllActiveTypes();

      expect(testController.name.value, originalName);
      expect(testController.age.value, originalAge);
    });

    test('setRunningStatus toggles isTaskRunning correctly', () {
      const taskKey1 = 'task1';
      const taskKey2 = 'task2';
      const taskKey3 = 'task3';

      testController.setRunningStatus(isRunning: true, isRunningKey: taskKey1);
      expect(testController.isTaskRunning(isRunningKey: taskKey1), isTrue);
      expect(testController.isTaskRunning(), isTrue);

      testController.setRunningStatus(isRunning: true, isRunningKey: taskKey2);
      expect(testController.isTaskRunning(isRunningKey: taskKey2), isTrue);

      testController.setRunningStatus(isRunning: true, isRunningKey: taskKey3);
      expect(testController.isTaskRunning(isRunningKey: taskKey3), isTrue);

      testController.setRunningStatus(isRunning: false, isRunningKey: taskKey1);
      expect(testController.isTaskRunning(isRunningKey: taskKey1), isFalse);

      testController.setRunningStatus(isRunning: false, isRunningKey: taskKey2);
      expect(testController.isTaskRunning(isRunningKey: taskKey2), isFalse);

      testController.setRunningStatus(isRunning: false, isRunningKey: taskKey3);
      expect(testController.isTaskRunning(isRunningKey: taskKey3), isFalse);
      expect(testController.isTaskRunning(), isFalse);
    });

    test('activeAsync toggles state before and after async task', () async {
      const taskKey = 'loadUser';

      final result = await testController.activeAsync<String>(() async {
        await Future.delayed(Duration(milliseconds: 100));
        expect(testController.isTaskRunning(isRunningKey: taskKey), isTrue);
        return 'User Loaded';
      }, isRunningKey: taskKey);

      expect(result, 'User Loaded');
      expect(testController.isTaskRunning(isRunningKey: taskKey), isFalse);
    });

    test('notifyActivities sends event to listeners', () async {
      final completer = Completer<List<ActiveStateChanged>>();

      final subscription = testController.addOnStateChangedListener((events) {
        completer.complete(events);
      });

      testController.name('Alice');

      final events = await completer.future;
      expect(events, isNotEmpty);
      expect(events.first.newValue, 'Alice');

      await subscription.cancel();
    });

    test('onActiveError emits error to listeners', () async {
      final completer = Completer<ErrorEvent>();

      final subscription = testController.onActiveErrorListener((error) {
        completer.complete(error);
      });

      final errorEvent = ErrorEvent('Something went wrong');
      testController.onActiveError(errorEvent);

      final result = await completer.future;
      expect(result.error, 'Something went wrong');

      await subscription.cancel();
    });

    test('resetActivities disposes resources and prevents further use', () async {
      await testController.resetActivities();

      expect(() => testController.name('Alice'),
          throwsA(isA<StateError>()));

      expect(() => testController.setRunning(isRunningKey: 'x'),
          throwsA(isA<StateError>()));

      expect(() => testController.addOnStateChangedListener((_) {}),
          throwsA(isA<StateError>()));
    });
  });
}
