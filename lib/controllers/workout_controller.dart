// ignore_for_file: avoid_print

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../models/workout_status.dart';
import '../models/workout_history_entry.dart';
import '../models/workout_template.dart';
import '../models/workout_data.dart';
import '../widgets/status/status_widgets.dart';
import 'package:vibration/vibration.dart';
import '../controllers/settings_controller.dart';
import '../services/sound_service.dart';
import '../controllers/templates_controller.dart';

class WorkoutController extends GetxController {
  // Observable variables
  final RxString currentDay = ''.obs;
  final RxString currentWorkout = ''.obs;
  final RxBool isRestDay = false.obs;
  final RxBool isWorkoutActive = false.obs;
  final RxList<Exercise> activeExercises = <Exercise>[].obs;
  final RxInt activeExerciseIndex = 0.obs;

  // Anti-spam protection
  final RxBool isProcessingAction = false.obs;
  final Map<String, DateTime> _lastActionTime = {};
  final Duration _minActionInterval = const Duration(milliseconds: 800);

  // Today's workout status
  final RxBool isTodayWorkoutCompleted = false.obs;
  final RxBool isTodayWorkoutSkipped = false.obs;

  // Save history of completed workouts
  final RxList<WorkoutHistoryEntry> workoutHistory =
      <WorkoutHistoryEntry>[].obs;

  // Workout schedule
  final RxMap<String, String> workoutSchedule = {
    'Monday': 'Pull',
    'Tuesday': 'Legs',
    'Wednesday': 'Rest',
    'Thursday': 'Push',
    'Friday': 'Pull',
    'Saturday': 'Legs',
    'Sunday': 'Rest',
  }.obs;

  // Workout start time (for duration tracking)
  DateTime? workoutStartTime;

  // Map to track ongoing operations per day
  final Map<String, bool> _dayUpdatesInProgress = {};

  // Add these variables to track workout progress
  final RxBool hasIncompleteWorkout = false.obs;
  final RxInt lastExerciseIndex = 0.obs;
  final RxMap<int, int> savedCompletedSets = <int, int>{}.obs;

  // Add these properties to the WorkoutController class
  final RxBool isResting = false.obs;
  final RxBool isSetRest =
      false.obs; // True for set rest, false for exercise rest
  final RxInt restTimeRemaining = 0.obs;
  final SettingsController _settings = Get.find<SettingsController>();
  final SoundService _soundService = Get.find<SoundService>();

  @override
  void onInit() {
    super.onInit();
    updateTodaysWorkout();

    // Check if we have a workout active on startup
    ever(isWorkoutActive, (_) {
      if (kDebugMode) {
        debugPrint('Workout active changed to: $isWorkoutActive');
      }
    });

    // Debug print when incomplete workout status changes
    ever(hasIncompleteWorkout, (value) {
      debugPrint('Has incomplete workout changed to: $value');
    });
  }

  // Anti-spam helper: Check if an action can be performed
  bool _canPerformAction(String actionKey) {
    if (isProcessingAction.value) return false;

    final now = DateTime.now();
    final lastTime = _lastActionTime[actionKey];

    if (lastTime != null) {
      final diff = now.difference(lastTime);
      if (diff < _minActionInterval) {
        return false;
      }
    }

    _lastActionTime[actionKey] = now;
    return true;
  }

  // Update today's workout information
  void updateTodaysWorkout() {
    if (!_canPerformAction('updateTodaysWorkout')) return;

    currentDay.value = getDayName(DateTime.now());
    currentWorkout.value = workoutSchedule[currentDay.value] ?? 'Rest';
    isRestDay.value = currentWorkout.value.toLowerCase() == 'rest';

    // Reset status first
    isTodayWorkoutCompleted.value = false;
    isTodayWorkoutSkipped.value = false;

    // Look through history to see if today's workout was already completed or skipped
    for (var workout in workoutHistory) {
      if (workout.isToday) {
        if (workout.status == WorkoutStatus.completed) {
          isTodayWorkoutCompleted.value = true;
        } else if (workout.status == WorkoutStatus.skipped) {
          isTodayWorkoutSkipped.value = true;
        }
      }
    }
  }

  // Get day name from DateTime
  String getDayName(DateTime date) {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    // DateTime weekday is 1-7 where 1 is Monday and 7 is Sunday
    return days[date.weekday - 1];
  }

