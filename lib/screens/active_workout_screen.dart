import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/workout_controller.dart';
import '../controllers/settings_controller.dart';
import '../widgets/workout/rest_timer.dart';
import '../widgets/workout/weight_input_field.dart';

class ActiveWorkoutScreen extends StatelessWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WorkoutController>();
    Get.find<SettingsController>();

    // Make sure the workout is active
    if (!controller.isWorkoutActive.value) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Workout'),
        ),
        body: const Center(
          child: Text('No active workout'),
        ),
      );
    }

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
          title: Obx(() => Text('${controller.currentWorkout.value} Workout')),
          actions: [
            Obx(() => IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: controller.isProcessingAction.value
                      ? null
                      : controller.saveWorkoutProgress,
                  tooltip: 'Save Progress',
                )),
            Obx(() => IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: controller.isProcessingAction.value
                      ? null
                      : controller.completeWorkout,
                  tooltip: 'Complete Workout',
                )),
          ],
        ),
        body: Obx(() {
          // Show rest timer if resting
          if (controller.isResting.value) {
            return Center(
              child: RestTimerWidget(controller: controller),
            );
          }

          // Original workout content
          if (controller.activeExercises.isEmpty) {
            return const Center(
              child: Text('No exercises available'),
            );
          }

          final currentExercise =
              controller.activeExercises[controller.activeExerciseIndex.value];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress indicator
                  LinearProgressIndicator(
                    value: (controller.activeExerciseIndex.value + 1) /
                        controller.activeExercises.length,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      controller
                          .getWorkoutColor(controller.currentWorkout.value),
                    ),
                    minHeight: 10,
                  ),

                  const SizedBox(height: 8),

                  // Exercise progress text
                  Text(
                    'Exercise ${controller.activeExerciseIndex.value + 1} of ${controller.activeExercises.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Exercise name and details
                  Card(
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
                            currentExercise.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Target sets and reps
                          Row(
                            children: [
                              const Icon(Icons.repeat,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                '${currentExercise.targetSets} sets',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Icon(Icons.fitness_center,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                '${currentExercise.targetReps} reps',
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
                              currentExercise.imageUrl ??
                                  'https://via.placeholder.com/150?text=Exercise',
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
                  ),

                  const SizedBox(height: 24),

                  // Sets tracking
                  Card(
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
                                  Text(
                                    '${currentExercise.completedSets.value}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
                                  Text(
                                    '${currentExercise.targetSets - currentExercise.completedSets.value}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
                              IconButton(
                                onPressed: controller.isProcessingAction.value
                                    ? null
                                    : () {
                                        if (currentExercise.currentReps.value >
                                            1) {
                                          currentExercise.currentReps.value--;
                                        }
                                      },
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                              Container(
                                width: 80,
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '${currentExercise.currentReps.value}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: controller.isProcessingAction.value
                                    ? null
                                    : () {
                                        currentExercise.currentReps.value++;
                                      },
                                icon: const Icon(Icons.add_circle_outline),
                              ),
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
                              weight: currentExercise.weight,
                              showIncrement: true,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Complete set button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: controller.isProcessingAction.value
                                  ? null
                                  : () {
                                      controller.completeSet(
                                          controller.activeExerciseIndex.value);
                                    },
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
