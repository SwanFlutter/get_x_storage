// ignore_for_file: unused_local_variable

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_x_master/get_x_master.dart';
import 'package:get_x_storage/get_x_storage.dart';

import 'theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize storage and wait for it to complete
  await GetXStorage.init();

  // 2. Create ThemeController and wait for it to load theme
  final ThemeController themeController = Get.put(ThemeController());

  // 3. Wait a frame to ensure theme is loaded before building UI
  await Future.delayed(Duration.zero);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        title: 'Flutter Demo',
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
