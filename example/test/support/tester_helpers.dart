import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpUntil(
  WidgetTester tester,
  bool Function() ready, {
  String reason = 'asynchronous UI',
}) async {
  final deadline = DateTime.now().add(const Duration(seconds: 10));
  while (!ready() && DateTime.now().isBefore(deadline)) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 25)),
    );
    await tester.pump();
  }
  expect(ready(), isTrue, reason: reason);
  await tester.pumpAndSettle();
}

void reportBrowserFailures() {
  if (!kIsWeb) return;
  reportTestException = (details, _) => Zone.current.handleUncaughtError(
    details.exception,
    details.stack ?? StackTrace.current,
  );
}
