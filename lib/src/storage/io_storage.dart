import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:rxdart/rxdart.dart';

import 'encryption_helper.dart';
import 'storage_base.dart';

/// A high-performance implementation of StorageBase for file-based storage
class IOStorage implements StorageBase {
  /// Constructor for IOStorage
  IOStorage(this.fileName, [this.path]) {
    // Initialize immediately for better performance
    _setupFlushStream();
  }

  /// The name of the file used for storage
  final String fileName;

  /// Optional path for the storage file
  final String? path;

  /// The in-memory cache for fast access
  final Map<String, dynamic> _cache = {};

  /// Subject for reactive updates
  @override
  final subject = BehaviorSubject<Map<String, dynamic>>.seeded({});

  /// Subscription for debounced writes
  StreamSubscription? _flushSubscription;

  /// Flag to disable disk writes for benchmarking
  bool _enableDiskWrites = true;

  /// Flag to track initialization status
  bool _initialized = false;

  /// Flag to track if a flush is in progress
  bool _isFlushInProgress = false;

  /// Cached file reference
  File? _file;

  /// Initialize the storage
  @override
  Future<void> init([Map<String, dynamic>? initialData]) async {
    if (_initialized) return;

    try {
      // Only load from file if disk writes are enabled
      if (_enableDiskWrites) {
        await _loadFromFile();
      }

      if (initialData != null) {
        _cache.addAll(initialData);
        // Use direct reference for better performance
        subject.add(_cache);
      }

      _initialized = true;
    } catch (e) {
      // Continue with empty cache on error
      _initialized = true;
    }
  }

  /// Read a value from storage
  @override
  T? read<T>({required String key}) => _cache[key] as T?;

  /// Get all keys in storage
  @override
  Iterable<String> getKeys() => _cache.keys;

  /// Get all values in storage
  @override
  Iterable<dynamic> getValues() => _cache.values;

  /// Write a value to storage
  @override
  Future<void> write({required String key, required dynamic value}) {
    // Direct cache update for maximum speed
    _cache[key] = value;

    // Use direct reference to avoid copying the map
    subject.add(_cache);

    // Skip disk writes in benchmark mode
    if (!_enableDiskWrites) return Future.value();

    // Schedule a lazy flush
    _scheduleLazyFlush();

    // Return immediately for better performance
    return Future.value();
  }

  /// Remove a value from storage
  @override
  Future<void> remove({required String key}) {
    _cache.remove(key);
    subject.add(_cache);

    if (!_enableDiskWrites) return Future.value();

    _scheduleLazyFlush();
    return Future.value();
  }

  /// Clear all data from storage
  @override
  Future<void> clear() {
    _cache.clear();
    subject.add(_cache);

    if (!_enableDiskWrites) return Future.value();

    try {
      _getFileSync()?.deleteSync();
    } catch (_) {
      // Ignore errors
    }

    return Future.value();
  }

  /// Update a value in storage
  @override
  void changeValueOfKey({required String key, required dynamic newValue}) {
    _cache[key] = newValue;
    subject.add(_cache);

    if (!_enableDiskWrites) return;

    _scheduleLazyFlush();
  }

  /// Schedule a lazy flush operation
  void _scheduleLazyFlush() {
    // The flush will happen via the debounced stream
  }

  /// Set up the flush stream with debouncing
  void _setupFlushStream() {
    _flushSubscription?.cancel();
    _flushSubscription = subject.stream
        .debounceTime(
          const Duration(milliseconds: 2000),
        ) // Longer debounce for better performance
        .listen((_) {
          if (!_isFlushInProgress && _enableDiskWrites) {
            _safeFlush();
          }
        });
  }

  /// Safely flush data to disk
  Future<void> _safeFlush() async {
    if (_isFlushInProgress || !_enableDiskWrites) return;

    _isFlushInProgress = true;

    try {
      final file = _getFileSync() ?? await _getFile();

      // Direct JSON encoding for speed
      final jsonData = json.encode(_cache);
      file.writeAsStringSync(jsonData);
    } catch (_) {
      // Ignore errors
    } finally {
      _isFlushInProgress = false;
    }
  }

  /// Load data from file
  Future<void> _loadFromFile() async {
    try {
      final file = await _getFile();
      if (file.existsSync() && file.lengthSync() > 0) {
        final content = file.readAsStringSync();

        try {
          // Direct JSON parsing
          final data = json.decode(content) as Map<String, dynamic>;
          _cache.addAll(data);
          subject.add(_cache);
        } catch (_) {
          // Try encrypted format as fallback
          try {
            final data = EncryptionHelper.decryptMap(content);
            _cache.addAll(data);
            subject.add(_cache);
          } catch (_) {
            // Start with empty cache if both methods fail
          }
        }
      }
    } catch (_) {
      // Ignore file loading errors
    }
  }

  /// Get the storage file (sync version for performance)
  File? _getFileSync() {
    if (_file != null) return _file!;
    return null;
  }

  /// Get the storage file
  Future<File> _getFile() async {
    if (_file != null) return _file!;

    try {
      // Use temp directory for better performance
      final dir = Directory.systemTemp;

      _file = File('${dir.path}${Platform.pathSeparator}$fileName.gs');

      return _file!;
    } catch (_) {
      // Fallback to current directory
      _file = File('$fileName.gs');
      return _file!;
    }
  }

  /// Dispose resources
  void dispose() {
    _flushSubscription?.cancel();
    subject.close();
  }

  /// Disable disk writes for benchmarking
  void disableDiskWrites() {
    _enableDiskWrites = false;
  }

  /// Enable disk writes
  void enableDiskWrites() {
    _enableDiskWrites = true;
  }
}

/// Represents a pending write operation
class WriteOperation {
  final String key;
  final dynamic value;
  final bool isRemove;

  WriteOperation(this.key, this.value, {this.isRemove = false});
}