  // Get color for workout type
  Color getWorkoutColor(String workout) {
    switch (workout.toLowerCase()) {
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

  // Get a list of exercise names for a workout type
  List<String> getExercisesForWorkout(String workoutType) {
    final exercises = WorkoutData.getExercisesForType(workoutType);
    return exercises.map((e) => e.name).toList();
  }

  // Start a workout
  void startWorkout() {
    // Check if we can perform this action
    if (!_canPerformAction('startWorkout')) return;

    isProcessingAction.value = true;
    debugPrint(
        'Starting workout. Has incomplete workout: ${hasIncompleteWorkout.value}');

    try {
      // Check if we have a saved workout to continue
      if (hasIncompleteWorkout.value) {
        _continueWorkoutInternal();
        return;
      }

      // Check if current workout is from a template
      final TemplatesController templatesController =
          Get.find<TemplatesController>();
      final template =
          templatesController.findTemplateByType(currentWorkout.value);

      // If the current workout is a template type and not a default type
      if (template != null &&
          !['Push', 'Pull', 'Legs', 'Rest', 'Custom']
              .contains(currentWorkout.value)) {
        // Start template workout
        templatesController.startTemplateWorkout(template.id);
        return;
      }

      // Start a new workout with default exercises
      // Clear previous active status
      isWorkoutActive.value = false;
      activeExercises.clear();

      // Set new exercise list based on workout type
      final exercises = WorkoutData.getExercisesForType(currentWorkout.value);
      activeExercises.assignAll(exercises);

      // Reset progress
      activeExerciseIndex.value = 0;

      // Reset all exercise sets
      for (var exercise in activeExercises) {
        exercise.completedSets.value = 0;
      }

      // Set workout as active
      isWorkoutActive.value = true;

      // Reset completed/skipped status (without showing toast)
      _silentResetTodaysWorkoutStatus();

      // Record start time
      workoutStartTime = DateTime.now();

      // Use the correct route name
      Get.toNamed('/active-workout');

      // Show toast AFTER navigation to ensure it's visible on the workout screen
      Future.delayed(const Duration(milliseconds: 300), () {
        StatusToast.showInfo('Starting ${currentWorkout.value} workout');
      });
    } catch (e) {
      debugPrint('Error in startWorkout: $e');
      StatusToast.showError('Failed to start workout: $e');

      // Reset active state if failed
      isWorkoutActive.value = false;

      // Clear saved state if it failed
      if (hasIncompleteWorkout.value) {
        _clearSavedWorkoutProgress();
      }
    } finally {
      // Small delay to prevent immediate re-enabling
      Future.delayed(const Duration(milliseconds: 800), () {
        isProcessingAction.value = false;
      });
    }
  }

  // Internal method to continue workout - called from startWorkout
  void _continueWorkoutInternal() {
    debugPrint('Continuing workout internally');

    try {
      // Ensure we have exercises loaded
      if (activeExercises.isEmpty) {
        final exercises = WorkoutData.getExercisesForType(currentWorkout.value);
        activeExercises.assignAll(exercises);
        debugPrint('Loaded ${activeExercises.length} exercises');
      }

      // Set workout as active
      isWorkoutActive.value = true;

      // Validate and restore exercise index
      if (lastExerciseIndex.value >= activeExercises.length) {
        activeExerciseIndex.value = 0;
        debugPrint('Reset exercise index - was out of bounds');
      } else {
        activeExerciseIndex.value = lastExerciseIndex.value;
        debugPrint('Restored exercise index to ${activeExerciseIndex.value}');
      }

      // Restore completed sets
      for (int i = 0; i < activeExercises.length; i++) {
        if (savedCompletedSets.containsKey(i)) {
          int savedSets = savedCompletedSets[i] ?? 0;
          activeExercises[i].completedSets.value = savedSets;
          debugPrint('Restored exercise $i sets: $savedSets');
        } else {
          activeExercises[i].completedSets.value = 0;
        }
      }

      // Navigate to workout screen
      Get.toNamed('/active-workout');

      // Show toast AFTER navigation
      Future.delayed(const Duration(milliseconds: 300), () {
        StatusToast.showInfo('Continuing ${currentWorkout.value} workout');
      });
    } catch (e) {
      debugPrint('Error in continueWorkout: $e');
      StatusToast.showError('Failed to continue workout: $e');

      // Reset state
      isWorkoutActive.value = false;
      _clearSavedWorkoutProgress();
    }
  }

  // Skip today's workout
  void skipWorkout() {
    if (!_canPerformAction('skipWorkout')) return;

    isProcessingAction.value = true;

    try {
      // Clear any saved workout progress
      _clearSavedWorkoutProgress();

      // Mark as skipped in history
      final todayEntry = WorkoutHistoryEntry(
        date: DateTime.now(),
        workoutType: currentWorkout.value,
        status: WorkoutStatus.skipped,
        exercises: null,
        totalSets: 0,
        completedSets: 0,
      );

      // Remove any existing entries for today
      workoutHistory.removeWhere((entry) => entry.isToday);

      // Add the new entry
      workoutHistory.add(todayEntry);

      // Update status
      isTodayWorkoutSkipped.value = true;
      isTodayWorkoutCompleted.value = false;

      StatusToast.showInfo('Workout skipped for today');
    } catch (e) {
      StatusToast.showError('Failed to skip workout: $e');
    } finally {
      Future.delayed(const Duration(milliseconds: 500), () {
        isProcessingAction.value = false;
      });
    }
  }

  // Complete workout
  void completeWorkout() {
    if (!_canPerformAction('completeWorkout')) return;

    isProcessingAction.value = true;

    try {
      // Create history entry with exercise data
      final todayEntry = WorkoutHistoryEntry(
        date: DateTime.now(),
        workoutType: currentWorkout.value,
        status: WorkoutStatus.completed,
        exercises:
            activeExercises.map((exercise) => exercise.toJson()).toList(),
        totalSets: activeExercises.fold(0, (sum, ex) => sum + ex.targetSets),
        completedSets:
            activeExercises.fold(0, (sum, ex) => sum + ex.completedSets.value),
        duration: workoutStartTime != null
            ? DateTime.now().difference(workoutStartTime!)
            : null,
      );

      // Remove any existing entries for today
      workoutHistory.removeWhere((entry) => entry.isToday);

      // Add the new entry
      workoutHistory.add(todayEntry);

      // Update status
      isTodayWorkoutCompleted.value = true;
      isTodayWorkoutSkipped.value = false;
      isWorkoutActive.value = false;

      // Clear saved progress since workout is completed
      _clearSavedWorkoutProgress();

      // Show completion toast
      StatusToast.showSuccess('Workout completed successfully!');

      // Return to dashboard
      Get.offAllNamed('/dashboard');
    } catch (e) {
      StatusToast.showError('Failed to complete workout: $e');
    } finally {
      Future.delayed(const Duration(milliseconds: 500), () {
        isProcessingAction.value = false;
      });
    }
  }

  // Save current workout progress
  void saveWorkoutProgress() {
    if (!_canPerformAction('saveWorkoutProgress')) return;

    isProcessingAction.value = true;

    try {
      // Only save if there's actually progress
      bool hasProgress = false;
      for (var exercise in activeExercises) {
        if (exercise.completedSets.value > 0) {
          hasProgress = true;
          break;
        }
      }

      if (!hasProgress) {
        // Nothing to save, just exit workout
        isWorkoutActive.value = false;
        _clearSavedWorkoutProgress();
        Get.offAllNamed('/dashboard');
        return;
      }

      // Save the current state
      hasIncompleteWorkout.value = true;
      lastExerciseIndex.value = activeExerciseIndex.value;

      // Save completed sets
      savedCompletedSets.clear();
      for (int i = 0; i < activeExercises.length; i++) {
        savedCompletedSets[i] = activeExercises[i].completedSets.value;
      }

      debugPrint(
          'Saved workout progress: index=${lastExerciseIndex.value}, sets=$savedCompletedSets');

      // Mark as not active when leaving
      isWorkoutActive.value = false;

      Get.offAllNamed('/dashboard');
    } catch (e) {
      StatusToast.showError('Failed to save workout: $e');
    } finally {
      Future.delayed(const Duration(milliseconds: 500), () {
        isProcessingAction.value = false;
      });
    }
  }

  // Clear saved workout progress
  void _clearSavedWorkoutProgress() {
    debugPrint('Clearing saved workout progress');
    hasIncompleteWorkout.value = false;
    lastExerciseIndex.value = 0;
    savedCompletedSets.clear();
  }

  // Change today's workout type
  void changeTodaysWorkout(String newWorkoutType) {
    if (!_canPerformAction('changeTodaysWorkout')) return;

    isProcessingAction.value = true;

    try {
      // Clear any saved progress if changing today's workout
      _clearSavedWorkoutProgress();

      // Update workout schedule for today
      workoutSchedule[currentDay.value] = newWorkoutType;

      // Update current workout
      currentWorkout.value = newWorkoutType;
      isRestDay.value = newWorkoutType.toLowerCase() == 'rest';

      // Reset workout status
      resetTodaysWorkoutStatus();

      StatusToast.showSuccess('Today\'s workout updated to $newWorkoutType');
    } catch (e) {
      StatusToast.showError('Failed to update workout: $e');
    } finally {
      Future.delayed(const Duration(milliseconds: 500), () {
        isProcessingAction.value = false;
      });
    }
  }

  // Reset today's workout status
  void resetTodaysWorkoutStatus() {
    if (!_canPerformAction('resetTodaysWorkoutStatus')) return;

    isProcessingAction.value = true;

    try {
      // Remove any existing entries for today
      workoutHistory.removeWhere((entry) => entry.isToday);

      // Reset status flags
      isTodayWorkoutCompleted.value = false;
      isTodayWorkoutSkipped.value = false;

      // Clear any saved progress
      _clearSavedWorkoutProgress();

      updateTodaysWorkout();
    } catch (e) {
      StatusToast.showError('Failed to reset status: $e');
    } finally {
      Future.delayed(const Duration(milliseconds: 500), () {
        isProcessingAction.value = false;
      });
    }
  }

  // Silent reset without toast message
  void _silentResetTodaysWorkoutStatus() {
    workoutHistory.removeWhere((entry) => entry.isToday);
    isTodayWorkoutCompleted.value = false;
    isTodayWorkoutSkipped.value = false;
  }

  // Update workout for a specific day
  void updateWorkoutSchedule(String day, String workoutType) {
    // Check for day-specific processing
    if (_dayUpdatesInProgress[day] == true) {
      return; // Already processing this day
    }

    // Global processing check
    if (isProcessingAction.value) {
      return; // Something else is processing
    }

    // Set both flags
    _dayUpdatesInProgress[day] = true;
    isProcessingAction.value = true;

    try {
      // Only update if the workout type has actually changed
      if (workoutSchedule[day] != workoutType) {
        workoutSchedule[day] = workoutType;

        // If updating today, also update current workout
        if (day == currentDay.value) {
          currentWorkout.value = workoutType;
          isRestDay.value = workoutType.toLowerCase() == 'rest';
          _silentResetTodaysWorkoutStatus();
          _clearSavedWorkoutProgress();
        }

        StatusToast.showSuccess('$day updated to $workoutType');
      }
    } catch (e) {
      StatusToast.showError('Failed to update schedule: $e');
    } finally {
      // Use a longer delay to ensure UI updates complete
      Future.delayed(const Duration(milliseconds: 800), () {
        _dayUpdatesInProgress[day] = false;
        isProcessingAction.value = false;
      });
    }
  }

  // Record completed set for an exercise
  void completeSet(int exerciseIndex) {
    // Anti-spam protection
    if (!_canPerformAction('completeSet_$exerciseIndex')) return;

    isProcessingAction.value = true;

    try {
      if (exerciseIndex >= 0 && exerciseIndex < activeExercises.length) {
        Exercise exercise = activeExercises[exerciseIndex];

        // Only increment if we haven't reached target sets
        if (exercise.completedSets.value < exercise.targetSets) {
          exercise.completedSets.value++;

          // Start rest timer if not the last set
          if (exercise.completedSets.value < exercise.targetSets) {
            // Rest between sets
            startRestTimer(isSetRest: true);
          }
          // If we've completed all sets for this exercise, move to the next one
          else if (exercise.completedSets.value >= exercise.targetSets) {
            if (activeExerciseIndex.value < activeExercises.length - 1) {
              // Start rest timer between exercises
              startRestTimer(isSetRest: false);
            } else {
              // All exercises completed
              StatusToast.showSuccess(
                  'All exercises completed! You can finish the workout.');
            }
          }
        }
      } else {
        StatusToast.showError('Invalid exercise index: $exerciseIndex');
      }
    } catch (e) {
      StatusToast.showError('Failed to record set: $e');
    } finally {
      // Short delay to prevent rapid clicking
      Future.delayed(const Duration(milliseconds: 500), () {
        isProcessingAction.value = false;
      });
    }
  }

  // Remove completed set
  void removeSet(int exerciseIndex) {
    if (!_canPerformAction('removeSet_$exerciseIndex')) return;

    isProcessingAction.value = true;

    try {
      if (exerciseIndex >= 0 && exerciseIndex < activeExercises.length) {
        Exercise exercise = activeExercises[exerciseIndex];
        if (exercise.completedSets.value > 0) {
          exercise.completedSets.value--;
        }
      }
    } catch (e) {
      StatusToast.showError('Failed to remove set: $e');
    } finally {
      Future.delayed(const Duration(milliseconds: 500), () {
        isProcessingAction.value = false;
      });
    }
  }

  // Update reps for an exercise
  void updateReps(int exerciseIndex, int reps) {
    if (exerciseIndex >= 0 && exerciseIndex < activeExercises.length) {
      Exercise exercise = activeExercises[exerciseIndex];
      exercise.currentReps.value = reps;
    }
  }

  // Check if all exercises have completed target sets
  bool isWorkoutComplete() {
    if (activeExercises.isEmpty) return false;

    for (var exercise in activeExercises) {
      if (exercise.completedSets.value < exercise.targetSets) {
        return false;
      }
    }

    return true;
  }

  /// Get all available workout types (default + custom)
  List<String> get availableWorkoutTypes {
    final workoutOptions = customWorkoutNames.toList();

    // Add 'Rest' if not already in the list
    if (!workoutOptions.contains('Rest')) {
      workoutOptions.add('Rest');
    }

    return workoutOptions;
  }

  /// Get list of custom workout names from templates
  List<String> get customWorkoutNames {
    try {
      // Get the templates controller
      final TemplatesController templatesController =
          Get.find<TemplatesController>();

      // Extract unique template types
      final customTypes = templatesController.templates
          .map((template) => template.type)
          .toSet()
          .toList();

      return customTypes;
    } catch (e) {
      // If templates controller not found or other error
      debugPrint('Error getting custom workout names: $e');
      return [];
    }
  }

  // Add this method to start a rest timer
  void startRestTimer({required bool isSetRest}) {
    this.isSetRest.value = isSetRest;

    // Get the appropriate rest duration from settings
    restTimeRemaining.value = isSetRest
        ? _settings.setRestDuration.value
        : _settings.workoutRestDuration.value;

    isResting.value = true;
  }

  void skipRestTimer() {
    if (isResting.value) {
      isResting.value = false;
      onRestTimerComplete();
    }
  }

  void decrementRestTimer() {
    if (restTimeRemaining.value > 0) {
      restTimeRemaining.value--;

      // Play sound alerts for last 3 seconds
      if (restTimeRemaining.value <= 3 && restTimeRemaining.value > 0) {
        if (_settings.enableSoundAlerts.value) {
          _soundService.playBeep();
        }
      }

      // Timer finished
      if (restTimeRemaining.value == 0) {
        onRestTimerComplete();
      }
    }
  }

  void onRestTimerComplete() {
    // Play completion sound
    if (_settings.enableSoundAlerts.value) {
      _soundService.playTimerComplete();
    }

    // Vibrate device if enabled
    if (_settings.enableVibration.value) {
      Vibration.vibrate(pattern: [0, 100, 100, 100, 100, 100]);
    }

    isResting.value = false;

    // If it was an exercise rest (not set rest), advance to the next exercise
    if (!isSetRest.value) {
      // Only advance if not on the last exercise
      if (activeExerciseIndex.value < activeExercises.length - 1) {
        activeExerciseIndex.value++;
      }
    }
  }

  // Start a workout from a template
  void startTemplateWorkout(WorkoutTemplate template) {
    // Check if we can perform this action
    if (!_canPerformAction('startTemplateWorkout')) return;

    isProcessingAction.value = true;
    try {
      // Clear previous active status
      isWorkoutActive.value = false;
      activeExercises.clear();

      // Convert template exercises to workout exercises
      final List<Exercise> exercises = template.exercises
          .map((e) => Exercise(
                name: e.name,
                workoutType: template.type,
                primaryMuscle:
                    template.type, // Default primary muscle to template type
                secondaryMuscles: [], // Empty secondary muscles
                equipment: 'Unknown', // Default equipment
                targetSets: e.targetSets,
                targetReps: e.targetReps,
                notes: e.notes,
              ))
          .toList();

      activeExercises.assignAll(exercises);

      // Set workout type from template name instead of type
      currentWorkout.value = template.name;

      // Reset progress
      activeExerciseIndex.value = 0;

      // Reset all exercise sets
      for (var exercise in activeExercises) {
        exercise.completedSets.value = 0;
      }

      // Set workout as active
      isWorkoutActive.value = true;

      // Reset completed/skipped status (without showing toast)
      _silentResetTodaysWorkoutStatus();

      // Record start time
      workoutStartTime = DateTime.now();

      // Navigate to workout screen
      Get.toNamed('/active-workout');

      // Show toast AFTER navigation
      Future.delayed(const Duration(milliseconds: 300), () {
        StatusToast.showInfo('Starting ${template.name} workout');
      });
    } catch (e) {
      debugPrint('Error in startTemplateWorkout: $e');
      StatusToast.showError('Failed to start template workout: $e');

      // Reset active state if failed
      isWorkoutActive.value = false;
    } finally {
      // Small delay to prevent immediate re-enabling
      Future.delayed(const Duration(milliseconds: 800), () {
        isProcessingAction.value = false;
      });
    }
  }

  // Start a custom workout with provided exercises
  void startCustomWorkout({
    required String workoutName,
    required List<Exercise> exercises,
  }) {
    // Check if we can perform this action
    if (!_canPerformAction('startCustomWorkout')) return;

    isProcessingAction.value = true;
    try {
      // Clear previous active status
      isWorkoutActive.value = false;
      activeExercises.clear();

      // Assign exercises
      activeExercises.assignAll(exercises);

      // Set workout type to custom
      currentWorkout.value = 'Custom';

      // Reset progress
      activeExerciseIndex.value = 0;

      // Reset all exercise sets
      for (var exercise in activeExercises) {
        exercise.completedSets.value = 0;
      }

      // Set workout as active
      isWorkoutActive.value = true;

      // Reset completed/skipped status (without showing toast)
      _silentResetTodaysWorkoutStatus();

      // Record start time
      workoutStartTime = DateTime.now();

      // Navigate to workout screen
      Get.toNamed('/active-workout');

      // Show toast AFTER navigation
      Future.delayed(const Duration(milliseconds: 300), () {
        StatusToast.showInfo('Starting $workoutName workout');
      });
    } catch (e) {
      debugPrint('Error in startCustomWorkout: $e');
      StatusToast.showError('Failed to start custom workout: $e');

      // Reset active state if failed
      isWorkoutActive.value = false;
    } finally {
      // Small delay to prevent immediate re-enabling
      Future.delayed(const Duration(milliseconds: 800), () {
        isProcessingAction.value = false;
      });
    }
  }

  // Add a custom workout to the schedule
  void addCustomWorkoutType(String workoutName) {
    // Update the current workout type if needed
    if (currentWorkout.isEmpty) {
      currentWorkout.value = workoutName;
    }

    // Option to replace a workout in the schedule
    // Show dialog to ask which day to replace
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Update Workout Schedule',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Which day would you like to replace with this workout?',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: workoutSchedule.length,
                  itemBuilder: (context, index) {
                    final day = workoutSchedule.keys.elementAt(index);
                    final currentType = workoutSchedule[day];

                    return ListTile(
                      title: Text(day),
                      subtitle: Text('Current: $currentType'),
                      onTap: () {
                        // Update the schedule
                        workoutSchedule[day] = workoutName;
                        Get.back(); // Close dialog

                        // If today is the selected day, update current workout
                        if (day == currentDay.value) {
                          currentWorkout.value = workoutName;
                          isRestDay.value = false;
                        }

                        StatusToast.showSuccess('Updated $day to $workoutName');
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
