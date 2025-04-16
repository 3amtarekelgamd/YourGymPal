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
    // Register controllers with proper types and make them permanent
    Get.put<SettingsController>(SettingsController(), permanent: true);
    Get.put<WorkoutController>(WorkoutController(), permanent: true);
    Get.put<TemplatesController>(TemplatesController(), permanent: true);

    // Register screen-specific controllers
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<WorkoutsController>(() => WorkoutsController(), fenix: true);
  }
}
