// ignore_for_file: unnecessary_cast

import 'dart:async';

import 'package:get_x_storage/src/storage/io_storage.dart';
import 'package:get_x_storage/src/storage/storage_base.dart';
import 'package:get_x_storage/src/storage/storage_factory.dart';

/// A class for managing persistent storage using the GetX pattern.
/// This class provides a simple, efficient interface to store, retrieve, and manage data
/// in a key-value format. It supports asynchronous initialization, real-time change listening,
/// and basic CRUD operations (create, read, update, delete).
///
/// Example usage:
/// ```dart
/// void main() async {
///   final storage = GetXStorage('UserPreferences');
///   await storage.init(); // Initialize the storage
///   await storage.write(key: 'username', value: 'Alice'); // Save a value
///   print(storage.read<String>(key: 'username')); // Prints: Alice
///   storage.listen(() => print('Data changed!')); // Listen for changes
/// }
/// ```
class GetXStorage {
  /// Factory constructor to create or retrieve a [GetXStorage] instance.
  /// Ensures singleton behavior: if an instance with the same [container] name exists,
  /// it returns that instance; otherwise, it creates a new one and stores it in [_sync].
  ///
  /// [container] The unique identifier for this storage instance. Defaults to 'GetStorage'.
  /// [path] Optional path for storage location (e.g., custom directory for file-based storage).
  /// [initialData] Optional initial key-value pairs to populate the storage.
  ///
  /// Example:
  /// ```dart
  /// final storage = GetXStorage('Settings', initialData: {'theme': 'dark'});
  ///
  ///
  /// ```
  ///
  ///
  factory GetXStorage([
    String container = 'GetStorage',
    String? path,
    Map<String, dynamic>? initialData,
  ]) {
    if (_sync.containsKey(container)) {
      return _sync[container]!;
    } else {
      final instance = GetXStorage._internal(container, path, initialData);
      _sync[container] = instance;
      return instance;
    }
  }

  /// Private constructor to initialize a new [GetXStorage] instance.
  /// Configures the underlying storage implementation and prepares it for use.
  /// Should only be called by the factory constructor.
  GetXStorage._internal(
    String key, [
    String? path,
    Map<String, dynamic>? initialData,
  ]) {
    _concrete = StorageFactory.create(key, path);
    initStorage = Future<bool>(() async {
      try {
        await _concrete.init(initialData);
        return true;
      } catch (e) {
        throw Exception('Initialization failed: $e');
      }
    });
  }

  /// A static map storing all [GetXStorage] instances by their container names.
  /// Prevents duplicate instances for the same container.
  static final Map<String, GetXStorage> _sync = {};

  /// The concrete storage implementation (e.g., [IOStorage] or [WebStorage]).
  late final StorageBase _concrete;

  /// A future indicating whether storage initialization was successful.
  /// Resolves to `true` on success, `false` on failure.
  late final Future<bool> initStorage;

  /// A stream that emits the current state of the storage as a map whenever it changes.
  /// Useful for reactive updates in UI or logic.
  ///
  /// Example:
  /// ```dart
  /// storage.stream.listen((data) => print('Current storage: $data'));
  /// ```
  Stream<Map<String, dynamic>> get stream => _concrete.subject.stream;

  /// Initializes the storage for a specific [container].
  /// Returns a future that resolves to `true` if initialization succeeds, `false` otherwise.
  ///
  /// [container] The name of the storage container to initialize.
  ///
  /// Example:
  /// ```dart
  /// bool success = await GetXStorage.init('AppData');
  /// if (success) print('Storage ready!');
  ///
  ///
  /// ```
  static Future<bool> init([String container = 'GetStorage']) {
    return GetXStorage(container).initStorage;
  }

  /// Reads a value from the storage by its [key].
  /// Returns `null` if the key doesn't exist or the type [T] doesn't match the stored value.
  ///
  /// [key] The key to look up in the storage.
  ///
  /// Example:
  /// ```dart
  /// final name = storage.read<String>(key: 'username');
  /// print(name ?? 'No user found'); // Prints: Alice (or "No user found" if not set)
  /// ```
  T? read<T>({required String key}) => _concrete.read<T>(key: key);

