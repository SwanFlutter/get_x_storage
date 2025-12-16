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
    bool initialTheme = _storage.read(key: _key) ?? false;
    isDarkMode = initialTheme.obs;

    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;

    // تغییر تم در کل اپلیکیشن
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);

    // ذخیره وضعیت جدید
    _storage.write(key: _key, value: isDarkMode.value);
  }
}
