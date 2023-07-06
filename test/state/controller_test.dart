import 'package:activity/activity.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:matcher/src/equals_matcher.dart' as match;

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

  test(
      'resetAllActiveTypes - change property values - All values equal their original value',
          () {
        const changedName = 'Steve';
        const changedAge = 100;

        final originalName = testController.name.value;
        final originalAge = testController.age.value;

        testController.name(changedName);
        testController.age(changedAge);

        expect(testController.name.value, match.equals(changedName));
        expect(testController.age.value, match.equals(changedAge));

        testController.resetAllActiveTypes();

        printSuccess(testController.age.value);
        printSuccess(originalName);
        printSuccess(testController.name.value);
        printSuccess(testController.name.originalValue);

        expect(testController.name.value, match.equals(originalName));
        expect(testController.age.value, match.equals(originalAge));
      });

  test('setRunningStatus', () {
    const taskKeyOne = 'taskOne';
    const taskKeyTwo = 'taskTwo';
    const taskKeyThree = 'taskThree';

    //Set all tasks to isTaskRunning
    testController.setRunningStatus(isRunning: true, isRunningKey: taskKeyOne);

    expect(testController.isTaskRunning(isRunningKey: taskKeyOne), isTrue);

    expect(testController.isTaskRunning(), isTrue);

    bool isTaskKeyOneBusy = testController.isTaskRunning(isRunningKey: taskKeyOne);

    expect(isTaskKeyOneBusy, isTrue);

    testController.setRunningStatus(isRunning: true, isRunningKey: taskKeyTwo);

    expect(testController.isTaskRunning(), isTrue);

    bool isTaskKeyTwoBusy = testController.isTaskRunning(isRunningKey: taskKeyTwo);

    expect(isTaskKeyTwoBusy, isTrue);

    testController.setRunningStatus(isRunning: true, isRunningKey: taskKeyThree);

    expect(testController.isTaskRunning(), isTrue);

    bool isTaskKeyThreeBusy = testController.isTaskRunning(isRunningKey: taskKeyThree);

    expect(isTaskKeyThreeBusy, isTrue);

    //Incrementally remove isTaskRunning status
    testController.setRunningStatus(isRunning: false, isRunningKey: taskKeyOne);

    isTaskKeyOneBusy = testController.isTaskRunning(isRunningKey: taskKeyOne);

    expect(isTaskKeyOneBusy, isFalse);
    expect(testController.isTaskRunning(), isTrue);

    testController.setRunningStatus(isRunning: false, isRunningKey: taskKeyTwo);

    isTaskKeyTwoBusy = testController.isTaskRunning(isRunningKey: taskKeyTwo);

    expect(isTaskKeyTwoBusy, isFalse);
    expect(testController.isTaskRunning(), isTrue);

    testController.setRunningStatus(isRunning: false, isRunningKey: taskKeyThree);

    isTaskKeyThreeBusy = testController.isTaskRunning(isRunningKey: taskKeyThree);

    expect(isTaskKeyThreeBusy, isFalse);
    expect(testController.isTaskRunning(), isFalse);
  });
}