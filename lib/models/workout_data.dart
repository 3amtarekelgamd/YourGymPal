import 'exercise.dart';

/// Data for predefined workout types
class WorkoutData {
  // List of available workout types
  static List<String> get availableWorkoutTypes =>
      ['Push', 'Pull', 'Legs', 'Custom'];

  // Get exercises for a specific workout type
  static List<Exercise> getExercisesForType(String workoutType) {
    switch (workoutType.toLowerCase()) {
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
            imageUrl:
                'https://www.inspireusafoundation.org/wp-content/uploads/2022/06/barbell-bench-press-benefits.jpg',
          ),
          Exercise(
            name: 'Shoulder Press',
            workoutType: 'Push',
            primaryMuscle: 'Shoulders',
            secondaryMuscles: ['Triceps'],
            equipment: 'Barbell/Dumbbell',
            targetSets: 3,
            targetReps: 10,
            imageUrl:
                'https://www.inspireusafoundation.org/wp-content/uploads/2022/11/shoulder-press-1024x576.png',
          ),
          Exercise(
            name: 'Tricep Pushdowns',
            workoutType: 'Push',
            primaryMuscle: 'Triceps',
            secondaryMuscles: [],
            equipment: 'Cable',
            targetSets: 3,
            targetReps: 12,
            imageUrl:
                'https://www.inspireusafoundation.org/wp-content/uploads/2022/01/tricep-pushdown.jpg',
          ),
        ];

      case 'pull':
        return [
          Exercise(
            name: 'Deadlifts',
            workoutType: 'Pull',
            primaryMuscle: 'Back',
            secondaryMuscles: ['Hamstrings', 'Glutes'],
            equipment: 'Barbell',
            targetSets: 4,
            targetReps: 6,
            imageUrl:
                'https://www.inspireusafoundation.org/wp-content/uploads/2022/01/barbell-deadlift-movement.gif',
          ),
          Exercise(
            name: 'Pullups/Lat Pulldowns',
            workoutType: 'Pull',
            primaryMuscle: 'Back',
            secondaryMuscles: ['Biceps'],
            equipment: 'Bodyweight/Machine',
            targetSets: 3,
            targetReps: 8,
            imageUrl:
                'https://www.inspireusafoundation.org/wp-content/uploads/2022/03/lat-pulldown-muscles-768x543.jpg',
          ),
          Exercise(
            name: 'Bicep Curls',
            workoutType: 'Pull',
            primaryMuscle: 'Biceps',
            secondaryMuscles: ['Forearms'],
            equipment: 'Dumbbell',
            targetSets: 3,
            targetReps: 12,
            imageUrl:
                'https://www.inspireusafoundation.org/wp-content/uploads/2022/01/barbell-curl-full-range-of-motion.gif',
          ),
        ];

      case 'legs':
        return [
          Exercise(
            name: 'Squats',
            workoutType: 'Legs',
            primaryMuscle: 'Quadriceps',
            secondaryMuscles: ['Glutes', 'Hamstrings'],
            equipment: 'Barbell',
            targetSets: 4,
            targetReps: 8,
            imageUrl:
                'https://www.inspireusafoundation.org/wp-content/uploads/2022/10/different-squat-variations.jpg',
          ),
          Exercise(
            name: 'Romanian Deadlifts',
            workoutType: 'Legs',
            primaryMuscle: 'Hamstrings',
            secondaryMuscles: ['Glutes', 'Lower Back'],
            equipment: 'Barbell',
            targetSets: 3,
            targetReps: 8,
            imageUrl:
                'https://www.inspireusafoundation.org/wp-content/uploads/2023/01/romanian-deadlift-form.jpg',
          ),
          Exercise(
            name: 'Calf Raises',
            workoutType: 'Legs',
            primaryMuscle: 'Calves',
            secondaryMuscles: [],
            equipment: 'Machine/Bodyweight',
            targetSets: 3,
            targetReps: 15,
            imageUrl:
                'https://www.inspireusafoundation.org/wp-content/uploads/2022/09/standing-calf-raise.jpg',
          ),
        ];

      case 'custom':
        // Return empty list for custom - user will add their own exercises
        return [];

      default:
        return [];
    }
  }

  // Method to create a custom exercise
  static Exercise createCustomExercise({
    required String name,
    required String workoutType,
    required int targetSets,
    required int targetReps,
    String primaryMuscle = 'Custom',
    List<String> secondaryMuscles = const [],
    String equipment = 'Custom',
    String? imageUrl,
    String? notes,
  }) {
    return Exercise(
      name: name,
      workoutType: workoutType,
      primaryMuscle: primaryMuscle,
      secondaryMuscles: secondaryMuscles,
      equipment: equipment,
      targetSets: targetSets,
      targetReps: targetReps,
      imageUrl: imageUrl,
      notes: notes,
    );
  }

  // Get simple exercise descriptions for a specific workout type
  static List<String> getExerciseDescriptionsForType(String workoutType) {
    switch (workoutType.toLowerCase()) {
      case 'push':
        return [
          'Bench Press: 4 sets x 8 reps',
          'Shoulder Press: 3 sets x 10 reps',
          'Tricep Pushdowns: 3 sets x 12 reps',
        ];
      case 'pull':
        return [
          'Deadlifts: 4 sets x 6 reps',
          'Pullups/Lat Pulldowns: 3 sets x 8 reps',
          'Bicep Curls: 3 sets x 12 reps',
        ];
      case 'legs':
        return [
          'Squats: 4 sets x 8 reps',
          'Romanian Deadlifts: 3 sets x 8 reps',
          'Calf Raises: 3 sets x 15 reps',
        ];
      case 'custom':
        return ['Custom workout - add your own exercises'];
      default:
        return [];
    }
  }
}
