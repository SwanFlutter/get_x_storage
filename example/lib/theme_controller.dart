import 'package:flutter/material.dart';
import 'package:get_x_master/get_x_master.dart';
import 'package:get_x_storage/get_x_storage.dart';

class ThemeController extends GetXController {
  final _storage = GetXStorage();
  final _key = 'isDarkMode';

  // Initialize with default value to avoid late initialization issues
  final isDarkMode = false.obs;

  ThemeMode get themeMode =>
      isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  void _loadTheme() {
    // Always read from storage on init/hot reload
    final storedValue = _storage.read<bool>(key: _key);

    if (storedValue != null) {
      isDarkMode.value = storedValue;
    }

    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    _storage.write(key: _key, value: isDarkMode.value);
  }
}
