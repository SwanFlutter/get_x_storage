// ignore_for_file: unused_local_variable

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_x_master/get_x_master.dart';
import 'package:get_x_storage/get_x_storage.dart';

import 'theme_controller.dart'; // فایل کنترلر خود را ایمپورت کنید
// import 'app_bindings.dart'; // اگر بایندینگ دیگری دارید

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. ابتدا استوریج را راه اندازی کنید
  await GetXStorage.init();

  final ThemeController themeController = Get.put(ThemeController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // کنترلر قبلاً در main ساخته شده، اینجا فقط آن را پیدا می‌کنیم (اختیاری برای دسترسی)
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        title: 'Flutter Demo',
        // initialBinding: AppBindings(), // اگر بایندینگ‌های دیگر دارید
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
        themeMode: themeController.themeMode,

        home: const Screen(),
      ),
    );
  }
}

class Screen extends StatelessWidget {
  const Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find();

    return Scaffold(
      appBar: AppBar(title: const Text('Theme Switcher')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(
              () => Text(
                themeController.isDarkMode.value ? 'Dark Mode' : 'Light Mode',
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 20),
            Obx(
              () => CupertinoSwitch(
                value: themeController.isDarkMode.value,
                onChanged: (value) {
                  themeController.toggleTheme();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
