import 'dart:async';
import 'dart:convert';

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
  WebStorage(this.fileName, [this.path]);

  /// The name of the file (or key) used to store data in `localStorage`.
  final String fileName;

  /// Optional path (not used in web storage, but included for compatibility).
  final String? path;

  /// A `BehaviorSubject` that holds the current state of the storage as a map.
  /// It is seeded with an empty map by default.
  @override
  final subject = BehaviorSubject<Map<String, dynamic>>.seeded({});

  /// Track whether we've initialized to avoid redundant loads
  bool _isInitialized = false;

  /// Ensures data is loaded from localStorage if not already initialized
  void _ensureLoaded() {
    if (_isInitialized) return;

    final loadedData = _loadDataSync();
    if (loadedData != null && loadedData.isNotEmpty) {
      subject.add(loadedData);
    }
    _isInitialized = true;
  }

  /// Initializes the storage with optional initial data.
  /// CRITICAL: Always loads from localStorage first to support hot reload
  /// If no data exists in localStorage, uses initialData
  @override
  Future<void> init([Map<String, dynamic>? initialData]) async {
    try {
      // CRITICAL: Always load from localStorage FIRST
      // This ensures hot reload works correctly
      final loadedData = _loadDataSync();

      Map<String, dynamic> dataToUse;

      if (loadedData != null && loadedData.isNotEmpty) {
        // Use loaded data from localStorage (highest priority)
        dataToUse = loadedData;
      } else if (initialData != null && initialData.isNotEmpty) {
        // Use initial data if no stored data exists
        dataToUse = initialData;

        // Save initial data to localStorage immediately using the new API
        try {
          WebStorageImpl.setItemSync(fileName, json.encode(initialData));
        } catch (e) {
          // Silently handle localStorage errors
        }
      } else {
        // Use empty map as fallback
        dataToUse = {};
      }

      // Update the subject IMMEDIATELY with the correct data
      subject.add(dataToUse);
      _isInitialized = true;
    } catch (e) {
      // If anything fails, use initial data or empty map
      subject.add(initialData ?? {});
      _isInitialized = true;
    }
  }

  /// Load data synchronously from localStorage for immediate access
  /// This is especially important for theme settings to avoid UI flicker
  Map<String, dynamic>? _loadDataSync() {
    try {
      final stored = WebStorageImpl.getItemSync(fileName);

      if (stored != null && stored.isNotEmpty) {
        try {
          final decoded = json.decode(stored);
          if (decoded is Map<String, dynamic>) {
            return decoded;
          }
          return null;
        } catch (e) {
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
  T? read<T>({required String key}) {
    _ensureLoaded();
    return subject.value[key] as T?;
  }

  /// Writes a value to the storage for a given key.
  /// Updates the `subject` and persists the data in `localStorage`.
  @override
  Future<void> write({required String key, required dynamic value}) async {
    _ensureLoaded();

    // Create a new map with the updated value
    final newData = Map<String, dynamic>.from(subject.value)..[key] = value;

    // Update the in-memory data immediately
    subject.add(newData);

    // Save to localStorage IMMEDIATELY using the new API
    try {
      final jsonData = json.encode(newData);
      WebStorageImpl.setItemSync(fileName, jsonData);
    } catch (e) {
      // Silently handle localStorage errors
    }

    return Future.value();
  }

  /// Removes a value from the storage by its key.
  /// Updates the `subject` and persists the changes in `localStorage`.
  @override
  Future<void> remove({required String key}) async {
    _ensureLoaded();

    // Create a new map without the removed key
    final newData = Map<String, dynamic>.from(subject.value)..remove(key);

    // Update the in-memory data immediately
    subject.add(newData);

    // Save to localStorage IMMEDIATELY using the new API
    try {
      WebStorageImpl.setItemSync(fileName, json.encode(newData));
    } catch (e) {
      // Silently handle localStorage errors
    }

    return Future.value();
  }

  /// Clears all data from the storage.
  /// Resets the `subject` to an empty map and removes the data from `localStorage`.
  @override
  Future<void> clear() async {
    // Reset the in-memory data to an empty map immediately
    subject.add({});

    // Remove from localStorage IMMEDIATELY using the new API
    try {
      WebStorageImpl.removeItemSync(fileName);
    } catch (e) {
      // Silently handle localStorage errors
    }

    return Future.value();
  }

  /// Returns an iterable of all keys in the storage.
  @override
  Iterable<String> getKeys() {
    _ensureLoaded();
    return subject.value.keys;
  }

  /// Returns an iterable of all values in the storage.
  @override
  Iterable<dynamic> getValues() {
    _ensureLoaded();
    return subject.value.values;
  }

  /// Updates the value of a specific key in the storage.
  /// Updates the `subject` and persists the changes in `localStorage`.
  @override
  void changeValueOfKey({required String key, required dynamic newValue}) {
    _ensureLoaded();

    // Create a new map with the updated value
    final newData = Map<String, dynamic>.from(subject.value)..[key] = newValue;

    // Update the in-memory data immediately
    subject.add(newData);

    // Save to localStorage IMMEDIATELY using the new API
    try {
      WebStorageImpl.setItemSync(fileName, json.encode(newData));
    } catch (e) {
      // Silently handle localStorage errors
    }
  }
}
