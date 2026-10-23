import 'package:activity/activity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'parses quoted comments, expands variables and exposes typed values',
    () {
      final env = ENVSetup();
      env.loadString('''
      # comment
HOST="example.com" # trailing comment
URL=https://\${HOST}/api
PORT=8080
READY=yes
TIMEOUT=PT2M
LITERAL='hello # world' # comment
''');
      expect(env.getString('LITERAL'), 'hello # world');
      expect(env.getUri('URL').host, 'example.com');
      expect(env.getInt('PORT'), 8080);
      expect(env.getBool('READY'), isTrue);
      expect(env.getDuration('TIMEOUT'), const Duration(minutes: 2));
      expect(() => env.values['PORT'] = '1', throwsUnsupportedError);
      expect(() => env.getInt('HOST'), throwsFormatException);
    },
  );
  test('malformed quoted input is rejected without merging partial input', () {
    final env = ENVSetup();
    expect(
      () => env.loadString('GOOD=1\nBAD="unterminated'),
      throwsFormatException,
    );
    expect(env.values, isEmpty);
  });
}
