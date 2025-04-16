import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:device_preview/device_preview.dart';
import 'screens/dashboard_screen.dart';
import 'screens/workouts_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/active_workout_screen.dart';
import 'screens/create_custom_workout_screen.dart';
import 'screens/edit_template_screen.dart';
import 'controllers/home_controller.dart';
import 'services/image_service.dart';
import 'services/sound_service.dart';
import 'bindings/initial_bindings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initServices();

  runApp(
    DevicePreview(
      enabled: true, // Keep device preview on at all times
      builder: (context) => const GymApp(),
    ),
  );
}

/// Initialize all services before the app starts
Future<void> initServices() async {
  // Initialize and inject services first (services don't depend on controllers)
  final imageService = ImageService();
  await imageService.init();
  Get.put<ImageService>(imageService, permanent: true);

  final soundService = SoundService();
  await soundService.init();
  Get.put<SoundService>(soundService, permanent: true);

  // Print confirmation when all services are ready
  debugPrint('All services initialized');
}

class GymApp extends StatelessWidget {
  const GymApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Your Gym Pal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system, // Initial theme mode
      initialBinding: InitialBindings(),
      getPages: [
        GetPage(
          name: '/',
          page: () => const HomeScreen(),
        ),
        GetPage(
          name: '/dashboard',
          page: () => const HomeScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/active-workout',
          page: () => const ActiveWorkoutScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/create-custom-workout',
          page: () => const CreateCustomWorkoutScreen(),
          transition: Transition.rightToLeft,
        ),
        GetPage(
          name: '/edit-template',
          page: () => const EditTemplateScreen(),
          transition: Transition.rightToLeft,
        ),
      ],
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize and inject the home controller
    final HomeController controller = Get.put(HomeController());

    final List<Widget> screens = [
      const DashboardScreen(),
      const WorkoutsScreen(),
      const ProgressScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: Obx(() => screens[controller.tabIndex.value]),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: controller.tabIndex.value,
          onTap: (index) => controller.changeTab(index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center),
              label: 'Workouts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart),
              label: 'Progress',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
