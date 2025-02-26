library;

import 'dart:async';

import 'package:get_x_storage/src/storage/storage_base.dart';
import 'package:get_x_storage/src/storage/storage_factory.dart';

/// A class for managing storage using GetX pattern.
/// This class provides a simple and efficient way to store, retrieve, and manage data
/// in a key-value format. It supports asynchronous initialization, listening to changes,
/// and various CRUD operations.

class GetXStorage {
  /// Factory constructor to create or retrieve an instance of GetXStorage.
  /// If an instance with the same container name already exists, it returns that instance.
  /// Otherwise, it creates a new instance and stores it in the `_sync` map.
  ///
  /// [container]: The name of the storage container. Defaults to 'GetStorage'.
  /// [path]: Optional path for the storage.
  /// [initialData]: Optional initial data to initialize the storage with.
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

  /// Internal constructor to initialize the storage instance.
  /// This constructor is private and should only be called from the factory constructor.
  GetXStorage._internal(
    String key, [
    String? path,
    Map<String, dynamic>? initialData,
  ]) {
    _concrete = StorageFactory.create(key, path);
    initStorage = Future<bool>(() async {
      await _concrete.init(initialData);
      return true;
    });
  }

  /// A map to store instances of GetXStorage with their container names as keys.
  static final Map<String, GetXStorage> _sync = {};

  /// The concrete storage implementation.
  late StorageBase _concrete;

  /// A future that completes when the storage is initialized.
  late Future<bool> initStorage;

  /// A stream that emits the current state of the storage as a map.
  Stream<Map<String, dynamic>> get stream => _concrete.subject.stream;

  /// Initializes the storage for a given container.
  /// Returns a future that completes when the storage is ready.
  static Future<bool> init([String container = 'GetStorage']) {
    return GetXStorage(container).initStorage;
  }

  /// Reads a value from the storage by its key.
  /// Returns `null` if the key does not exist.
  T? read<T>({required String key}) => _concrete.read<T>(key: key);

  /// Returns an iterable of all keys in the storage.
  Iterable<String> getKeys() => _concrete.getKeys();

  /// Returns an iterable of all values in the storage.
  Iterable<dynamic> getValues() => _concrete.getValues();

  /// Checks if the storage contains data for a given key.
  bool hasData({required String key}) => read(key: key) != null;

  /// Listens to changes in the storage and invokes the callback whenever a change occurs.
  StreamSubscription? listen(void Function() callback) {
    return _concrete.subject.stream.listen((_) => callback());
  }

  /// Listens to changes for a specific key and invokes the callback with the new value.
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

  /// Writes a value to the storage for a given key.
  Future<void> write({required String key, required dynamic value}) async {
    await _concrete.write(key: key, value: value);
  }

  /// Writes a value to the storage only if the key does not already exist.
  Future<void> writeIfNull({
    required String key,
    required dynamic value,
  }) async {
    if (hasData(key: key)) return;
    await write(key: key, value: value);
  }

  /// Removes a value from the storage by its key.
  Future<void> remove({required String key}) async {
    await _concrete.remove(key: key);
  }

  /// Clears all data from the storage.
  Future<void> erase() async {
    await _concrete.clear();
  }

  /// Updates the value of a specific key in the storage.
  void changeValueOfKey({required String key, required dynamic newValue}) {
    _concrete.changeValueOfKey(key: key, newValue: newValue);
  }
}
