import 'dart:convert';
import 'dart:js_interop';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web/web.dart' as web;

/// Flutter's browser widget-test server serves test/, not the application asset
/// bundle, and its engine asset channel does not resolve these requests. Load
/// exact staged application files over HTTP; no translations/source are mocked.
void configureBrowserAssets() {
  TestWidgetsFlutterBinding.ensureInitialized();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (message) async {
        final key = utf8.decode(
          message!.buffer.asUint8List(
            message.offsetInBytes,
            message.lengthInBytes,
          ),
        );
        final uri = Uri.base.resolve('/.web-assets/$key');
        final response = await web.window.fetch(uri.toString().toJS).toDart;
        if (!response.ok) {
          throw FlutterError(
            'Browser fixture unavailable: $key (${response.status})',
          );
        }
        final bytes = (await response.arrayBuffer().toDart).toDart
            .asUint8List();
        return ByteData.sublistView(bytes);
      });
  rootBundle.clear();
}
