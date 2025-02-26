import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get_x_master/get_x_master.dart';

class ThemeController extends GetXController {
  final _storage = GetStorage('ThemeStorage');
  final RxBool isDarkTheme = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    await _storage.initStorage;
    isDarkTheme.value = _storage.read<bool>('isDarkTheme') ?? true;
    _applyTheme();
  }

  void toggleTheme() {
    isDarkTheme.value = !isDarkTheme.value;
    _applyTheme();
    _saveTheme();
  }

  void _applyTheme() {
    Get.changeThemeMode(isDarkTheme.value ? ThemeMode.light : ThemeMode.dark);
  }

  Future<void> _saveTheme() async {
    await _storage.write('isDarkTheme', isDarkTheme.value);
  }
}
