import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../controllers/settings_controller.dart';

/// Controller for the home screen
class HomeController extends GetxController {
  // Observable for the current tab index
  final RxInt tabIndex = 0.obs;

  // Settings controller reference
  final SettingsController settingsController = Get.find<SettingsController>();

  // Worker for theme changes
  late Worker _themeWorker;

  @override
  void onInit() {
    super.onInit();

    // Set up listener for theme changes
    _themeWorker = ever(
        settingsController.isDarkMode,
        (isDark) =>
            Get.changeThemeMode(isDark ? ThemeMode.dark : ThemeMode.light));
  }

  @override
  void onClose() {
    // Dispose of worker when controller is closed
    _themeWorker.dispose();
    super.onClose();
  }

  /// Change the current tab
  void changeTab(int index) {
    tabIndex.value = index;
  }
}
