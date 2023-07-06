import 'dart:io';
import 'ios/path_foundation.dart';
import 'android/path_android.dart';
import 'path_platform_interface.dart';
import 'enums.dart';

/// An exception thrown when a directory that should always be available on
/// the current platform cannot be obtained.
class MissingPlatformDirectoryException implements Exception {
  /// Creates a new exception
  MissingPlatformDirectoryException(this.message, {this.details});

  /// The explanation of the exception.
  final String message;

  /// Added details, if any.
  ///
  /// E.g., an error object from the platform implementation.
  final Object? details;

  @override
  String toString() {
    final String detailsAddition = details == null ? '' : ': $details';
    return 'MissingPlatformDirectoryException($message)$detailsAddition';
  }
}

PathPlatform get _platform =>
    ((Platform.isAndroid? PathAndroid():
    ((Platform.isIOS? PathFoundation() :
    PathPlatform.instance))));

/// Path to the temporary directory on the device that is not backed up and is
/// suitable for storing caches of downloaded files.
///
/// Files in this directory may be cleared at any time. This does *not* return
/// a new temporary directory. Instead, the caller is responsible for creating
/// (and cleaning up) files or directories within this directory. This
/// directory is scoped to the calling application.
///
/// Example implementations:
/// - `NSCachesDirectory` on iOS and macOS.
/// - `Context.getCacheDir` on Android.
///
/// Throws a [MissingPlatformDirectoryException] if the system is unable to
/// provide the directory.
Future<Directory> getTemporaryDirectory() async {
  final String? path = await _platform.getTemporaryPath();
  if (path == null) {
    throw MissingPlatformDirectoryException(
        'Unable to get temporary directory');
  }
  return Directory(path);
}

/// Path to a directory where the application may place application support
/// files.
///
/// If this directory does not exist, it is created automatically.
///
/// Use this for files you don’t want exposed to the user. Your app should not
/// use this directory for user data files.
///
/// Example implementations:
/// - `NSApplicationSupportDirectory` on iOS and macOS.
/// - The Flutter engine's `PathUtils.getFilesDir` API on Android.
///
/// Throws a [MissingPlatformDirectoryException] if the system is unable to
/// provide the directory.
Future<Directory> getApplicationSupportDirectory() async {
  final String? path = await _platform.getApplicationSupportPath();
  if (path == null) {
    throw MissingPlatformDirectoryException(
        'Unable to get application support directory');
  }

  return Directory(path);
}

/// Path to the directory where application can store files that are persistent,
/// backed up, and not visible to the user, such as sqlite.db.
///
/// Example implementations:
/// - `NSApplicationSupportDirectory` on iOS and macOS.
///
/// Throws an [UnsupportedError] if this is not supported on the current
/// platform. For example, this is unlikely to ever be supported on Android,
/// as no equivalent path exists.
///
/// Throws a [MissingPlatformDirectoryException] if the system is unable to
/// provide the directory on a supported platform.
Future<Directory> getLibraryDirectory() async {
  final String? path = await _platform.getLibraryPath();
  if (path == null) {
    throw MissingPlatformDirectoryException('Unable to get library directory');
  }
  return Directory(path);
}

/// Path to a directory where the application may place data that is
/// user-generated, or that cannot otherwise be recreated by your application.
///
/// Consider using another path, such as [getApplicationSupportDirectory] or
/// [getExternalStorageDirectory], if the data is not user-generated.
///
/// Example implementations:
/// - `NSDocumentDirectory` on iOS and macOS.
/// - The Flutter engine's `PathUtils.getDataDirectory` API on Android.
///
/// Throws a [MissingPlatformDirectoryException] if the system is unable to
/// provide the directory.
Future<Directory> getApplicationDocumentsDirectory() async {
  final String? path = await _platform.getApplicationDocumentsPath();
  if (path == null) {
    throw MissingPlatformDirectoryException(
        'Unable to get application documents directory');
  }
  return Directory(path);
}

/// Path to a directory where the application may access top level storage.
///
/// Example implementation:
/// - `getExternalFilesDir(null)` on Android.
///
/// Throws an [UnsupportedError] if this is not supported on the current
/// platform (for example, on iOS where it is not possible to access outside
/// the app's sandbox).
Future<Directory?> getExternalStorageDirectory() async {
  final String? path = await _platform.getExternalStoragePath();
  if (path == null) {
    return null;
  }
  return Directory(path);
}

/// Paths to directories where application specific cache data can be stored
/// externally.
///
/// These paths typically reside on external storage like separate partitions
/// or SD cards. Phones may have multiple storage directories available.
///
/// Example implementation:
/// - Context.getExternalCacheDirs() on Android (or
///   Context.getExternalCacheDir() on API levels below 19).
///
/// Throws an [UnsupportedError] if this is not supported on the current
/// platform. This is unlikely to ever be supported on any platform other than
/// Android.
Future<List<Directory>?> getExternalCacheDirectories() async {
  final List<String>? paths = await _platform.getExternalCachePaths();
  if (paths == null) {
    return null;
  }

  return paths.map((String path) => Directory(path)).toList();
}

/// Paths to directories where application specific data can be stored
/// externally.
///
/// These paths typically reside on external storage like separate partitions
/// or SD cards. Phones may have multiple storage directories available.
///
/// Example implementation:
/// - Context.getExternalFilesDirs(type) on Android (or
///   Context.getExternalFilesDir(type) on API levels below 19).
///
/// Throws an [UnsupportedError] if this is not supported on the current
/// platform. This is unlikely to ever be supported on any platform other than
/// Android.
Future<List<Directory>?> getExternalStorageDirectories({
  /// Optional parameter. See [StorageDirectory] for more informations on
  /// how this type translates to Android storage directories.
  StorageDirectory? type,
}) async {
  final List<String>? paths =
  await _platform.getExternalStoragePaths(type: type);
  if (paths == null) {
    return null;
  }

  return paths.map((String path) => Directory(path)).toList();
}

/// Path to the directory where downloaded files can be stored.
///
/// The returned directory is not guaranteed to exist, so clients should verify
/// that it does before using it, and potentially create it if necessary.
///
/// Throws an [UnsupportedError] if this is not supported on the current
/// platform.
Future<Directory?> getDownloadsDirectory() async {
  final String? path = await _platform.getDownloadsPath();
  if (path == null) {
    return null;
  }
  return Directory(path);
}