  /// Reads a list of type [T] from the storage by its [key].
  /// This method is specifically designed for reading lists with type safety.
  /// Returns `null` if the key doesn't exist or the stored value is not a list.
  ///
  /// [key] The key to look up in the storage.
  ///
  /// Example:
  /// ```dart
  /// final fruits = storage.readList<String>(key: 'fruits');
  /// print(fruits ?? []); // Prints: ['apple', 'banana', 'cherry'] or []
  ///
  /// final numbers = storage.readList<int>(key: 'numbers');
  /// print(numbers ?? []); // Prints: [1, 2, 3, 4, 5] or []
  ///
  /// final users = storage.readList<Map<String, dynamic>>(key: 'users');
  /// print(users?.length ?? 0); // Prints: 2 or 0
  /// ```
  List<T>? readList<T>({required String key}) {
    try {
      final data = _concrete.read<dynamic>(key: key);
      if (data == null) return null;

      // Check if the data is actually a list
      if (data is! List) return null;

      // Convert to List<dynamic> first
      final dynamicList = data as List<dynamic>;

      // Try to cast each element to the desired type
      final List<T> result = [];
      for (final item in dynamicList) {
        if (item is T) {
          result.add(item);
        } else {
          // If any item can't be cast to T, return null
          return null;
        }
      }

      return result;
    } catch (e) {
      return null;
    }
  }

  /// Returns an iterable of all keys currently stored in the storage.
  /// Useful for inspecting or iterating over stored data.
  ///
  /// Example:
  /// ```dart
  /// final keys = storage.getKeys();
  /// print('Stored keys: $keys'); // Prints: (username, age)
  ///
  ///
  /// ```
  Iterable<String> getKeys() => _concrete.getKeys();

  /// Returns an iterable of all values currently stored in the storage.
  /// Useful for bulk retrieval of data.
  ///
  /// Example:
  /// ```dart
  /// final values = storage.getValues();
  /// print('Stored values: $values'); // Prints: (Alice, 25)
  ///
  ///
  /// ```
  Iterable<dynamic> getValues() => _concrete.getValues();

  /// Checks if the storage contains data for the specified [key].
  /// Returns `true` if the key exists and has a non-null value, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// if (storage.hasData(key: 'email')) {
  ///   print('Email is set!');
  /// }
  ///
  ///
  /// ```
  bool hasData({required String key}) => read(key: key) != null;

  /// Listens to any changes in the storage and invokes the [callback] when they occur.
  /// Returns a [StreamSubscription] that can be cancelled to stop listening.
  ///
  /// Example:
  /// ```dart
  /// final subscription = storage.listen(() {
  ///   print('Something changed in storage!');
  /// });
  /// // Later, to stop listening:
  /// subscription.cancel();
  ///
  ///
  /// ```
  StreamSubscription? listen(void Function() callback) {
    return _concrete.subject.stream.listen((_) => callback());
  }

  /// Listens to changes for a specific [key] and invokes the [callback] with the new value.
  /// Only emits when the value changes and is non-null, avoiding duplicate events.
  ///
  /// [key] The key to monitor for changes.
  /// [callback] The function to call with the updated value.
  ///
  /// Example:
  /// ```dart
  /// final subscription = storage.listenKey(
  ///   key: 'score',
  ///   callback: (value) => print('New score: $value'),
  /// );
  /// await storage.write(key: 'score', value: 100); // Prints: New score: 100
  /// subscription.cancel();
  ///
  ///
  /// ```
  StreamSubscription listenKey({
    required String key,
    required void Function(dynamic) callback,
  }) {
    return _concrete.subject.stream
        .map((map) => map[key])
        .where((value) => value != null)
        .distinct()
        .listen(callback);
  }

  /// Writes a [value] to the storage under the specified [key].
  /// Overwrites any existing value for that key.
  ///
  /// [key] The key to associate with the value.
  /// [value] The data to store (can be any type).
  ///
  /// Example:
  /// ```dart
  /// await storage.write(key: 'age', value: 25);
  /// print(storage.read<int>(key: 'age')); // Prints: 25
  ///
  ///
  /// ```
  Future<void> write({required String key, required dynamic value}) async {
    try {
      await _concrete.write(key: key, value: value);
    } catch (e) {
      throw Exception('Failed to write to storage: $e');
    }
  }

