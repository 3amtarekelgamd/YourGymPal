import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends GetxController {
  // Rest timer settings
  final RxInt setRestDuration = 60.obs; // Default 60 seconds between sets
  final RxInt workoutRestDuration =
      120.obs; // Default 120 seconds between exercises
  final RxBool enableSoundAlerts = true.obs;
  final RxBool enableVibration = true.obs;
  final RxBool autoStartTimer = true.obs;

  // Theme settings
  final RxBool isDarkMode = false.obs;

  // Units
  final RxString weightUnit = 'kg'.obs; // kg or lb

  // UI preferences
  final RxBool showCompletedWorkouts = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Rest timer settings
      setRestDuration.value = prefs.getInt('setRestDuration') ?? 60;
      workoutRestDuration.value = prefs.getInt('workoutRestDuration') ?? 120;
      enableSoundAlerts.value = prefs.getBool('enableSoundAlerts') ?? true;
      enableVibration.value = prefs.getBool('enableVibration') ?? true;
      autoStartTimer.value = prefs.getBool('autoStartTimer') ?? true;

      // Theme settings
      isDarkMode.value = prefs.getBool('isDarkMode') ?? false;

      // Units
      weightUnit.value = prefs.getString('weightUnit') ?? 'kg';

      // UI preferences
      showCompletedWorkouts.value =
          prefs.getBool('showCompletedWorkouts') ?? true;

      // Apply theme on load
      Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Rest timer settings
      await prefs.setInt('setRestDuration', setRestDuration.value);
      await prefs.setInt('workoutRestDuration', workoutRestDuration.value);
      await prefs.setBool('enableSoundAlerts', enableSoundAlerts.value);
      await prefs.setBool('enableVibration', enableVibration.value);
      await prefs.setBool('autoStartTimer', autoStartTimer.value);

      // Theme settings
      await prefs.setBool('isDarkMode', isDarkMode.value);

      // Units
      await prefs.setString('weightUnit', weightUnit.value);

      // UI preferences
      await prefs.setBool('showCompletedWorkouts', showCompletedWorkouts.value);
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  void updateSetRestDuration(int seconds) {
    // Ensure value is an integer
    seconds = seconds.round();
    if (seconds < 1) seconds = 1;

    setRestDuration.value = seconds;
    saveSettings();
  }

  void updateWorkoutRestDuration(int seconds) {
    // Ensure value is an integer
    seconds = seconds.round();
    if (seconds < 1) seconds = 1;

    workoutRestDuration.value = seconds;
    saveSettings();
  }

  void toggleSoundAlerts() {
    enableSoundAlerts.value = !enableSoundAlerts.value;
    saveSettings();
  }

  void toggleVibration() {
    enableVibration.value = !enableVibration.value;
    saveSettings();
  }

  void toggleAutoStartTimer() {
    autoStartTimer.value = !autoStartTimer.value;
    saveSettings();
  }

  void toggleDarkMode() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    saveSettings();
  }

  void setWeightUnit(String unit) {
    weightUnit.value = unit;
    saveSettings();
  }

  // Weight unit conversion methods
  double kgToLb(double kg) {
    return kg * 2.20462;
  }

  double lbToKg(double lb) {
    return lb / 2.20462;
  }

  // Get weight with correct unit
  String getFormattedWeight(double weight) {
    if (weightUnit.value == 'kg') {
      return '${weight.toStringAsFixed(1)} kg';
    } else {
      return '${kgToLb(weight).toStringAsFixed(1)} lb';
    }
  }

  // Get weight increment value based on current unit
  double getWeightIncrement() {
    return weightUnit.value == 'kg' ? 2.5 : 5.0;
  }

  // Convert display weight to stored weight (always in kg)
  double displayWeightToStored(double displayWeight) {
    if (weightUnit.value == 'kg') {
      return displayWeight;
    } else {
      return lbToKg(displayWeight);
    }
  }

  // Convert stored weight (in kg) to display weight
  double storedWeightToDisplay(double storedWeight) {
    if (weightUnit.value == 'kg') {
      return storedWeight;
    } else {
      return kgToLb(storedWeight);
    }
  }
}
