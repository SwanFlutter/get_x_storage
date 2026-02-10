import 'package:flutter/material.dart';
import 'package:get_x_master/get_x_master.dart';
import 'package:get_x_storage/get_x_storage.dart';

class ThemeController extends GetXController {
  final _storage = GetXStorage();
  final _key = 'isDarkMode';

  late RxBool isDarkMode;

  ThemeMode get themeMode =>
      isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  @override
  void onInit() {
    super.onInit();
    _initTheme();
  }

  void _initTheme() {
    // Read the stored theme value SYNCHRONOUSLY to avoid flicker
    // This is critical for web where localStorage is synchronous
    final storedValue = _storage.read<bool>(key: _key);

    // Use stored value if available, otherwise default to false (light mode)
    final initialTheme = storedValue ?? false;

    // Initialize the reactive variable
    isDarkMode = initialTheme.obs;

    // Apply the theme immediately
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;

    // Change theme in the entire application
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);

    // Save the new state
    _storage.write(key: _key, value: isDarkMode.value);
  }
}
