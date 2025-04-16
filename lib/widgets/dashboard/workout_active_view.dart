import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'exercise_list_item.dart';

class WorkoutActiveView extends StatelessWidget {
  final String workoutName;
  final List<String> exercises;
  final bool isProcessing;
  final VoidCallback onStart;
  final VoidCallback onSkip;
  final bool hasIncompletedWorkout;

  const WorkoutActiveView({
    super.key,
    required this.workoutName,
    required this.exercises,
    required this.isProcessing,
    required this.onStart,
    required this.onSkip,
    this.hasIncompletedWorkout = false,
  });

  @override
  Widget build(BuildContext context) {
    // Use a GetX reactive variable to track local button state
    final RxBool isButtonDisabled = isProcessing.obs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today\'s Exercises:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...exercises.map((exercise) => ExerciseListItem(exercise: exercise)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Obx(() => ElevatedButton.icon(
                    onPressed: isButtonDisabled.value
                        ? null
                        : () {
                            // Disable button immediately on click
                            isButtonDisabled.value = true;

                            // Call the action
                            onStart();
                          },
                    icon: isButtonDisabled.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white70,
                            ),
                          )
                        : const Icon(Icons.play_arrow),
                    label: Text(hasIncompletedWorkout
                        ? 'CONTINUE WORKOUT'
                        : 'START WORKOUT'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[400],
                      disabledForegroundColor: Colors.white70,
                    ),
                  )),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: Obx(() => IconButton(
                    onPressed: isButtonDisabled.value
                        ? null
                        : () {
                            // Disable button immediately
                            isButtonDisabled.value = true;

                            // Call skip function
                            onSkip();
                          },
                    icon: isButtonDisabled.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.skip_next),
                    tooltip: 'Skip Workout',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      padding: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                  )),
            ),
          ],
        ),
      ],
    );
  }
}
