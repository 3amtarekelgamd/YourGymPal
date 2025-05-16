import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../controllers/workout_controller.dart';
import '../controllers/templates_controller.dart';
import '../controllers/workouts_controller.dart';
import '../controllers/home_controller.dart';

/// Initial bindings for the application
class InitialBindings extends Bindings {
  @override
  void dependencies() {
    try {
      // Core controllers that should be initialized first
      Get.put<SettingsController>(SettingsController(), permanent: true);

      // Controllers that depend on settings
      Get.put<WorkoutController>(WorkoutController(), permanent: true);
      Get.put<TemplatesController>(TemplatesController(), permanent: true);

      // Register WorkoutsController without a tag so it can be used with GetView
      Get.put<WorkoutsController>(WorkoutsController(), permanent: true);
      
      // Screen-specific controllers with fenix flag for automatic recreation
      Get.lazyPut<HomeController>(
        () => HomeController(),
        fenix: true,
        tag: 'home',
      );

    } catch (e) {
      debugPrint('Error initializing dependencies: $e');
      // Show error to user
      Get.snackbar(
        'Initialization Error',
        'Failed to initialize app dependencies. Please restart the app.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }
}
