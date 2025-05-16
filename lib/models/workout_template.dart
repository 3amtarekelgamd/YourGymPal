import 'package:get/get.dart';

class WorkoutTemplate {
  String id;
  String name;
  String type;
  String description;
  List<TemplateExercise> exercises;
  String? coverImagePath; // Path to template cover image

  WorkoutTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.exercises,
    this.coverImagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'coverImagePath': coverImagePath,
    };
  }

  factory WorkoutTemplate.fromJson(Map<String, dynamic> json) {
    return WorkoutTemplate(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      description: json['description'],
      exercises: (json['exercises'] as List)
          .map((e) => TemplateExercise.fromJson(e))
          .toList(),
      coverImagePath: json['coverImagePath'],
    );
  }

  // Create a copy with updated fields
  WorkoutTemplate copyWith({
    String? name,
    String? type,
    String? description,
    List<TemplateExercise>? exercises,
    String? coverImagePath,
  }) {
    return WorkoutTemplate(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
      coverImagePath: coverImagePath ?? this.coverImagePath,
    );
  }
}

class TemplateExercise {
  String name;
  int targetSets;
  int targetReps;
  double weight; // Weight in kg/lbs
  String? notes;
  String? imagePath; // Path to locally stored image
  final RxInt completedSets = 0.obs;

  TemplateExercise({
    required this.name,
    required this.targetSets,
    required this.targetReps,
    this.weight = 0.0,
    this.notes,
    this.imagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'targetSets': targetSets,
      'targetReps': targetReps,
      'weight': weight,
      'notes': notes,
      'imagePath': imagePath,
    };
  }

  factory TemplateExercise.fromJson(Map<String, dynamic> json) {
    return TemplateExercise(
      name: json['name'] ?? 'Exercise',
      targetSets: json['targetSets'] ?? 3,
      targetReps: json['targetReps'] ?? 10,
      weight: json['weight']?.toDouble() ?? 0.0,
      notes: json['notes'],
      imagePath: json['imagePath'],
    );
  }

  // Create a copy with updated fields
  TemplateExercise copyWith({
    String? name,
    int? targetSets,
    int? targetReps,
    double? weight,
    String? notes,
    String? imagePath,
  }) {
    return TemplateExercise(
      name: name ?? this.name,
      targetSets: targetSets ?? this.targetSets,
      targetReps: targetReps ?? this.targetReps,
      weight: weight ?? this.weight,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
