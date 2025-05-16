import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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

// Add a route observer for debugging
class NavigationObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugPrint('NAVIGATION: Pushed route: ${route.settings.name}');
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugPrint('NAVIGATION: Popped route: ${route.settings.name}');
    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugPrint('NAVIGATION: Removed route: ${route.settings.name}');
    super.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    debugPrint('NAVIGATION: Replaced route: ${oldRoute?.settings.name} -> ${newRoute?.settings.name}');
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize GetStorage before the app starts
    await GetStorage.init();
    
    await initServices();

    runApp(const GymApp());
  } catch (e) {
    debugPrint('Error initializing app: $e');
    // Show a user-friendly error screen
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Failed to initialize app. Please restart.',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
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
      debugShowCheckedModeBanner: false,
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
      navigatorObservers: [NavigationObserver()], // Add our navigation observer
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
    // Get the home controller using the tag specified in InitialBindings
    final HomeController controller = Get.find<HomeController>(tag: 'home');

    final List<Widget> screens = [
      const DashboardScreen(),
      const WorkoutsScreen(),
      const ProgressScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: Obx(() {
        // Add safety check for tabIndex to prevent index out of range errors
        final index = controller.tabIndex.value.clamp(0, screens.length - 1);
        return screens[index];
      }),
      bottomNavigationBar: Obx(
        () {
          // Add safety check for tabIndex to prevent index out of range errors
          final index = controller.tabIndex.value.clamp(0, screens.length - 1);
          return BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: index,
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
          );
        },
      ),
    );
  }
}
