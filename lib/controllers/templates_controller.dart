// ignore_for_file: depend_on_referenced_packages

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/workout_template.dart';
import '../widgets/status/status_widgets.dart';
import '../services/image_service.dart';
import 'workout_controller.dart';
import 'package:flutter/material.dart';
import '../screens/active_workout_screen.dart';
import '../models/workout_data.dart';

class TemplatesController extends GetxController {
  // Storage keys
  static const String kWorkoutTemplates = 'workout_templates';
  
  // GetStorage instance
  final GetStorage _storage = GetStorage();
  
  final RxList<WorkoutTemplate> templates = <WorkoutTemplate>[].obs;
  final Rx<WorkoutTemplate?> editingTemplate = Rx<WorkoutTemplate?>(null);
  late final ImageService _imageService;

  @override
  void onInit() {
    super.onInit();
    _imageService = Get.find<ImageService>();
    loadTemplates();
    
    // Save templates when they change
    ever(templates, (_) {
      saveTemplates();
    });
  }

  // Create default templates for Push, Pull, Legs
  void createDefaultTemplates() {
    final defaultTypes = ['Push', 'Pull', 'Legs'];
    
    // Check if any default templates already exist
    final hasDefaults = templates.any((t) => defaultTypes.contains(t.type));
    
    if (!hasDefaults) {
      // Create Push template
      final pushTemplate = WorkoutTemplate(
        id: 'default-push-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Push',
        type: 'Push',
        description: 'Default push workout focusing on chest, shoulders, and triceps',
        exercises: [
          TemplateExercise(
            name: 'Bench Press',
            targetSets: 4,
            targetReps: 8,
          ),
          TemplateExercise(
            name: 'Shoulder Press',
            targetSets: 3,
            targetReps: 10,
          ),
          TemplateExercise(
            name: 'Tricep Pushdowns',
            targetSets: 3,
            targetReps: 12,
          ),
        ],
      );
      
      // Create Pull template
      final pullTemplate = WorkoutTemplate(
        id: 'default-pull-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Pull',
        type: 'Pull',
        description: 'Default pull workout focusing on back and biceps',
        exercises: [
          TemplateExercise(
            name: 'Deadlifts',
            targetSets: 4,
            targetReps: 6,
          ),
          TemplateExercise(
            name: 'Pullups/Lat Pulldowns',
            targetSets: 3,
            targetReps: 8,
          ),
          TemplateExercise(
            name: 'Bicep Curls',
            targetSets: 3,
            targetReps: 12,
          ),
        ],
      );
      
      // Create Legs template
      final legsTemplate = WorkoutTemplate(
        id: 'default-legs-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Legs',
        type: 'Legs',
        description: 'Default legs workout focusing on quads, hamstrings, and calves',
        exercises: [
          TemplateExercise(
            name: 'Squats',
            targetSets: 4,
            targetReps: 8,
          ),
          TemplateExercise(
            name: 'Romanian Deadlifts',
            targetSets: 3,
            targetReps: 8,
          ),
          TemplateExercise(
            name: 'Calf Raises',
            targetSets: 3,
            targetReps: 15,
          ),
        ],
      );
      
      // Add templates
      templates.addAll([pushTemplate, pullTemplate, legsTemplate]);
    }
  }

  Future<void> loadTemplates() async {
    try {
      final templatesJson = _storage.read<List<dynamic>>(kWorkoutTemplates);
      
      if (templatesJson != null) {
        final loadedTemplates = templatesJson
            .map((json) => WorkoutTemplate.fromJson(json))
            .toList();

        templates.assignAll(loadedTemplates);
        debugPrint('Loaded ${loadedTemplates.length} templates from GetStorage');
      } else {
        // If not found in GetStorage, try loading from SharedPreferences (for migration)
        await _loadFromSharedPreferences();
      }
      
      // Create default templates after loading
      createDefaultTemplates();
    } catch (e) {
      debugPrint('Failed to load templates: $e');
    }
  }
  
  // Migration method to load from SharedPreferences
  Future<void> _loadFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final templatesJson = prefs.getStringList('workout_templates') ?? [];

