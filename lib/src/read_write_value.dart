// import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';

import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';

import 'package:get_x_storage/src/storage/storage_factory.dart';

import '../get_x_storage.dart';

/// A generic class to read and write values to storage with a default value.
class ReadWriteValue<T> {
  final String key;
  final T defaultValue;
  final StorageFactory? getBox;

  ReadWriteValue(this.key, this.defaultValue, [this.getBox]);

  GetXStorage _getRealBox() => getBox?.call() ?? GetXStorage();

  T get val => _getRealBox().read<T>(key: key) ?? defaultValue;

  set val(T newVal) => _getRealBox().write(key: key, value: newVal);
}

extension Data<T> on T {
  ReadWriteValue<T> val(String valueKey, {StorageFactory? getBox, T? defVal}) {
    return ReadWriteValue(valueKey, defVal ?? this, getBox);
  }
}
