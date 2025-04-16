import 'package:get/get.dart';

/// Exercise data class
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
  final RxDouble weight = 0.0.obs; // Track weight used for the exercise
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
    double? initialWeight,
    this.imageUrl,
    this.notes,
  }) {
    if (initialWeight != null) {
      weight.value = initialWeight;
    }
  }

  // Add observable properties with GetX
  String get formattedSets => '$completedSets/$targetSets';

  // Convert exercise to JSON
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
      'weight': weight.value,
      'imageUrl': imageUrl,
      'notes': notes,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    final exercise = Exercise(
      name: json['name'],
      workoutType: json['workoutType'],
      primaryMuscle: json['primaryMuscle'],
      secondaryMuscles: List<String>.from(json['secondaryMuscles']),
      equipment: json['equipment'],
      targetSets: json['targetSets'],
      targetReps: json['targetReps'],
      initialWeight: json['weight']?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'],
      notes: json['notes'],
    );

    // Initialize the Rx values if they exist in the JSON
    if (json['completedSets'] != null) {
      exercise.completedSets.value = json['completedSets'];
    }

    if (json['currentReps'] != null) {
      exercise.currentReps.value = json['currentReps'];
    }

    return exercise;
  }
}
