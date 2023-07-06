// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import '../enums.dart';
import '../path_platform_interface.dart';

import 'package:flutter/foundation.dart';
import 'messages.g.dart';

/// The iOS and macOS implementation of [PathPlatform].
class PathFoundation extends PathPlatform {
  /// Constructor that accepts a testable PathPlatformProvider.
  PathFoundation({
    @visibleForTesting PathPlatformProvider? platform,
  }) : _platformProvider = platform ?? PathPlatformProvider();

  final PathPlatformProvider _platformProvider;
  final PathApi _Path = PathApi();

  /// Registers this class as the default instance of [PathPlatform]
  static void registerWith() {
    PathPlatform.instance = PathFoundation();
  }

  @override
  Future<String?> getTemporaryPath() {
    return _Path.getDirectoryPath(DirectoryType.temp);
  }

  @override
  Future<String?> getApplicationSupportPath() async {
    final String? path =
        await _Path.getDirectoryPath(DirectoryType.applicationSupport);
    if (path != null) {
      // Ensure the directory exists before returning it, for consistency with
      // other platforms.
      await Directory(path).create(recursive: true);
    }
    return path;
  }

  @override
  Future<String?> getLibraryPath() {
    return _Path.getDirectoryPath(DirectoryType.library);
  }

  @override
  Future<String?> getApplicationDocumentsPath() {
    return _Path.getDirectoryPath(DirectoryType.applicationDocuments);
  }

  @override
  Future<String?> getExternalStoragePath() async {
    throw UnsupportedError(
        'getExternalStoragePath is not supported on this platform');
  }

  @override
  Future<List<String>?> getExternalCachePaths() async {
    throw UnsupportedError(
        'getExternalCachePaths is not supported on this platform');
  }

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async {
    throw UnsupportedError(
        'getExternalStoragePaths is not supported on this platform');
  }

  @override
  Future<String?> getDownloadsPath() {
    return _Path.getDirectoryPath(DirectoryType.downloads);
  }

  /// Returns the path to the container of the specified App Group.
  /// This is only supported for iOS.
  Future<String?> getContainerPath({required String appGroupIdentifier}) async {
    if (!_platformProvider.isIOS) {
      throw UnsupportedError(
          'getContainerPath is not supported on this platform');
    }
    return _Path.getContainerPath(appGroupIdentifier);
  }
}

/// Helper class for returning information about the current platform.
@visibleForTesting
class PathPlatformProvider {
  /// Specifies whether the current platform is iOS.
  bool get isIOS => Platform.isIOS;
}
