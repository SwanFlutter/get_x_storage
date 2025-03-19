import 'dart:convert';

import 'package:get_x_storage/src/storage/storage_base.dart';
import 'package:rxdart/rxdart.dart';
import 'package:web/web.dart' as web;

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

  /// The browser's `localStorage` instance used for storing data.
  final web.Storage _localStorage = web.window.localStorage;

  /// A `BehaviorSubject` that holds the current state of the storage as a map.
  /// It is seeded with an empty map by default.
  @override
  final BehaviorSubject<Map<String, dynamic>> subject = BehaviorSubject.seeded(
    {},
  );

  /// Initializes the storage with optional initial data.
  /// If data already exists in `localStorage`, it is loaded. Otherwise, the initial data is used.
  @override
  Future<void> init([Map<String, dynamic>? initialData]) async {
    final stored = _localStorage[fileName];
    subject.add(
      initialData ??
          (stored != null ? json.decode(stored) as Map<String, dynamic> : {}),
    );
  }

  /// Reads a value from the storage by its key.
  /// Returns `null` if the key does not exist.
  @override
  T? read<T>({required String key}) => subject.value[key] as T?;

  /// Writes a value to the storage for a given key.
  /// Updates the `subject` and persists the data in `localStorage`.
  @override
  Future<void> write({required String key, required dynamic value}) async {
    final newData = Map<String, dynamic>.from(subject.value)..[key] = value;
    subject.add(newData);
    _localStorage[fileName] = json.encode(newData);
  }

  /// Removes a value from the storage by its key.
  /// Updates the `subject` and persists the changes in `localStorage`.
  @override
  Future<void> remove({required String key}) async {
    final newData = Map<String, dynamic>.from(subject.value)..remove(key);
    subject.add(newData);
    _localStorage[fileName] = json.encode(newData);
  }

  /// Clears all data from the storage.
  /// Resets the `subject` to an empty map and removes the data from `localStorage`.
  @override
  Future<void> clear() async {
    subject.add({});
    _localStorage.removeItem(fileName);
  }

  /// Returns an iterable of all keys in the storage.
  @override
  Iterable<String> getKeys() => subject.value.keys;

  /// Returns an iterable of all values in the storage.
  @override
  Iterable<dynamic> getValues() => subject.value.values;

  /// Updates the value of a specific key in the storage.
  /// Updates the `subject` and persists the changes in `localStorage`.
  @override
  void changeValueOfKey({required String key, required dynamic newValue}) {
    final newData = Map<String, dynamic>.from(subject.value)..[key] = newValue;
    subject.add(newData);
    _localStorage[fileName] = json.encode(newData);
  }
}
