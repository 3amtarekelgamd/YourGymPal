import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../controllers/workout_controller.dart';
import '../../models/workout_status.dart';
import '../../models/workout_history_entry.dart';

class WorkoutHistoryList extends StatelessWidget {
  final WorkoutController controller;

  const WorkoutHistoryList({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.workoutHistory.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'No workout history yet',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Complete workouts to see them here',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      }

      // Sort history by date (newest first)
      final sortedHistory = controller.workoutHistory.toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      return ListView.builder(
        itemCount: sortedHistory.length,
        itemBuilder: (context, index) {
          final workout = sortedHistory[index];
          return _buildHistoryItem(context, workout, controller);
        },
      );
    });
  }

  Widget _buildHistoryItem(
    BuildContext context,
    WorkoutHistoryEntry workout,
    WorkoutController controller,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: controller.getWorkoutColor(workout.workoutType),
          child: Icon(
            workout.status == WorkoutStatus.completed
                ? Icons.fitness_center
                : Icons.skip_next,
            color: Colors.white,
          ),
        ),
        title: Text(
          workout.workoutType,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${workout.date.day}/${workout.date.month}/${workout.date.year}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              timeago.format(workout.date),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: _getStatusIcon(workout.status),
        children: [
          if (workout.status == WorkoutStatus.completed &&
              workout.exercises != null &&
              workout.exercises!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Exercises',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...workout.exercises!.map((exercise) {
                    // Debug print
                    debugPrint('Exercise data type: ${exercise.runtimeType}');
                    debugPrint('Exercise data: $exercise');

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.fitness_center, size: 18),
                      title: Text(exercise['name'] ?? ''),
                      subtitle: Text(
                        '${exercise['completedSets'] ?? 0} sets × ${exercise['currentReps'] ?? 0} reps',
                      ),
                      dense: true,
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _getStatusIcon(WorkoutStatus status) {
    switch (status) {
      case WorkoutStatus.completed:
        return const Chip(
          label: Text('COMPLETED'),
          backgroundColor: Colors.green,
          labelStyle: TextStyle(color: Colors.white, fontSize: 10),
        );
      case WorkoutStatus.skipped:
        return const Chip(
          label: Text('SKIPPED'),
          backgroundColor: Colors.orange,
          labelStyle: TextStyle(color: Colors.white, fontSize: 10),
        );
      default:
        return const Chip(
          label: Text('IN PROGRESS'),
          backgroundColor: Colors.blue,
          labelStyle: TextStyle(color: Colors.white, fontSize: 10),
        );
    }
  }
}
