import 'dart:io';

bool isAndroidPlatform() {
  return Platform.isAndroid;
}

bool isIosPlatform() {
  return Platform.isIOS;
}

bool isMacPlatform() {
  return Platform.isMacOS;
}

bool isWindowsPlatform() {
  return Platform.isWindows;
}