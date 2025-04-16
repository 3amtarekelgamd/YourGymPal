// Import GetX for observable properties
import 'package:get/get.dart';

// Barrel file to export all models
export 'exercise.dart';
export 'workout_status.dart';
export 'workout_type.dart';
export 'workout_history_entry.dart';
export 'workout_data.dart';

// Define the workout status enum
enum WorkoutStatus { notStarted, inProgress, completed, skipped }

class Exercise {
  final String name;
  final String workoutType;
  final String primaryMuscle;
  final List<String> secondaryMuscles;
  final String equipment;
  final int targetSets;
  final int targetReps;
  final RxInt completedSets = 0.obs;
  final RxInt currentReps = 0.obs; // Track current reps for exercise
  final String? imageUrl;
  final String? notes;

  Exercise({
    required this.name,
    required this.workoutType,
    required this.primaryMuscle,
    required this.secondaryMuscles,
    required this.equipment,
    required this.targetSets,
    required this.targetReps,
    this.imageUrl,
    this.notes,
  });

  // Add observable properties with GetX
  String get formattedSets => '$completedSets/$targetSets';

  // Convert to JSON for history storage
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'workoutType': workoutType,
      'primaryMuscle': primaryMuscle,
      'secondaryMuscles': secondaryMuscles,
      'equipment': equipment,
      'targetSets': targetSets,
      'targetReps': targetReps,
      'completedSets': completedSets.value,
      'currentReps': currentReps.value,
      'imageUrl': imageUrl,
      'notes': notes,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'] ?? '',
      workoutType: json['workoutType'] ?? '',
      primaryMuscle: json['primaryMuscle'] ?? '',
      secondaryMuscles: List<String>.from(json['secondaryMuscles'] ?? []),
      equipment: json['equipment'] ?? '',
      targetSets: json['targetSets'] ?? 0,
      targetReps: json['targetReps'] ?? 0,
      imageUrl: json['imageUrl'],
      notes: json['notes'],
    );
  }
}

// Workout history entry
class WorkoutHistoryEntry {
  final DateTime date;
  final String workoutType;
  final List<Exercise> exercises;
  final WorkoutStatus status;
  final int totalSets;
  final int completedSets;
  final Duration? duration;

  WorkoutHistoryEntry({
    required this.date,
    required this.workoutType,
    required this.exercises,
    required this.status,
    required this.totalSets,
    required this.completedSets,
    this.duration,
  });

  // Check if this workout was done today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

// Static data helper
class WorkoutData {
  // Get exercises for a workout type
  static List<Exercise> getExercisesForType(String type) {
    // Mock implementation - in real app this would come from a database
    switch (type.toLowerCase()) {
      case 'push':
        return [
          Exercise(
            name: 'Bench Press',
            workoutType: 'Push',
            primaryMuscle: 'Chest',
            secondaryMuscles: ['Triceps', 'Shoulders'],
            equipment: 'Barbell',
            targetSets: 4,
            targetReps: 8,
          ),
          Exercise(
            name: 'Overhead Press',
            workoutType: 'Push',
            primaryMuscle: 'Shoulders',
            secondaryMuscles: ['Triceps'],
            equipment: 'Barbell',
            targetSets: 3,
            targetReps: 10,
          ),
          Exercise(
            name: 'Incline Dumbbell Press',
            workoutType: 'Push',
            primaryMuscle: 'Upper Chest',
            secondaryMuscles: ['Shoulders', 'Triceps'],
            equipment: 'Dumbbells',
            targetSets: 3,
            targetReps: 12,
          ),
          Exercise(
            name: 'Tricep Pushdown',
            workoutType: 'Push',
            primaryMuscle: 'Triceps',
            secondaryMuscles: [],
            equipment: 'Cable',
            targetSets: 3,
            targetReps: 12,
          ),
          Exercise(
            name: 'Lateral Raises',
            workoutType: 'Push',
            primaryMuscle: 'Shoulders',
            secondaryMuscles: [],
            equipment: 'Dumbbells',
            targetSets: 3,
            targetReps: 15,
          ),
        ];
      case 'pull':
        return [
          Exercise(
            name: 'Deadlift',
            workoutType: 'Pull',
            primaryMuscle: 'Back',
            secondaryMuscles: ['Hamstrings', 'Glutes', 'Forearms'],
            equipment: 'Barbell',
            targetSets: 3,
            targetReps: 6,
          ),
          Exercise(
            name: 'Pull-ups',
            workoutType: 'Pull',
            primaryMuscle: 'Back',
            secondaryMuscles: ['Biceps', 'Shoulders'],
            equipment: 'Body Weight',
            targetSets: 3,
            targetReps: 8,
          ),
          Exercise(
            name: 'Barbell Rows',
            workoutType: 'Pull',
            primaryMuscle: 'Back',
            secondaryMuscles: ['Biceps', 'Shoulders'],
            equipment: 'Barbell',
            targetSets: 3,
            targetReps: 10,
          ),
          Exercise(
            name: 'Bicep Curls',
            workoutType: 'Pull',
            primaryMuscle: 'Biceps',
            secondaryMuscles: ['Forearms'],
            equipment: 'Dumbbells',
            targetSets: 3,
            targetReps: 12,
          ),
          Exercise(
            name: 'Face Pulls',
            workoutType: 'Pull',
            primaryMuscle: 'Rear Deltoids',
            secondaryMuscles: ['Traps', 'Rhomboids'],
            equipment: 'Cable',
            targetSets: 3,
            targetReps: 15,
          ),
        ];
      case 'legs':
        return [
          Exercise(
            name: 'Squats',
            workoutType: 'Legs',
            primaryMuscle: 'Quadriceps',
            secondaryMuscles: ['Glutes', 'Hamstrings', 'Core'],
            equipment: 'Barbell',
            targetSets: 4,
            targetReps: 8,
          ),
          Exercise(
            name: 'Romanian Deadlift',
            workoutType: 'Legs',
            primaryMuscle: 'Hamstrings',
            secondaryMuscles: ['Glutes', 'Lower Back'],
            equipment: 'Barbell',
            targetSets: 3,
            targetReps: 10,
          ),
          Exercise(
            name: 'Leg Press',
            workoutType: 'Legs',
            primaryMuscle: 'Quadriceps',
            secondaryMuscles: ['Glutes', 'Hamstrings'],
            equipment: 'Machine',
            targetSets: 3,
            targetReps: 12,
          ),
          Exercise(
            name: 'Calf Raises',
            workoutType: 'Legs',
            primaryMuscle: 'Calves',
            secondaryMuscles: [],
            equipment: 'Machine',
            targetSets: 4,
            targetReps: 15,
          ),
          Exercise(
            name: 'Leg Curls',
            workoutType: 'Legs',
            primaryMuscle: 'Hamstrings',
            secondaryMuscles: [],
            equipment: 'Machine',
            targetSets: 3,
            targetReps: 12,
          ),
        ];
      default:
        return [];
    }
  }
}
