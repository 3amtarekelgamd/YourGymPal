import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends GetxController {
  // Storage keys
  static const String kSetRestDuration = 'setRestDuration';
  static const String kWorkoutRestDuration = 'workoutRestDuration';
  static const String kEnableSoundAlerts = 'enableSoundAlerts';
  static const String kEnableVibration = 'enableVibration';
  static const String kAutoStartTimer = 'autoStartTimer';
  static const String kIsDarkMode = 'isDarkMode';
  static const String kWeightUnit = 'weightUnit';
  static const String kShowCompletedWorkouts = 'showCompletedWorkouts';
  
  // GetStorage instance
  final GetStorage _storage = GetStorage();

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
    
    // Set up reactivity to auto-save settings when they change
    ever(setRestDuration, (_) => _saveToStorage(kSetRestDuration, setRestDuration.value));
    ever(workoutRestDuration, (_) => _saveToStorage(kWorkoutRestDuration, workoutRestDuration.value));
    ever(enableSoundAlerts, (_) => _saveToStorage(kEnableSoundAlerts, enableSoundAlerts.value));
    ever(enableVibration, (_) => _saveToStorage(kEnableVibration, enableVibration.value));
    ever(autoStartTimer, (_) => _saveToStorage(kAutoStartTimer, autoStartTimer.value));
    ever(isDarkMode, (value) {
      _saveToStorage(kIsDarkMode, value);
      Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    });
    ever(weightUnit, (_) => _saveToStorage(kWeightUnit, weightUnit.value));
    ever(showCompletedWorkouts, (_) => _saveToStorage(kShowCompletedWorkouts, showCompletedWorkouts.value));
  }
  
  // Helper to save a value to storage
  void _saveToStorage(String key, dynamic value) {
    try {
      _storage.write(key, value);
    } catch (e) {
      debugPrint('Error saving $key to storage: $e');
    }
  }

  Future<void> loadSettings() async {
    try {
      // Try to load from GetStorage first
      final hasGetStorageData = _loadFromGetStorage();
      
      // If GetStorage is empty, try to migrate from SharedPreferences
      if (!hasGetStorageData) {
        await _migrateFromSharedPreferences();
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
      // Set default values in case of error
      _setDefaultValues();
    }
  }
  
  // Load settings from GetStorage
  bool _loadFromGetStorage() {
    bool dataLoaded = false;
    
    // Rest timer settings with validation
    final setRest = _storage.read<int>(kSetRestDuration);
    if (setRest != null) {
      setRestDuration.value = setRest > 0 ? setRest : 60;
      dataLoaded = true;
    }

    final workoutRest = _storage.read<int>(kWorkoutRestDuration);
    if (workoutRest != null) {
      workoutRestDuration.value = workoutRest > 0 ? workoutRest : 120;
      dataLoaded = true;
    }

    final soundAlerts = _storage.read<bool>(kEnableSoundAlerts);
    if (soundAlerts != null) {
      enableSoundAlerts.value = soundAlerts;
      dataLoaded = true;
    }
    
    final vibration = _storage.read<bool>(kEnableVibration);
    if (vibration != null) {
      enableVibration.value = vibration;
      dataLoaded = true;
    }
    
    final autoStart = _storage.read<bool>(kAutoStartTimer);
    if (autoStart != null) {
      autoStartTimer.value = autoStart;
      dataLoaded = true;
    }

    // Theme settings
    final darkMode = _storage.read<bool>(kIsDarkMode);
    if (darkMode != null) {
      isDarkMode.value = darkMode;
      dataLoaded = true;
    }

    // Units with validation
    final unit = _storage.read<String>(kWeightUnit);
    if (unit != null) {
      weightUnit.value = (unit == 'kg' || unit == 'lb') ? unit : 'kg';
      dataLoaded = true;
    }

    // UI preferences
    final showCompleted = _storage.read<bool>(kShowCompletedWorkouts);
    if (showCompleted != null) {
      showCompletedWorkouts.value = showCompleted;
      dataLoaded = true;
    }

    // Apply theme on load
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    
    return dataLoaded;
  }
  
  // Migrate settings from SharedPreferences to GetStorage
  Future<void> _migrateFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool dataMigrated = false;
      
      // Check if there's any data to migrate
      if (prefs.containsKey('setRestDuration') || 
          prefs.containsKey('workoutRestDuration') ||
          prefs.containsKey('isDarkMode')) {
        
        // Migrate rest timer settings
        final setRest = prefs.getInt('setRestDuration');
        if (setRest != null) {
          setRestDuration.value = setRest > 0 ? setRest : 60;
          _storage.write(kSetRestDuration, setRestDuration.value);
          await prefs.remove('setRestDuration');
          dataMigrated = true;
        }

        final workoutRest = prefs.getInt('workoutRestDuration');
        if (workoutRest != null) {
          workoutRestDuration.value = workoutRest > 0 ? workoutRest : 120;
          _storage.write(kWorkoutRestDuration, workoutRestDuration.value);
          await prefs.remove('workoutRestDuration');
          dataMigrated = true;
        }

        enableSoundAlerts.value = prefs.getBool('enableSoundAlerts') ?? true;
        _storage.write(kEnableSoundAlerts, enableSoundAlerts.value);
        await prefs.remove('enableSoundAlerts');
        
        enableVibration.value = prefs.getBool('enableVibration') ?? true;
        _storage.write(kEnableVibration, enableVibration.value);
        await prefs.remove('enableVibration');
        
        autoStartTimer.value = prefs.getBool('autoStartTimer') ?? true;
        _storage.write(kAutoStartTimer, autoStartTimer.value);
        await prefs.remove('autoStartTimer');

        // Theme settings
        isDarkMode.value = prefs.getBool('isDarkMode') ?? false;
        _storage.write(kIsDarkMode, isDarkMode.value);
        await prefs.remove('isDarkMode');

        // Units
        final unit = prefs.getString('weightUnit');
        weightUnit.value = unit != null && (unit == 'kg' || unit == 'lb') ? unit : 'kg';
        _storage.write(kWeightUnit, weightUnit.value);
        await prefs.remove('weightUnit');

        // UI preferences
        showCompletedWorkouts.value = prefs.getBool('showCompletedWorkouts') ?? true;
        _storage.write(kShowCompletedWorkouts, showCompletedWorkouts.value);
        await prefs.remove('showCompletedWorkouts');
        
        debugPrint('Migrated settings from SharedPreferences to GetStorage');
      }
      
      // If no data was migrated, set default values
      if (!dataMigrated) {
        _setDefaultValues();
      }
    } catch (e) {
      debugPrint('Error migrating settings from SharedPreferences: $e');
      _setDefaultValues();
    }
  }

  void _setDefaultValues() {
    setRestDuration.value = 60;
    workoutRestDuration.value = 120;
    enableSoundAlerts.value = true;
    enableVibration.value = true;
    autoStartTimer.value = true;
    isDarkMode.value = false;
    weightUnit.value = 'kg';
    showCompletedWorkouts.value = true;
    
    // Save default values to storage
    _saveToStorage(kSetRestDuration, setRestDuration.value);
    _saveToStorage(kWorkoutRestDuration, workoutRestDuration.value);
    _saveToStorage(kEnableSoundAlerts, enableSoundAlerts.value);
    _saveToStorage(kEnableVibration, enableVibration.value);
    _saveToStorage(kAutoStartTimer, autoStartTimer.value);
    _saveToStorage(kIsDarkMode, isDarkMode.value);
    _saveToStorage(kWeightUnit, weightUnit.value);
    _saveToStorage(kShowCompletedWorkouts, showCompletedWorkouts.value);
  }

  // Update methods now only need to update the Rx values, and the observers
  // will take care of saving to storage automatically
  
  void updateSetRestDuration(int seconds) {
    // Ensure value is an integer
    seconds = seconds.round();
    if (seconds < 1) seconds = 1;
    setRestDuration.value = seconds;
  }

  void updateWorkoutRestDuration(int seconds) {
    // Ensure value is an integer
    seconds = seconds.round();
    if (seconds < 1) seconds = 1;
    workoutRestDuration.value = seconds;
  }

  void toggleSoundAlerts() {
    enableSoundAlerts.value = !enableSoundAlerts.value;
  }

  void toggleVibration() {
    enableVibration.value = !enableVibration.value;
  }

  void toggleAutoStartTimer() {
    autoStartTimer.value = !autoStartTimer.value;
  }

  void toggleDarkMode() {
    isDarkMode.value = !isDarkMode.value;
    // No need to call Get.changeThemeMode here as the observer handles it
  }

  void setWeightUnit(String unit) {
    weightUnit.value = unit;
  }

  // Weight unit conversion methods with validation
  double kgToLb(double kg) {
    if (kg < 0) return 0;
    return kg * 2.20462;
  }

  double lbToKg(double lb) {
    if (lb < 0) return 0;
    return lb / 2.20462;
  }

  String getFormattedWeight(double weight) {
    if (weight < 0) weight = 0;
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
  
  // Add the missing saveSettings method
  void saveSettings() {
    // This method is for explicit saves, although our observers already auto-save individual settings
    _saveToStorage(kSetRestDuration, setRestDuration.value);
    _saveToStorage(kWorkoutRestDuration, workoutRestDuration.value);
    _saveToStorage(kEnableSoundAlerts, enableSoundAlerts.value);
    _saveToStorage(kEnableVibration, enableVibration.value);
    _saveToStorage(kAutoStartTimer, autoStartTimer.value);
    _saveToStorage(kIsDarkMode, isDarkMode.value);
    _saveToStorage(kWeightUnit, weightUnit.value);
    _saveToStorage(kShowCompletedWorkouts, showCompletedWorkouts.value);
    
    debugPrint('All settings saved manually');
  }
}
