// This file should only be imported on web platforms
// It provides direct access to the browser's localStorage API

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:web/web.dart' as web;

/// Web-specific implementation of localStorage access
class WebStorageImpl {
  /// Returns the browser's localStorage object without caching to avoid issues with hot reload
  static web.Storage? get localStorage {
    if (!kIsWeb) {
      return null;
    }

    try {
      return web.window.localStorage;
    } catch (e) {
      return null;
    }
  }

  /// Directly check if localStorage is available and working
  static bool get isAvailable {
    if (!kIsWeb) return false;

    try {
      final storage = localStorage;
      if (storage == null) {
        return false;
      }
      const testKey = '__get_x_storage_test__';

      storage.setItem(testKey, 'test');
      final result = storage.getItem(testKey) == 'test';
      storage.removeItem(testKey);

      return result;
    } catch (e) {
      return false;
    }
  }

  /// Synchronously read a value from localStorage
  static String? getItemSync(String key) {
    if (!kIsWeb) return null;

    try {
      final storage = localStorage;
      if (storage == null) {
        return null;
      }

      return storage.getItem(key);
    } catch (e) {
      return null;
    }
  }

  /// Synchronously write a value to localStorage
  static void setItemSync(String key, String value) {
    if (!kIsWeb) return;

    try {
      final storage = localStorage;
      if (storage == null) {
        return;
      }

      storage.setItem(key, value);
    } catch (e) {
      // Silently handle errors
    }
  }

  /// Synchronously remove a value from localStorage
  static void removeItemSync(String key) {
    if (!kIsWeb) return;

    try {
      final storage = localStorage;
      if (storage == null) {
        return;
      }

      storage.removeItem(key);
    } catch (e) {
      // Silently handle errors
    }
  }
}
