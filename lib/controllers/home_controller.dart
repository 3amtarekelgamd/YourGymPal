import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../controllers/settings_controller.dart';

/// Controller for the home screen
class HomeController extends GetxController {
  // Observable for the current tab index
  final RxInt tabIndex = 0.obs;
  
  // Maximum tab index (number of tabs - 1)
  final int maxTabIndex = 3; // Dashboard, Workouts, Progress, Profile

  // Settings controller reference
  final SettingsController settingsController = Get.find<SettingsController>();

  // Worker for theme changes
  Worker? _themeWorker;

  @override
  void onInit() {
    super.onInit();

    // Dispose any existing worker before creating a new one
    _themeWorker?.dispose();
    
    // Set up listener for theme changes
    _themeWorker = ever(
        settingsController.isDarkMode,
        (isDark) =>
            Get.changeThemeMode(isDark ? ThemeMode.dark : ThemeMode.light));
  }

  @override
  void onClose() {
    // Dispose of worker when controller is closed
    _themeWorker?.dispose();
    _themeWorker = null;
    super.onClose();
  }

  /// Change the current tab with safety check
  void changeTab(int index) {
    // Validate index to prevent out of bounds errors
    if (index >= 0 && index <= maxTabIndex) {
      tabIndex.value = index;
    } else {
      debugPrint('Invalid tab index: $index, must be between 0 and $maxTabIndex');
      // Set to a valid value
      tabIndex.value = 0;
    }
  }
}
