import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get_x_storage/src/storage/html_storage.dart';
import 'package:get_x_storage/src/storage/storage_base.dart';

import 'io_storage.dart';

/// A factory class for creating instances of `StorageBase`.
/// This class provides a centralized way to instantiate different storage implementations
/// based on the platform (web, mobile, or desktop).

class StorageFactory {
  /// Creates and returns an instance of `StorageBase`.
  /// This method automatically selects the appropriate storage implementation
  /// based on the platform:
  /// - For web: `WebStorage` is used.
  /// - For mobile and desktop: `IOStorage` is used.
  ///
  /// [key]: The identifier for the storage instance (e.g., file name or container name).
  /// [path]: Optional path for the storage (e.g., directory path for file-based storage).
  ///
  /// Returns: An instance of `StorageBase` (`WebStorage` for web, `IOStorage` for others).
  static StorageBase create(String key, String? path) {
    if (kIsWeb) {
      // Use WebStorage for web platforms
      return WebStorage(key, path);
    } else {
      // Use IOStorage for mobile and desktop platforms
      return IOStorage(key, path);
    }
  }
}
