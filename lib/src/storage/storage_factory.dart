import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get_x_storage/src/storage/storage_base.dart';
import 'package:get_x_storage/src/storage/web_storage.dart';

import 'io_storage.dart';

/// A factory class responsible for creating storage instances based on the platform.
class StorageFactory {
  /// Creates an instance of [StorageBase] tailored to the current platform.
  /// This method uses platform detection to decide which storage implementation to use:
  /// - [WebStorage] for web platforms.
  /// - [IOStorage] for mobile and desktop platforms (Android, iOS, Windows, Linux, macOS).
  ///
  /// [key] The identifier for the storage instance (e.g., file name or container name).
  /// [path] An optional path for storage location (e.g., directory for file-based storage).
  /// Returns an instance of [StorageBase] appropriate for the platform.
  static StorageBase create(String key, String? path) {
    if (kIsWeb) {
      // Use WebStorage for web platforms, leveraging browser's localStorage.
      return WebStorage(key, path);
    } else if (Platform.isAndroid) {
      // Use IOStorage for Android, utilizing the device's file system.
      return IOStorage(key, path);
    } else if (Platform.isIOS) {
      // Use IOStorage for iOS, utilizing the device's file system.
      return IOStorage(key, path);
    } else if (Platform.isWindows) {
      // Use IOStorage for Windows, utilizing the device's file system.
      return IOStorage(key, path);
    } else if (Platform.isLinux) {
      // Use IOStorage for Linux, utilizing the device's file system.
      return IOStorage(key, path);
    } else if (Platform.isMacOS) {
      // Use IOStorage for macOS, utilizing the device's file system.
      return IOStorage(key, path);
    } else {
      // Fallback for unknown or unsupported platforms.
      // Throws an error with the detected platform name for debugging purposes.
      throw UnsupportedError(
        'This platform is not supported by GetXStorage: ${Platform.operatingSystem}',
      );
    }
  }
}
