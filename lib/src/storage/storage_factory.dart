import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:rxdart/rxdart.dart';

import 'package:get_x_storage/src/storage/storage_base.dart';
import 'package:get_x_storage/src/storage/web_storage.dart';

import 'io_storage.dart';

/// A factory class responsible for creating storage instances based on the platform.
class StorageFactory {
  /// Creates an instance of [StorageBase] tailored to the current platform.
  /// This method uses platform detection to decide which storage implementation to use:
  /// - WebStorage for web platforms.
  /// - IOStorage for mobile and desktop platforms (Android, iOS, Windows, Linux, macOS).
  ///
  /// [key] The identifier for the storage instance (e.g., file name or container name).
  /// [path] An optional path for storage location (e.g., directory for file-based storage).
  /// Returns an instance of [StorageBase] appropriate for the platform.
  static StorageBase create(String key, String? path) {
    try {
      if (kIsWeb) {
        return _createWebStorage(key, path);
      }

      // We know it's not web, so we can safely use dart:io
      return IOStorage(key, path);
    } catch (e) {
      // Fallback to memory storage if platform-specific storage fails
      return _MemoryStorage(key);
    }
  }

  /// Creates a web storage instance with proper error handling
  static StorageBase _createWebStorage(String key, String? path) {
    if (!kIsWeb) {
      throw UnsupportedError('Web storage is only available on web platforms');
    }

    try {
      return WebStorage(key, path);
    } catch (e) {
      // Fallback to memory storage if web storage fails
      return _MemoryStorage(key);
    }
  }
}

/// A simple in-memory implementation of StorageBase for fallback purposes
class _MemoryStorage implements StorageBase {
  _MemoryStorage(this.fileName);

  final String fileName;
  final _data = <String, dynamic>{};

  @override
  final subject = BehaviorSubject<Map<String, dynamic>>.seeded({});

  @override
  Future<void> clear() async {
    _data.clear();
    subject.add({});
  }

  @override
  Future<void> init([Map<String, dynamic>? initialData]) async {
    if (initialData != null) {
      _data.addAll(initialData);
      subject.add(Map<String, dynamic>.from(_data));
    }
  }

  @override
  T? read<T>({required String key}) => _data[key] as T?;

  @override
  Future<void> remove({required String key}) async {
    _data.remove(key);
    subject.add(Map<String, dynamic>.from(_data));
  }

  @override
  Future<void> write({required String key, required value}) async {
    _data[key] = value;
    subject.add(Map<String, dynamic>.from(_data));
  }

  @override
  Iterable<String> getKeys() => _data.keys;

  @override
  Iterable getValues() => _data.values;

  @override
  void changeValueOfKey({required String key, required newValue}) {
    _data[key] = newValue;
    subject.add(Map<String, dynamic>.from(_data));
  }
}
