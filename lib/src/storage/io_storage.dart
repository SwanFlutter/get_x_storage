import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

import 'storage_base.dart';

/// A class that implements the `StorageBase` interface for file-based storage.
/// This class uses the device's file system to store and manage data in a key-value format.
/// It supports asynchronous initialization, CRUD operations, and listening to changes.
/// Data is cached in memory for quick access and flushed to disk periodically.

class IOStorage implements StorageBase {
  /// Constructor for IOStorage.
  /// [fileName]: The name of the file to store data in the file system.
  /// [path]: Optional path for the file. If not provided, the application's documents directory is used.
  IOStorage(this.fileName, [this.path]);

  /// The name of the file used to store data in the file system.
  final String fileName;

  /// Optional path for the file. If not provided, the application's documents directory is used.
  final String? path;

  /// A `BehaviorSubject` that holds the current state of the storage as a map.
  /// It is seeded with an empty map by default.
  @override
  final BehaviorSubject<Map<String, dynamic>> subject = BehaviorSubject.seeded(
    {},
  );

  /// A subscription to the `subject` stream for debounced flushing of data to disk.
  StreamSubscription? _flushSubscription;

  /// An in-memory cache to store data for quick access.
  final Map<String, dynamic> _cache = {};

  /// Initializes the storage with optional initial data.
  /// Loads data from the file system if it exists, otherwise initializes with the provided data.
  @override
  Future<void> init([Map<String, dynamic>? initialData]) async {
    await _loadFromFile();
    if (initialData != null) {
      _cache.addAll(initialData);
      subject.add(Map<String, dynamic>.from(_cache));
    }
    _setupFlushStream();
  }

  /// Reads a value from the storage by its key.
  /// Returns `null` if the key does not exist.
  @override
  T? read<T>({required String key}) => _cache[key] as T?;

  /// Returns an iterable of all keys in the storage.
  @override
  Iterable<String> getKeys() => _cache.keys;

  /// Returns an iterable of all values in the storage.
  @override
  Iterable<dynamic> getValues() => _cache.values;

  /// Writes a value to the storage for a given key.
  /// Updates the in-memory cache and the `subject`, but does not immediately flush to disk.
  @override
  Future<void> write({required String key, required dynamic value}) async {
    _cache[key] = value;
    subject.add(Map<String, dynamic>.from(_cache));
    // No immediate flush here; handled by debounce
  }

  /// Removes a value from the storage by its key.
  /// Updates the in-memory cache and the `subject`, but does not immediately flush to disk.
  @override
  Future<void> remove({required String key}) async {
    _cache.remove(key);
    subject.add(Map<String, dynamic>.from(_cache));
    // No immediate flush here; handled by debounce
  }

  /// Clears all data from the storage.
  /// Resets the in-memory cache and the `subject`, and immediately flushes to disk.
  @override
  Future<void> clear() async {
    _cache.clear();
    subject.add({});
    await _flush(); // Immediate flush only for clear
  }

  /// Sets up a debounced stream to flush data to disk periodically.
  void _setupFlushStream() {
    _flushSubscription?.cancel();
    _flushSubscription = subject.stream
        .debounceTime(
          const Duration(milliseconds: 500),
        ) // Increased debounce for better performance
        .listen((data) async => await _flush());
  }

  /// Flushes the in-memory cache to the file system.
  Future<void> _flush() async {
    final file = await _getFile();
    await file.writeAsString(json.encode(_cache), flush: true);
  }

  /// Loads data from the file system into the in-memory cache.
  Future<void> _loadFromFile() async {
    try {
      final file = await _getFile();
      if (await file.exists() && await file.length() > 0) {
        final content = await file.readAsString();
        _cache.addAll(json.decode(content) as Map<String, dynamic>);
        subject.add(Map<String, dynamic>.from(_cache));
      }
    } catch (e) {
      _cache.clear();
      subject.add({});
    }
  }

  /// Gets the file object for the storage file.
  /// Creates the file if it does not exist.
  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath = path ?? dir.path;
    final file = File('$filePath/$fileName.gs');
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    return file;
  }

  /// Updates the value of a specific key in the storage.
  /// Updates the in-memory cache and the `subject`, but does not immediately flush to disk.
  @override
  void changeValueOfKey({required String key, required dynamic newValue}) {
    _cache[key] = newValue;
    subject.add(Map<String, dynamic>.from(_cache));
  }
}
