import 'package:flutter/material.dart';
import 'exercise.dart';

/// Workout Type data class
class WorkoutType {
  final String name;
  final Color color;
  final List<Exercise> exercises;
  final List<String> exerciseDescriptions;

  const WorkoutType({
    required this.name,
    required this.color,
    required this.exercises,
    required this.exerciseDescriptions,
  });

  // Helper method to get color for a workout type
  static Color getColorForType(String workoutType) {
    switch (workoutType.toLowerCase()) {
      case 'push':
        return Colors.blue;
      case 'pull':
        return Colors.red;
      case 'legs':
        return Colors.green;
      case 'rest':
        return Colors.grey;
      case 'custom':
        return Colors.purple;
      case 'upper body':
        return Colors.indigo;
      case 'lower body':
        return Colors.deepOrange;
      case 'full body':
        return Colors.teal;
      case 'cardio':
        return Colors.pink;
      default:
        return Colors.blueGrey;
    }
  }
}
