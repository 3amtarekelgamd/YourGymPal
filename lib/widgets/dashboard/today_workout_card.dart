import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/workout_controller.dart';
import 'workout_day_header.dart';
import 'workout_completed_view.dart';
import 'workout_skipped_view.dart';
import 'workout_active_view.dart';
import 'workout_rest_day_view.dart';

class TodayWorkoutCard extends StatelessWidget {
  final WorkoutController controller;

  const TodayWorkoutCard({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WorkoutDayHeader(
                  day: controller.currentDay.value,
                  workout: controller.currentWorkout.value,
                  getWorkoutColor: controller.getWorkoutColor,
                  isCompleted: controller.isTodayWorkoutCompleted.value,
                  isSkipped: controller.isTodayWorkoutSkipped.value,
                ),
                const SizedBox(height: 16),
                _buildContent(context),
              ],
            ),
          ),
        ));
  }

  Widget _buildContent(BuildContext context) {
    // Debug help

    if (controller.isTodayWorkoutCompleted.value) {
      return const WorkoutCompletedView();
    } else if (controller.isTodayWorkoutSkipped.value) {
      return WorkoutSkippedView(
        onUndoSkip: controller.resetTodaysWorkoutStatus,
      );
    } else if (!controller.isRestDay.value) {
      return WorkoutActiveView(
        workoutName: controller.currentWorkout.value,
        exercises:
            controller.getExercisesForWorkout(controller.currentWorkout.value),
        isProcessing: controller.isProcessingAction.value,
        onStart: controller.startWorkout,
        onSkip: controller.skipWorkout,
        hasIncompletedWorkout: controller.hasIncompleteWorkout.value,
      );
    } else {
      return const WorkoutRestDayView();
    }
  }
}
