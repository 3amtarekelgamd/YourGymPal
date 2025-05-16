import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/workout_controller.dart';
import '../controllers/settings_controller.dart';
import '../models/exercise.dart';
import '../widgets/workout/rest_timer.dart';
import '../widgets/workout/weight_input_field.dart';
import '../widgets/status/status_widgets.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  late WorkoutController controller;
  bool isInitialized = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    try {
      controller = Get.find<WorkoutController>();
      Get.find<SettingsController>();
      
      // Verify workout is active on init
      if (!controller.isWorkoutActive.value) {
        debugPrint('ActiveWorkoutScreen: Warning - Opened screen but workout is not active');
        
        // If we have exercises but workout isn't marked active, try to activate it
        if (controller.activeExercises.isNotEmpty) {
          controller.isWorkoutActive.value = true;
          debugPrint('ActiveWorkoutScreen: Auto-activated workout with ${controller.activeExercises.length} exercises');
        }
      }
      
      setState(() {
        isInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing ActiveWorkoutScreen: $e');
      setState(() {
        errorMessage = 'Failed to initialize: $e';
        isInitialized = false;
      });
      
      // Try to go back to dashboard after error
      Future.delayed(const Duration(seconds: 2), () {
        Get.offAllNamed('/dashboard');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Handle initialization error
    if (!isInitialized) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Failed to initialize workout screen',
                style: const TextStyle(fontSize: 18),
              ),
              if (errorMessage.isNotEmpty) Text(
                errorMessage,
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.offAllNamed('/dashboard'),
                child: const Text('Return to Dashboard'),
              ),
            ],
          ),
        ),
      );
    }

    // Make sure the workout is active
    return Obx(() {
      if (!controller.isWorkoutActive.value) {
        debugPrint('ActiveWorkoutScreen: Workout is not active!');
        debugPrint('Active exercises: ${controller.activeExercises.length}');
        debugPrint('Current workout: ${controller.currentWorkout.value}');
        
        // Automatically go back to dashboard after showing error
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.offAllNamed('/dashboard');
          StatusToast.showError('No active workout found');
        });
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Workout'),
            actions: [
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () => Get.offAllNamed('/dashboard'),
                tooltip: 'Return to Dashboard',
              ),
            ],
          ),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'No active workout',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  'Returning to Dashboard...',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      }

      // If we have no exercises, show error
      if (controller.activeExercises.isEmpty) {
        debugPrint('ActiveWorkoutScreen: No exercises available for workout');
        
        // Automatically go back to dashboard after showing error
        Future.delayed(const Duration(milliseconds: 1000), () {
          controller.isWorkoutActive.value = false;
          Get.offAllNamed('/dashboard');
          StatusToast.showError('No exercises found for this workout');
        });
        
        return Scaffold(
          appBar: AppBar(
            title: Text('${controller.currentWorkout.value} Workout'),
            actions: [
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () => Get.offAllNamed('/dashboard'),
                tooltip: 'Return to Dashboard',
              ),
            ],
          ),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fitness_center, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No exercises available',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  'Returning to Dashboard...',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      }

      // Continue with the regular screen when workout is active and we have exercises
      return PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) return;

          // Prevent accidental back navigation during workout
          if (controller.isWorkoutActive.value) {
            // Show confirmation dialog
            final result = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('End Workout?'),
                content: const Text(
                    'Are you sure you want to end this workout? Your progress will not be saved.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('CANCEL'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('END WORKOUT'),
                  ),
                ],
              ),
            );

            // If user confirms, end workout and go to dashboard
            if (result == true) {
              controller.isWorkoutActive.value = false;
              Get.offAllNamed('/dashboard');
            }
          } else {
            Get.back(); // Allow back if not active
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('${controller.currentWorkout.value} Workout'),
            actions: [
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: controller.isProcessingAction.value
                    ? null
                    : controller.saveWorkoutProgress,
                tooltip: 'Save Progress',
              ),
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: controller.isProcessingAction.value
                    ? null
                    : controller.completeWorkout,
                tooltip: 'Complete Workout',
              ),
            ],
          ),
          body: _buildWorkoutBody(controller),
        ),
      );
    });
  }
  
  Widget _buildWorkoutBody(WorkoutController controller) {
    // Show rest timer if resting
    if (controller.isResting.value) {
      return Center(
        child: RestTimerWidget(controller: controller),
      );
    }

    // This should now be redundant since we check for empty exercises earlier,
    // but keeping as an extra safety check
    if (controller.activeExercises.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No exercises available',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      );
    }

    // Safety check for index being in range
    final index = controller.activeExerciseIndex.value.clamp(0, controller.activeExercises.length - 1);
    final currentExercise = controller.activeExercises[index];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (index + 1) / controller.activeExercises.length,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                controller.getWorkoutColor(controller.currentWorkout.value),
              ),
              minHeight: 10,
            ),

            const SizedBox(height: 8),

            // Exercise progress text
            Text(
              'Exercise ${index + 1} of ${controller.activeExercises.length}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 16),

            // Exercise name and details card
            _buildExerciseDetailsCard(currentExercise, controller),

            const SizedBox(height: 24),

            // Sets tracking card
            _buildSetsTrackingCard(currentExercise, controller, index),
          ],
        ),
      ),
    );
  }

  // Card showing exercise details
  Widget _buildExerciseDetailsCard(Exercise exercise, WorkoutController controller) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise name
            Text(
              exercise.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Target sets and reps
            Row(
              children: [
                const Icon(Icons.repeat, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${exercise.targetSets} sets',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.fitness_center, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${exercise.targetReps} reps',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Exercise image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                exercise.imageUrl ?? 'https://via.placeholder.com/150?text=Exercise',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.broken_image,
                      size: 60,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card for tracking sets
  Widget _buildSetsTrackingCard(Exercise exercise, WorkoutController controller, int exerciseIndex) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Track Your Sets',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Sets counter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text(
                      'Completed',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                      '${exercise.completedSets.value}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                  ],
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.grey[300],
                ),
                Column(
                  children: [
                    const Text(
                      'Remaining',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(() => Text(
                      '${exercise.targetSets - exercise.completedSets.value}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Reps adjustment
            const Text(
              'Reps for this set:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Reps counter with +/- buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() => IconButton(
                  onPressed: controller.isProcessingAction.value
                      ? null
                      : () {
                          if (exercise.currentReps.value > 1) {
                            exercise.currentReps.value--;
                          }
                        },
                  icon: const Icon(Icons.remove_circle_outline),
                )),
                Container(
                  width: 80,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Obx(() => Text(
                      '${exercise.currentReps.value}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                  ),
                ),
                Obx(() => IconButton(
                  onPressed: controller.isProcessingAction.value
                      ? null
                      : () {
                          exercise.currentReps.value++;
                        },
                  icon: const Icon(Icons.add_circle_outline),
                )),
              ],
            ),

            const SizedBox(height: 16),

            // Weight adjustment
            const Text(
              'Weight:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Weight input with text field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: WeightInputField(
                weight: exercise.weight,
                showIncrement: true,
              ),
            ),

            const SizedBox(height: 16),

            // Complete set button
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                onPressed: controller.isProcessingAction.value
                    ? null
                    : () {
                        controller.completeSet(exerciseIndex);
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: controller.getWorkoutColor(
                      controller.currentWorkout.value),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[400],
                ),
                child: controller.isProcessingAction.value
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              )),
                          SizedBox(width: 8),
                          Text('PROCESSING...'),
                        ],
                      )
                    : const Text('COMPLETE SET'),
              )),
            ),
          ],
        ),
      ),
    );
  }
}
