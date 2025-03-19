import 'dart:async';

import 'package:rxdart/rxdart.dart';

/// An abstract class that defines the interface for storage implementations.
/// This class provides a contract for managing data in a key-value format,
/// including initialization, CRUD operations, and listening to changes.

abstract class StorageBase {
  /// Initializes the storage with optional initial data.
  /// This method should be called before any other operations.
  Future<void> init([Map<String, dynamic>? initialData]);

  /// Reads a value from the storage by its key.
  /// Returns `null` if the key does not exist.
  T? read<T>({required String key});

  /// Returns an iterable of all keys in the storage.
  Iterable<String> getKeys();

  /// Returns an iterable of all values in the storage.
  Iterable<dynamic> getValues();

  /// Writes a value to the storage for a given key.
  /// If the key already exists, its value will be updated.
  Future<void> write({required String key, required dynamic value});

  /// Removes a value from the storage by its key.
  /// If the key does not exist, no action is taken.
  Future<void> remove({required String key});

  /// Clears all data from the storage.
  Future<void> clear();

  /// A `BehaviorSubject` that holds the current state of the storage as a map.
  /// This allows listening to changes in the storage.
  BehaviorSubject<Map<String, dynamic>> get subject;

  /// Updates the value of a specific key in the storage.
  /// If the key does not exist, it will be created.
  void changeValueOfKey({required String key, required dynamic newValue});
}
