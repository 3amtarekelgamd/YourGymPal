import 'package:flutter/material.dart';

/// Action buttons for the dashboard (Start Workout, Skip)
class WorkoutActionButtons extends StatelessWidget {
  final String workoutType;
  final bool isCompleted;
  final bool isSkipped;
  final bool isProcessing;
  final VoidCallback onStartWorkout;
  final VoidCallback onSkipWorkout;

  const WorkoutActionButtons({
    super.key,
    required this.workoutType,
    required this.isCompleted,
    required this.isSkipped,
    required this.isProcessing,
    required this.onStartWorkout,
    required this.onSkipWorkout,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
      return _buildCompletedState();
    } else if (isSkipped) {
      return _buildSkippedState();
    } else {
      return _buildNormalState();
    }
  }

  Widget _buildCompletedState() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8.0),
          const Expanded(
            child: Text(
              'Workout completed for today!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          TextButton.icon(
            onPressed: onStartWorkout,
            icon: const Icon(Icons.refresh),
            label: const Text('Restart'),
          ),
        ],
      ),
    );
  }

  Widget _buildSkippedState() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          const Icon(Icons.cancel, color: Colors.grey),
          const SizedBox(width: 8.0),
          const Expanded(
            child: Text(
              'Workout skipped for today',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          TextButton.icon(
            onPressed: onStartWorkout,
            icon: const Icon(Icons.undo),
            label: const Text('Undo Skip'),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalState() {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: ElevatedButton.icon(
            onPressed: isProcessing ? null : onStartWorkout,
            icon: isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.fitness_center),
            label: const Text('START WORKOUT'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
            ),
          ),
        ),
        const SizedBox(width: 8.0),
        Tooltip(
          message: 'Skip today\'s workout',
          child: IconButton(
            onPressed: isProcessing ? null : onSkipWorkout,
            icon: const Icon(Icons.close),
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}
