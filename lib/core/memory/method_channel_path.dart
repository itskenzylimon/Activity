// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io' show Platform;
import 'enums.dart';
import './path_platform_interface.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';


/// An implementation of [PathPlatform] that uses method channels.
class MethodChannelPath extends PathPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  MethodChannel methodChannel =
  const MethodChannel('plugins.flutter.io/path');


  // Ideally, this property shouldn't exist, and each platform should
  // just implement the supported methods. Once all the platforms are
  // federated, this property should be removed.
  //Platform _platform =  Platform();
  
 

  @override
  Future<String?> getTemporaryPath() {
    return methodChannel.invokeMethod<String>('getTemporaryDirectory');
  }

  @override
  Future<String?> getApplicationSupportPath() {
    return methodChannel.invokeMethod<String>('getApplicationSupportDirectory');
  }

  @override
  Future<String?> getLibraryPath() {
    if (!Platform.isIOS && !Platform.isMacOS) {
      throw UnsupportedError('Functionality only available on iOS/macOS');
    }
    return methodChannel.invokeMethod<String>('getLibraryDirectory');
  }

  @override
  Future<String?> getApplicationDocumentsPath() {
    return methodChannel
        .invokeMethod<String>('getApplicationDocumentsDirectory');
  }

  @override
  Future<String?> getExternalStoragePath() {
    if (!Platform.isAndroid) {
      throw UnsupportedError('Functionality only available on Android');
    }
    return methodChannel.invokeMethod<String>('getStorageDirectory');
  }

  @override
  Future<List<String>?> getExternalCachePaths() {
    if (!Platform.isAndroid) {
      throw UnsupportedError('Functionality only available on Android');
    }
    return methodChannel
        .invokeListMethod<String>('getExternalCacheDirectories');
  }

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async {
    if (!Platform.isAndroid) {
      throw UnsupportedError('Functionality only available on Android');
    }
    return methodChannel.invokeListMethod<String>(
      'getExternalStorageDirectories',
      <String, dynamic>{'type': type?.index},
    );
  }

  @override
  Future<String?> getDownloadsPath() {
    if (!Platform.isMacOS) {
      throw UnsupportedError('Functionality only available on macOS');
    }
    return methodChannel.invokeMethod<String>('getDownloadsDirectory');
  }
}
