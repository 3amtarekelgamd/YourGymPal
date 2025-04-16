// ignore_for_file: depend_on_referenced_packages

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/workout_template.dart';
import '../widgets/status/status_widgets.dart';
import '../services/image_service.dart';
import 'workout_controller.dart';
import 'package:flutter/foundation.dart';

class TemplatesController extends GetxController {
  final RxList<WorkoutTemplate> templates = <WorkoutTemplate>[].obs;
  final Rx<WorkoutTemplate?> editingTemplate = Rx<WorkoutTemplate?>(null);
  late final ImageService _imageService;

  @override
  void onInit() {
    super.onInit();
    _imageService = Get.find<ImageService>();
    loadTemplates();
  }

  Future<void> loadTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final templatesJson = prefs.getStringList('workout_templates') ?? [];

      final loadedTemplates = templatesJson
          .map((json) => WorkoutTemplate.fromJson(jsonDecode(json)))
          .toList();

      templates.assignAll(loadedTemplates);

      // Remove default templates creation
      // if (templates.isEmpty) {
      //   _createDefaultTemplates();
      // }
    } catch (e) {
      // Use debugPrint instead of toast for errors
      debugPrint('Failed to load templates: $e');
    }
  }

  Future<void> saveTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final templatesJson =
          templates.map((template) => jsonEncode(template.toJson())).toList();

      await prefs.setStringList('workout_templates', templatesJson);
    } catch (e) {
      debugPrint('Failed to save templates: $e');
    }
  }

  void addTemplate(WorkoutTemplate template) {
    templates.add(template);
    saveTemplates();
    // Only show toast if needed, not when navigating away
  }

  void updateTemplate(WorkoutTemplate template) {
    final index = templates.indexWhere((t) => t.id == template.id);
    if (index >= 0) {
      templates[index] = template;
      saveTemplates();
      // Only show toast on same screen
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
      saveTemplates();
      // Show toast for successful deletion
      StatusToast.showSuccess('Template deleted');
    }
  }

  void setEditingTemplate(WorkoutTemplate? template) {
    editingTemplate.value = template;
  }

  void startTemplateWorkout(String templateId) {
    final template = templates.firstWhereOrNull((t) => t.id == templateId);
    if (template == null) {
      StatusToast.showError('Template not found');
      return;
    }

    final workoutController = Get.find<WorkoutController>();
    workoutController.startTemplateWorkout(template);
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

  // Find a template by its type (workout name)
  WorkoutTemplate? findTemplateByType(String type) {
    return templates.firstWhereOrNull((template) => template.type == type);
  }
}
