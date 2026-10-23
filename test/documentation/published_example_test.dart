@TestOn('vm')
library;

// Browser verification copies this exact example into the test server's root:
// dart run tool/check_doc_examples.dart --chrome --include-pub-example
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../example/activity_example.dart';

void main() {
  testWidgets('pub.dev example works without the gallery or QuickeyDB', (
    tester,
  ) async {
    await tester.pumpWidget(const ActivityExample());
    expect(find.text('Count: 0'), findsOneWidget);
    await tester.tap(find.byTooltip('Increment'));
    await tester.pump();
    expect(find.text('Count: 1'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
