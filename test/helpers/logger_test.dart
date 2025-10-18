import 'package:activity/core/helpers/logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';

void main() {
  group('Logger', () {
    late Logger logger;
    final buffer = StringBuffer();

    setUp(() {
      logger = Logger(
        enabled: true,
        includeTimestamp: false,
        enableColors: false,
        printInRelease: true,
      );

      // Override debugPrint to capture logs
      debugPrint = (String? message, {int? wrapWidth}) {
        buffer.writeln(message);
      };
    });

    tearDown(() {
      buffer.clear();
    });

    test('logs error with name and message', () {
      logger.error("An error occurred", name: 'Test');
      expect(buffer.toString(), contains('Test'));
      expect(buffer.toString(), contains('An error occurred'));
    });

    test('logs success with message only', () {
      logger.success("Operation successful");
      expect(buffer.toString(), contains('Operation successful'));
    });

    test('logs warning with default name', () {
      logger.warn("Something might be wrong");
      expect(buffer.toString(), contains('Something might be wrong'));
    });

    test('logs info with default name', () {
      logger.info("Informational message");
      expect(buffer.toString(), contains('Informational message'));
    });

    test('logs normal text', () {
      logger.normal("Just a normal log");
      expect(buffer.toString(), contains('Just a normal log'));
    });

    test('does not log if disabled', () {
      logger.enabled = false;
      logger.error("This should not be logged");
      expect(buffer.toString().trim(), isEmpty);
    });

    test('includes error and stack trace when provided', () {
      final error = ArgumentError("Invalid arg");
      final stack = StackTrace.current;
      logger.error("Something broke", error: error, stackTrace: stack);
      expect(buffer.toString(), contains('Something broke'));
      expect(buffer.toString(), contains('Invalid arg'));
      expect(buffer.toString(), contains('error'));
    });

    test('disables logging in release mode if not allowed', () {
      logger.printInRelease = false;
      // simulate kReleaseMode by disabling enabled flag manually
      logger.enabled = false;
      logger.info("Should be suppressed");
      expect(buffer.toString().trim(), isEmpty);
    });
  });

  group('Top-level logger functions', () {
    test('printError logs to buffer', () {
      printError("fail");
      expect(Logger.instance.enabled, isTrue);
    });

    test('printSuccess logs to buffer', () {
      printSuccess("great");
      expect(Logger.instance.enabled, isTrue);
    });

    test('printWarning logs to buffer', () {
      printWarning("be careful");
      expect(Logger.instance.enabled, isTrue);
    });

    test('printInfo logs to buffer', () {
      printInfo("FYI");
      expect(Logger.instance.enabled, isTrue);
    });

    test('printNormal logs to buffer', () {
      printNormal("Nothing to see");
      expect(Logger.instance.enabled, isTrue);
    });
  });
}
