import 'exercise.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../controllers/templates_controller.dart';
import 'workout_template.dart';

/// Data for predefined workout types
class WorkoutData {
  // List of available workout types
  static List<String> get availableWorkoutTypes =>
      ['Push', 'Pull', 'Legs', 'Custom'];

  // Get exercises for a specific workout type
  static List<Exercise> getExercisesForType(String workoutType) {
    // Convert to lowercase for case-insensitive comparison
    final lowercaseType = workoutType.toLowerCase();
    
    // Handle standard workout types first
    switch (lowercaseType) {
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

      case 'rest':
        // Return empty list for Rest type
        return [];
      
      case 'custom':
        // For the specific "Custom" string, try to use templates first,
        // but provide default exercises as a fallback
        return _generateDefaultExercisesForCustomWorkout("Custom");
        
      default:
        // For any other workout type (custom workouts), look for templates first
        try {
          // Try to find a template with this name
          final templatesController = Get.find<TemplatesController>();
          
          // Look for a template with matching name or type
          final template = templatesController.templates.firstWhereOrNull(
            (t) => t.name.toLowerCase() == workoutType.toLowerCase() || 
                   t.type.toLowerCase() == workoutType.toLowerCase()
          );
          
          if (template != null && template.exercises.isNotEmpty) {
            // Convert template exercises to regular exercises
            return template.exercises.map((te) => 
              Exercise(
                name: te.name,
                workoutType: template.type,
                primaryMuscle: template.type,
                secondaryMuscles: [],
                equipment: 'Unknown',
                targetSets: te.targetSets > 0 ? te.targetSets : 3,
                targetReps: te.targetReps > 0 ? te.targetReps : 10,
                notes: te.notes,
              )
            ).toList();
          }
        } catch (e) {
          // If there's an error getting templates, log it and use defaults
          debugPrint('Error getting exercises from template: $e');
        }
        
        // Fallback to default exercises if template not found or empty
        return _generateDefaultExercisesForCustomWorkout(workoutType);
    }
  }

  // Helper method to generate default exercises for any custom workout type
  static List<Exercise> _generateDefaultExercisesForCustomWorkout(String workoutType) {
    // Create a properly capitalized version of the workout type for display
    final displayType = workoutType.isNotEmpty 
        ? workoutType[0].toUpperCase() + workoutType.substring(1)
        : workoutType;
        
    return [
      Exercise(
        name: 'Bench Press',
        workoutType: displayType,
        primaryMuscle: 'Chest',
        secondaryMuscles: ['Triceps', 'Shoulders'],
        equipment: 'Barbell',
        targetSets: 3,
        targetReps: 10,
      ),
      Exercise(
        name: 'Squats',
        workoutType: displayType,
        primaryMuscle: 'Legs',
        secondaryMuscles: ['Glutes', 'Hamstrings'],
        equipment: 'Barbell',
        targetSets: 3,
        targetReps: 10,
      ),
      Exercise(
        name: 'Pull-ups',
        workoutType: displayType,
        primaryMuscle: 'Back',
        secondaryMuscles: ['Biceps'],
        equipment: 'Bodyweight',
        targetSets: 3,
        targetReps: 8,
      ),
    ];
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
    final lowercaseType = workoutType.toLowerCase();
    
    switch (lowercaseType) {
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
      case 'rest':
        return ['Custom workout - add your own exercises'];
      default:
        // For any custom workout, return default descriptions
        return [
          'Bench Press: 3 sets x 10 reps',
          'Squats: 3 sets x 10 reps',
          'Pull-ups: 3 sets x 8 reps',
        ];
    }
  }
}
