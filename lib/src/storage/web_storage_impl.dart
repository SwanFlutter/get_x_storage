// This file should only be imported on web platforms
// It provides direct access to the browser's localStorage API
// Using universal_html for cross-platform compatibility

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

/// Web-specific implementation of localStorage access
class WebStorageImpl {
  // Cache for localStorage to improve performance
  static dynamic _cachedLocalStorage;

  // Flag to track if localStorage has been initialized
  static bool _initialized = false;

  /// Returns the browser's localStorage object with caching for better performance
  static dynamic get localStorage {
    // Return cached value if already initialized
    if (_initialized) return _cachedLocalStorage;

    // Return null for non-web platforms
    if (!kIsWeb) {
      _initialized = true;
      _cachedLocalStorage = null;
      return null;
    }

    try {
      // Initialize and cache localStorage
      _cachedLocalStorage = html.window.localStorage;
      _initialized = true;
      return _cachedLocalStorage;
    } catch (e) {
      // Handle errors gracefully
      _initialized = true;
      _cachedLocalStorage = null;
      return null;
    }
  }

  /// Directly check if localStorage is available and working
  static bool get isAvailable {
    // Return false for non-web platforms
    if (!kIsWeb) return false;

    try {
      // Try to access localStorage and perform a test operation
      final storage = html.window.localStorage;
      const testKey = '__get_x_storage_test__';

      // Try to write and read a test value
      storage[testKey] = 'test';
      final result = storage[testKey] == 'test';

      // Clean up the test key
      storage.remove(testKey);

      return result;
    } catch (e) {
      // If any error occurs, localStorage is not available
      return false;
    }
  }

  /// Synchronously read a value from localStorage
  /// This method is optimized for performance and should be used
  /// when immediate access to stored values is needed (e.g., theme settings)
  static String? getItemSync(String key) {
    if (!kIsWeb) return null;

    try {
      final storage = localStorage;
      if (storage == null) return null;

      return storage[key] as String?;
    } catch (e) {
      // Handle errors gracefully
      return null;
    }
  }
}