      if (templatesJson.isNotEmpty) {
        final loadedTemplates = templatesJson
            .map((json) => WorkoutTemplate.fromJson(jsonDecode(json)))
            .toList();

        templates.assignAll(loadedTemplates);
        debugPrint('Migrated ${loadedTemplates.length} templates from SharedPreferences');
        
        // Save immediately to GetStorage
        saveTemplates();
        
        // Clear from SharedPreferences to complete migration
        await prefs.remove('workout_templates');
      }
    } catch (e) {
      debugPrint('Failed to migrate templates from SharedPreferences: $e');
    }
  }

  Future<void> saveTemplates() async {
    try {
      final templatesJson = templates.map((template) => template.toJson()).toList();
      await _storage.write(kWorkoutTemplates, templatesJson);
      debugPrint('Saved ${templates.length} templates to GetStorage');
    } catch (e) {
      debugPrint('Failed to save templates: $e');
      StatusToast.showError('Failed to save workout templates');
    }
  }

  void addTemplate(WorkoutTemplate template) {
    templates.add(template);
    // saveTemplates() no longer needed here as it's called by the reactive listener
    StatusToast.showSuccess('Template added');
  }

  void updateTemplate(WorkoutTemplate template) {
    final index = templates.indexWhere((t) => t.id == template.id);
    if (index >= 0) {
      templates[index] = template;
      // saveTemplates() no longer needed here as it's called by the reactive listener
      StatusToast.showSuccess('Template updated');
    }
  }

  void deleteTemplate(String id) async {
    final template = templates.firstWhereOrNull((t) => t.id == id);
    if (template != null) {
      // Delete template cover image
      if (template.coverImagePath != null) {
        await _imageService.deleteImage(template.coverImagePath);
      }

      // Delete all exercise images
      for (final exercise in template.exercises) {
        if (exercise.imagePath != null) {
          await _imageService.deleteImage(exercise.imagePath);
        }
      }

      templates.removeWhere((t) => t.id == id);
      // saveTemplates() no longer needed here as it's called by the reactive listener
      StatusToast.showSuccess('Template deleted');
    }
  }

  void setEditingTemplate(WorkoutTemplate? template) {
    editingTemplate.value = template;
  }

  bool startTemplateWorkout(String templateId) {
    debugPrint('TemplatesController: Starting template workout with id: $templateId');
    
    final template = templates.firstWhereOrNull((t) => t.id == templateId);
    if (template == null) {
      debugPrint('TemplatesController: Template not found for id: $templateId');
      StatusToast.showError('Template not found');
      return false;
    }

    debugPrint('TemplatesController: Found template: ${template.name}');
    
    // Let the workout controller handle the template, even if it has no exercises
    // It will use default exercises if needed
    final workoutController = Get.find<WorkoutController>();
    
    try {
      // Start the workout directly
      workoutController.startTemplateWorkout(template);
      
      // Verify workout was activated
      if (workoutController.isWorkoutActive.value) {
        debugPrint('TemplatesController: Workout activated successfully');
        return true;
      } else {
        debugPrint('TemplatesController: Failed to activate workout');
        return false;
      }
    } catch (e) {
      debugPrint('TemplatesController: Error starting template workout: $e');
      StatusToast.showError('Error starting workout: $e');
      return false;
    }
  }

  Future<String?> pickTemplateCoverImage() async {
    return _imageService.pickImageFromGallery();
  }

  Future<String?> pickExerciseImage() async {
    return _imageService.pickImageFromGallery();
  }

  void updateTemplateWithNewImage(
      WorkoutTemplate template, String? newImagePath) async {
    // Delete old image if exists
    if (template.coverImagePath != null &&
        template.coverImagePath != newImagePath) {
      await _imageService.deleteImage(template.coverImagePath);
    }

    final updatedTemplate = template.copyWith(coverImagePath: newImagePath);
    updateTemplate(updatedTemplate);
  }

  void updateExerciseWithNewImage(
      WorkoutTemplate template, int exerciseIndex, String? newImagePath) async {
    final exercises = [...template.exercises];
    final oldExercise = exercises[exerciseIndex];

    // Delete old image if exists
    if (oldExercise.imagePath != null &&
        oldExercise.imagePath != newImagePath) {
      await _imageService.deleteImage(oldExercise.imagePath);
    }

    // Update exercise with new image
    exercises[exerciseIndex] = oldExercise.copyWith(imagePath: newImagePath);

    // Update template
    final updatedTemplate = template.copyWith(exercises: exercises);
    updateTemplate(updatedTemplate);
  }

  // Public method to delete images
  Future<void> deleteImage(String? imagePath) async {
    if (imagePath != null) {
      await _imageService.deleteImage(imagePath);
    }
  }

  // Find a template by its type or name
  WorkoutTemplate? findTemplateByType(String typeOrName) {
    try {
      return templates.firstWhereOrNull((template) => 
        template.type.toLowerCase() == typeOrName.toLowerCase() || 
        template.name.toLowerCase() == typeOrName.toLowerCase());
    } catch (e) {
      debugPrint('Error finding template by type or name: $e');
      return null;
    }
  }

  // Find a template by its ID with error handling
  WorkoutTemplate? findTemplateById(String id) {
    try {
      return templates.firstWhereOrNull((template) => template.id == id);
    } catch (e) {
      debugPrint('Error finding template by ID: $e');
      return null;
    }
  }
}
