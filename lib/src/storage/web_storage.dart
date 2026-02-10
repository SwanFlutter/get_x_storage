import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get_x_storage/src/storage/storage_base.dart';
import 'package:rxdart/rxdart.dart';

// Conditionally import web implementation
import 'web_storage_impl.dart' if (dart.library.io) 'web_storage_stub.dart';

/// A class that implements the `StorageBase` interface for web-based storage.
/// This class uses the browser's `localStorage` to store and manage data in a key-value format.
/// It supports asynchronous initialization, CRUD operations, and listening to changes.
class WebStorage implements StorageBase {
  /// Constructor for WebStorage.
  /// [fileName]: The name of the file (or key) to store data in `localStorage`.
  /// [path]: Optional path (not used in web storage, but included for compatibility).
  WebStorage(this.fileName, [this.path]) {
    // Don't throw an exception for non-web platforms
    // The StorageFactory will handle platform-specific implementations
  }

  /// The name of the file (or key) used to store data in `localStorage`.
  final String fileName;

  /// Optional path (not used in web storage, but included for compatibility).
  final String? path;

  /// The browser's `localStorage` instance used for storing data.
  /// Returns null if localStorage is not available or if not running on web.
  dynamic get _localStorage {
    if (!kIsWeb) {
      // Return null for non-web platforms
      return null;
    }

    // Check if localStorage is available before trying to use it
    if (WebStorageImpl.isAvailable) {
      return WebStorageImpl.localStorage;
    }

    // Return null if localStorage is not available
    return null;
  }

  /// A `BehaviorSubject` that holds the current state of the storage as a map.
  /// It is seeded with an empty map by default.
  @override
  final subject = BehaviorSubject<Map<String, dynamic>>.seeded({});

  /// Initializes the storage with optional initial data.
  /// If data already exists in `localStorage`, it is loaded. Otherwise, the initial data is used.
  /// This implementation is optimized for performance to minimize UI flicker.
  @override
  Future<void> init([Map<String, dynamic>? initialData]) async {
    try {
      // CRITICAL: Load data synchronously FIRST to avoid UI flicker
      final loadedData = _loadDataSync();

      // Determine which data to use
      Map<String, dynamic> dataToUse;

      if (loadedData != null && loadedData.isNotEmpty) {
        // Use loaded data from localStorage (highest priority)
        dataToUse = loadedData;
      } else if (initialData != null) {
        // Use initial data if no stored data exists
        dataToUse = initialData;
      } else {
        // Use empty map as fallback
        dataToUse = {};
      }

      // Update the subject IMMEDIATELY with the correct data
      subject.add(dataToUse);

      // If we have initial data but no stored data, save it in the background
      final localStorage = _localStorage;
      if (initialData != null && loadedData == null && localStorage != null) {
        // Save in the background to avoid blocking the UI
        Future.microtask(() {
          try {
            localStorage[fileName] = json.encode(initialData);
          } catch (e) {
            // Silently handle localStorage errors
          }
        });
      }
    } catch (e) {
      // If anything fails, use initial data or empty map
      subject.add(initialData ?? {});
    }
  }

  /// Load data synchronously from localStorage for immediate access
  /// This is especially important for theme settings to avoid UI flicker
  Map<String, dynamic>? _loadDataSync() {
    try {
      // Use the optimized synchronous method to get data
      final stored = WebStorageImpl.getItemSync(fileName);

      if (stored != null && stored.isNotEmpty) {
        try {
          // Parse the stored JSON data
          return json.decode(stored) as Map<String, dynamic>;
        } catch (e) {
          // If parsing fails, return null
          return null;
        }
      }
    } catch (e) {
      // Silently handle errors
    }
    return null;
  }

  /// Reads a value from the storage by its key.
  /// Returns `null` if the key does not exist.
  @override
  T? read<T>({required String key}) => subject.value[key] as T?;

  /// Writes a value to the storage for a given key.
  /// Updates the `subject` and persists the data in `localStorage`.
  /// This implementation ensures data is saved immediately for web.
  @override
  Future<void> write({required String key, required dynamic value}) async {
    // Create a new map with the updated value
    final newData = Map<String, dynamic>.from(subject.value)..[key] = value;

    // Update the in-memory data immediately
    subject.add(newData);

    // CRITICAL: For web, we need to save IMMEDIATELY, not in microtask
    // Otherwise data might be lost when browser closes
    try {
      final localStorage = _localStorage;
      if (localStorage != null) {
        // Convert the entire data map to JSON and store it
        final jsonData = json.encode(newData);
        localStorage[fileName] = jsonData;
      }
    } catch (e) {
      // Silently handle localStorage errors
      // In-memory data is already updated, so the app will continue to work
    }

    // Return immediately for better responsiveness
    return Future.value();
  }

  /// Removes a value from the storage by its key.
  /// Updates the `subject` and persists the changes in `localStorage`.
  /// This implementation ensures data is saved immediately for web.
  @override
  Future<void> remove({required String key}) async {
    // Create a new map without the removed key
    final newData = Map<String, dynamic>.from(subject.value)..remove(key);

    // Update the in-memory data immediately
    subject.add(newData);

    // CRITICAL: For web, we need to save IMMEDIATELY
    try {
      final localStorage = _localStorage;
      if (localStorage != null) {
        // Convert the entire data map to JSON and store it
        localStorage[fileName] = json.encode(newData);
      }
    } catch (e) {
      // Silently handle localStorage errors
      // In-memory data is already updated, so the app will continue to work
    }

    // Return immediately for better responsiveness
    return Future.value();
  }

  /// Clears all data from the storage.
  /// Resets the `subject` to an empty map and removes the data from `localStorage`.
  /// This implementation ensures data is saved immediately for web.
  @override
  Future<void> clear() async {
    // Reset the in-memory data to an empty map immediately
    subject.add({});

    // CRITICAL: For web, we need to save IMMEDIATELY
    try {
      final localStorage = _localStorage;
      if (localStorage != null) {
        // Remove the entire entry from localStorage
        localStorage.remove(fileName);
      }
    } catch (e) {
      // Silently handle localStorage errors
      // In-memory data is already cleared, so the app will continue to work
    }

    // Return immediately for better responsiveness
    return Future.value();
  }

  /// Returns an iterable of all keys in the storage.
  @override
  Iterable<String> getKeys() => subject.value.keys;

  /// Returns an iterable of all values in the storage.
  @override
  Iterable<dynamic> getValues() => subject.value.values;

  /// Updates the value of a specific key in the storage.
  /// Updates the `subject` and persists the changes in `localStorage`.
  /// This implementation ensures data is saved immediately for web.
  @override
  void changeValueOfKey({required String key, required dynamic newValue}) {
    // Create a new map with the updated value
    final newData = Map<String, dynamic>.from(subject.value)..[key] = newValue;

    // Update the in-memory data immediately
    subject.add(newData);

    // CRITICAL: For web, we need to save IMMEDIATELY
    // Otherwise data might be lost when browser closes
    try {
      final localStorage = _localStorage;
      if (localStorage != null) {
        // Convert the entire data map to JSON and store it
        localStorage[fileName] = json.encode(newData);
      }
    } catch (e) {
      // Silently handle localStorage errors
      // In-memory data is already updated, so the app will continue to work
    }
  }
}
