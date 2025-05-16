import 'package:flutter/material.dart';
import '../../models/models.dart';

/// Shows workout completion dialog with summary
class WorkoutCompletionDialog extends StatelessWidget {
  final String workoutType;
  final List<Exercise> exercises;
  final Duration duration;

  const WorkoutCompletionDialog({
    super.key,
    required this.workoutType,
    required this.exercises,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate stats
    int totalSets = 0;
    int totalReps = 0;

    for (var exercise in exercises) {
      totalSets += exercise.completedSets.value;
      totalReps += exercise.completedSets.value * exercise.targetReps;
    }

    return AlertDialog(
      title: const Row(
        children: [
          Icon(
            Icons.emoji_events,
            color: Colors.amber,
            size: 28,
          ),
          SizedBox(width: 8),
          Text('Workout Complete!'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Great job completing your $workoutType workout!',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatItem(
              Icons.fitness_center, 'Total Sets', totalSets.toString()),
          _buildStatItem(Icons.repeat, 'Total Reps', totalReps.toString()),
          _buildStatItem(
            Icons.timer,
            'Duration',
            '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '💪 Keep up the good work! 💪',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CLOSE'),
        ),
        ElevatedButton(
          onPressed: () {
            // Could add sharing functionality here
            Navigator.pop(context);
          },
          child: const Text('SHARE RESULTS'),
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