  /// Writes a list of type [T] to the storage under the specified [key].
  /// This method is specifically designed for storing lists with type safety.
  /// Overwrites any existing value for that key.
  ///
  /// [key] The key to associate with the list.
  /// [value] The list to store (must be List< T>).
  ///
  /// Example:
  /// ```dart
  /// final fruits = ['apple', 'banana', 'cherry'];
  /// await storage.writeList<String>(key: 'fruits', value: fruits);
  ///
  /// final numbers = [1, 2, 3, 4, 5];
  /// await storage.writeList<int>(key: 'numbers', value: numbers);
  ///
  /// final users = [
  ///   {'name': 'John', 'age': 30},
  ///   {'name': 'Jane', 'age': 25}
  /// ];
  /// await storage.writeList<Map<String, dynamic>>(key: 'users', value: users);
  /// ```
  Future<void> writeList<T>({
    required String key,
    required List<T> value,
  }) async {
    try {
      await _concrete.write(key: key, value: value);
    } catch (e) {
      throw Exception('Failed to write list to storage: $e');
    }
  }

  /// Writes a [value] to the storage only if the [key] does not already exist.
  /// Useful for setting default values without overwriting existing data.
  ///
  /// [key] The key to check and potentially write to.
  /// [value] The data to store if the key is empty.
  ///
  /// Example:
  /// ```dart
  /// await storage.writeIfNull(key: 'theme', value: 'light');
  /// print(storage.read<String>(key: 'theme')); // Prints: light (if not set before)
  ///
  ///
  /// ```
  Future<void> writeIfNull({
    required String key,
    required dynamic value,
  }) async {
    if (hasData(key: key)) return;
    await write(key: key, value: value);
  }

  /// Removes the value associated with the specified [key] from the storage.
  /// Does nothing if the key doesn't exist.
  ///
  /// [key] The key to remove from the storage.
  ///
  /// Example:
  /// ```dart
  /// await storage.write(key: 'temp', value: 'data');
  /// await storage.remove(key: 'temp');
  /// print(storage.read<String>(key: 'temp')); // Prints: null
  ///
  ///
  /// ```
  Future<void> remove({required String key}) async {
    try {
      await _concrete.remove(key: key);
    } catch (e) {
      throw Exception('Failed to remove from storage: $e');
    }
  }

  /// Clears all data from the storage, resetting it to an empty state.
  ///
  /// Example:
  /// ```dart
  /// await storage.write(key: 'key1', value: 'value1');
  /// await storage.clear();
  /// print(storage.getKeys().isEmpty); // Prints: true
  /// ```
  Future<void> clear() async {
    try {
      await _concrete.clear();
    } catch (e) {
      throw Exception('Failed to clear storage: $e');
    }
  }

  /// Updates the value of a specific [key] in the storage without awaiting persistence.
  /// Faster than [write] for in-memory updates; persistence depends on the implementation.
  ///
  /// [key] The key to update.
  /// [newValue] The new value to set.
  ///
  /// Example:
  /// ```dart
  /// storage.changeValueOfKey(key: 'counter', newValue: 42);
  /// print(storage.read<int>(key: 'counter')); // Prints: 42
  ///
  ///
  /// ```
  void changeValueOfKey({required String key, required dynamic newValue}) {
    _concrete.changeValueOfKey(key: key, newValue: newValue);
  }

  /// Disposes of the storage instance, closing streams and freeing resources.
  /// Call this when the storage is no longer needed to prevent memory leaks.
  ///
  /// Example:
  /// ```dart
  /// final storage = GetXStorage('Temp');
  /// await storage.init();
  /// // Use storage...
  /// storage.dispose(); // Clean up when done
  ///
  ///
  /// ```
  void dispose() {
    _concrete.subject.close();
    _sync.removeWhere((k, v) => v == this);
  }

  /// Enables benchmark mode which disables disk writes for performance testing
  void enableBenchmarkMode() {
    if (_concrete is IOStorage) {
      (_concrete as IOStorage).disableDiskWrites();
    }
  }
}
