import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../controllers/templates_controller.dart';
import '../controllers/workout_controller.dart';
import '../models/workout_template.dart';

/// Controller for the workouts screen
class WorkoutsController extends GetxController {
  // References to other controllers
  final TemplatesController _templatesController =
      Get.find<TemplatesController>();
  final WorkoutController _workoutController = Get.find<WorkoutController>();

  // Observable list of templates filtered (no Rest workouts)
  final RxList<WorkoutTemplate> filteredTemplates = <WorkoutTemplate>[].obs;

  // Search term for filtering workouts
  final RxString searchTerm = ''.obs;

  // Loading state
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Listen for changes in templates list
    ever(_templatesController.templates, (_) => _updateFilteredTemplates());

    // Listen for search term changes
    debounce(
      searchTerm,
      (_) => _updateFilteredTemplates(),
      time: const Duration(milliseconds: 300),
    );

    // Initial load
    _updateFilteredTemplates();
  }

  /// Update the filtered templates list
  void _updateFilteredTemplates() {
    isLoading.value = true;

    try {
      if (searchTerm.value.isEmpty) {
        // Just filter out Rest workouts
        filteredTemplates.assignAll(_templatesController.templates
            .where((template) => template.type.toLowerCase() != 'rest')
            .toList());
      } else {
        // Filter by search term and not Rest
        final term = searchTerm.value.toLowerCase();
        filteredTemplates.assignAll(_templatesController.templates
            .where((template) =>
                template.type.toLowerCase() != 'rest' &&
                (template.name.toLowerCase().contains(term) ||
                    template.description.toLowerCase().contains(term) ||
                    template.type.toLowerCase().contains(term) ||
                    template.exercises
                        .any((e) => e.name.toLowerCase().contains(term))))
            .toList());
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh templates from storage
  Future<void> refreshTemplates() async {
    isLoading.value = true;
    try {
      await _templatesController.loadTemplates();
      // Filtered templates will update automatically through the ever() worker
    } finally {
      isLoading.value = false;
    }
  }

  /// Start a template workout
  void startWorkout(String templateId) {
    _templatesController.startTemplateWorkout(templateId);
  }

  /// Edit a template
  void editTemplate(WorkoutTemplate template) {
    _templatesController.setEditingTemplate(template);
    Get.toNamed('/edit-template');
  }

  /// Delete a template
  Future<bool> deleteTemplate(String templateId) async {
    isLoading.value = true;
    try {
      _templatesController.deleteTemplate(templateId);
      return true;
    } catch (e) {
      debugPrint('Error deleting template: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Get color for a workout type
  Color getWorkoutColor(String workoutType) {
    return _workoutController.getWorkoutColor(workoutType);
  }

  /// Search workouts
  void search(String term) {
    searchTerm.value = term;
  }

  /// Clear search
  void clearSearch() {
    searchTerm.value = '';
  }
}
