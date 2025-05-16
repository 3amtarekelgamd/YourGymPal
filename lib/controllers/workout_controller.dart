// ignore_for_file: avoid_print

import 'dart:async';
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
import 'package:get_storage/get_storage.dart';
import '../screens/active_workout_screen.dart';

class WorkoutController extends GetxController {
  // Storage keys
  static const String kWorkoutSchedule = 'workout_schedule';
  static const String kWorkoutHistory = 'workout_history';
  static const String kHasIncompleteWorkout = 'has_incomplete_workout';
  static const String kLastExerciseIndex = 'last_exercise_index';
  static const String kSavedCompletedSets = 'saved_completed_sets';
  static const String kCurrentWorkout = 'current_workout';
  static const String kWorkoutStartTime = 'workout_start_time';

  // GetStorage instance
  final GetStorage _storage = GetStorage();

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

  // Default workout schedule to restore from
  final Map<String, String> defaultWorkoutSchedule = {
    'Monday': 'Pull',
    'Tuesday': 'Legs',
    'Wednesday': 'Rest',
    'Thursday': 'Push',
    'Friday': 'Pull',
    'Saturday': 'Legs',
    'Sunday': 'Rest',
  };

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
    
    // Load data from GetStorage
    _loadDataFromStorage();
    
    updateTodaysWorkout();

    // Check if we have a workout active on startup
    ever(isWorkoutActive, (_) {
      debugPrint('Workout active changed to: $isWorkoutActive');
    });

    // Debug print when incomplete workout status changes
    ever(hasIncompleteWorkout, (value) {
      debugPrint('Has incomplete workout changed to: $value');
      // Save the state to storage when it changes
      _storage.write(kHasIncompleteWorkout, value);
    });
    
    // Save workout schedule when it changes
    ever(workoutSchedule, (_) {
      _saveWorkoutSchedule();
    });
    
    // Save workout history when it changes
    ever(workoutHistory, (_) {
      _saveWorkoutHistory();
    });
    
    // Save completed sets when they change
    ever(savedCompletedSets, (_) {
      _storage.write(kSavedCompletedSets, savedCompletedSets.map((key, value) => 
        MapEntry(key.toString(), value)));
    });
    
    // Save last exercise index when it changes
    ever(lastExerciseIndex, (value) {
      _storage.write(kLastExerciseIndex, value);
    });
    
    // Save current workout when it changes
    ever(currentWorkout, (value) {
      _storage.write(kCurrentWorkout, value);
    });
  }
  
  // Load data from GetStorage
  void _loadDataFromStorage() {
    try {
      // Load workout schedule
      final savedSchedule = _storage.read<Map<dynamic, dynamic>>(kWorkoutSchedule);
      if (savedSchedule != null) {
        final Map<String, String> typedSchedule = {};
        savedSchedule.forEach((key, value) {
          if (key is String && value is String) {
            typedSchedule[key] = value;
          }
        });
        if (typedSchedule.isNotEmpty) {
          workoutSchedule.assignAll(typedSchedule);
          debugPrint('Loaded workout schedule from storage');
        }
      }
      
      // Load workout history
      final savedHistory = _storage.read<List<dynamic>>(kWorkoutHistory);
      if (savedHistory != null) {
        final loadedHistory = savedHistory
            .map((item) => WorkoutHistoryEntry.fromJson(item))
            .toList();
        workoutHistory.assignAll(loadedHistory);
        debugPrint('Loaded ${loadedHistory.length} workout history entries');
      }
      
      // Load incomplete workout data
      hasIncompleteWorkout.value = _storage.read<bool>(kHasIncompleteWorkout) ?? false;
      lastExerciseIndex.value = _storage.read<int>(kLastExerciseIndex) ?? 0;
      
      final savedSets = _storage.read<Map<dynamic, dynamic>>(kSavedCompletedSets);
      if (savedSets != null) {
        final Map<int, int> typedSets = {};
        savedSets.forEach((key, value) {
          if (value is int) {
            typedSets[int.tryParse(key.toString()) ?? 0] = value;
          }
        });
        savedCompletedSets.assignAll(typedSets);
        debugPrint('Loaded saved sets: $typedSets');
      }
      
      // Load current workout if available
      final savedWorkout = _storage.read<String>(kCurrentWorkout);
      if (savedWorkout != null && savedWorkout.isNotEmpty) {
        currentWorkout.value = savedWorkout;
        debugPrint('Loaded current workout: $savedWorkout');
      }
      
      // Load workout start time if available
      final savedStartTime = _storage.read<String>(kWorkoutStartTime);
      if (savedStartTime != null) {
        try {
          workoutStartTime = DateTime.parse(savedStartTime);
          debugPrint('Loaded workout start time: $workoutStartTime');
        } catch (e) {
          debugPrint('Error parsing workout start time: $e');
          workoutStartTime = null;
        }
      }
    } catch (e) {
      debugPrint('Error loading data from storage: $e');
    }
  }
  
  // Save workout schedule to storage
  void _saveWorkoutSchedule() {
    try {
      _storage.write(kWorkoutSchedule, workoutSchedule);
      debugPrint('Saved workout schedule to storage');
    } catch (e) {
      debugPrint('Error saving workout schedule: $e');
    }
  }
  
  // Save workout history to storage
  void _saveWorkoutHistory() {
    try {
      final historyJson = workoutHistory.map((entry) => entry.toJson()).toList();
      _storage.write(kWorkoutHistory, historyJson);
      debugPrint('Saved workout history to storage');
    } catch (e) {
      debugPrint('Error saving workout history: $e');
    }
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

    final DateTime now = DateTime.now();
    currentDay.value = getDayName(now);
    final oldWorkout = currentWorkout.value;
    currentWorkout.value = workoutSchedule[currentDay.value] ?? 'Rest';
    
    debugPrint('WorkoutController.updateTodaysWorkout: Current date: ${now.toString()}');
    debugPrint('WorkoutController.updateTodaysWorkout: Current day: ${currentDay.value}');
    debugPrint('WorkoutController.updateTodaysWorkout: Current workout: ${currentWorkout.value} (was $oldWorkout)');
    
    // Check each day in schedule
    workoutSchedule.forEach((day, workout) {
      debugPrint('WorkoutController.updateTodaysWorkout: Schedule - $day: $workout');
    });
    
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
    
    // Pre-check if we have exercises for the current workout
    final preCheckExercises = WorkoutData.getExercisesForType(currentWorkout.value);
    if (preCheckExercises.isEmpty) {
      debugPrint('WorkoutController.updateTodaysWorkout: WARNING - No exercises found for ${currentWorkout.value}');
      
      // Try with lowercase to fix case sensitivity issues
      final normalizedWorkoutType = currentWorkout.value.toLowerCase();
      final fallbackExercises = WorkoutData.getExercisesForType(normalizedWorkoutType);
      if (fallbackExercises.isNotEmpty) {
        debugPrint('WorkoutController.updateTodaysWorkout: But found ${fallbackExercises.length} exercises with normalized type');
      }
    } else {
      debugPrint('WorkoutController.updateTodaysWorkout: Found ${preCheckExercises.length} exercises for ${currentWorkout.value}');
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

  // Helper method for consistent navigation to active workout
  void _navigateToActiveWorkout() {
    try {
      // Make sure isWorkoutActive is true before navigating
      if (!isWorkoutActive.value) {
        debugPrint('WorkoutController: Cannot navigate to active workout because isWorkoutActive is false');
        return;
      }
      
      if (activeExercises.isEmpty) {
        debugPrint('WorkoutController: Cannot navigate to active workout because activeExercises is empty');
        StatusToast.showError('No exercises available for this workout');
        isWorkoutActive.value = false;
        return;
      }
      
      // Check if we're already on the active workout screen
      if (Get.currentRoute == '/active-workout') {
        debugPrint('WorkoutController: Already on active workout screen');
        return;
      }
      
      debugPrint('WorkoutController: Navigating to active workout screen');
      
      // Capture current route for better debugging
      final String currentRoute = Get.currentRoute;
      debugPrint('WorkoutController: Current route before navigation: $currentRoute');
      
      // Try different navigation approaches based on current context
      if (currentRoute == '/dashboard' || currentRoute == '/') {
        // If on dashboard, use offAndToNamed for smoother navigation
        debugPrint('WorkoutController: Using offAndToNamed for navigation from dashboard');
        Get.offAndToNamed('/active-workout');
      } else {
        // For other routes, try regular navigation
        debugPrint('WorkoutController: Using toNamed for navigation from non-dashboard');
        Get.toNamed('/active-workout');
      }
      
      // Add a fallback check after short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (isWorkoutActive.value && Get.currentRoute != '/active-workout') {
          debugPrint('WorkoutController: Navigation may have failed, using fallback navigation');
          Get.offAll(() => const ActiveWorkoutScreen());
        }
      });
    } catch (e) {
      debugPrint('WorkoutController: Exception in _navigateToActiveWorkout: $e');
      StatusToast.showError('Navigation error: $e');
      _handleNavigationError();
    }
  }
  
  // Handle navigation errors with a fallback strategy
  void _handleNavigationError() {
    // Try using a different navigation approach as fallback
    try {
      debugPrint('WorkoutController: Trying fallback navigation');
      
      // First ensure we return to dashboard
      Get.offAllNamed('/dashboard');
      
      // Then after a delay try to go to active workout
      Future.delayed(const Duration(milliseconds: 500), () {
        if (isWorkoutActive.value && activeExercises.isNotEmpty) {
          debugPrint('WorkoutController: Fallback navigation to active workout');
          Get.toNamed('/active-workout');
          StatusToast.showInfo('Starting workout...');
        }
      });
    } catch (e) {
      debugPrint('WorkoutController: Fallback navigation also failed: $e');
      StatusToast.showError('Could not open workout screen. Please try again.');
      isWorkoutActive.value = false;
    }
  }

  // Start a workout
  void startWorkout() {
    // Check if we can perform this action
    if (!_canPerformAction('startWorkout')) {
      debugPrint('WorkoutController: Cannot start workout due to anti-spam protection');
      StatusToast.showInfo('Please wait a moment before trying again');
      return;
    }

    isProcessingAction.value = true;
    debugPrint(
        'WorkoutController.startWorkout(): Starting workout. Current workout: ${currentWorkout.value}, Day: ${currentDay.value}');

    try {
      // Check if we have a saved workout to continue
      if (hasIncompleteWorkout.value) {
        debugPrint('WorkoutController.startWorkout(): Continuing incomplete workout');
        _continueWorkoutInternal();
        return;
      }

      // Fix for case insensitivity issues
      final normalizedWorkoutType = currentWorkout.value.toLowerCase();
      debugPrint('WorkoutController.startWorkout(): Normalized workout type: $normalizedWorkoutType');

      // Check if current workout is from a template - improved template matching
      final TemplatesController templatesController = Get.find<TemplatesController>();
      
      // First try exact match by name
      var template = templatesController.templates.firstWhereOrNull(
        (t) => t.name.toLowerCase() == currentWorkout.value.toLowerCase()
      );
      
      // If no match by name, try match by type
      if (template == null) {
        template = templatesController.templates.firstWhereOrNull(
          (t) => t.type.toLowerCase() == currentWorkout.value.toLowerCase()
        );
      }
      
      // Log whether we found a template
      if (template != null) {
        debugPrint('WorkoutController.startWorkout(): Found matching template: ${template.name}');
      } else {
        debugPrint('WorkoutController.startWorkout(): No matching template found for: ${currentWorkout.value}');
      }

      // If the current workout is a template type or matches a template name
      if (template != null) {
        try {
          // Start template workout with detailed error trapping
          debugPrint('WorkoutController.startWorkout(): Attempting to start template workout with ID: ${template.id}');
          bool success = templatesController.startTemplateWorkout(template.id);
          debugPrint('WorkoutController.startWorkout(): Template workout start result: $success');
          
          // If template start succeeded, return early (success path)
          if (success) {
            return;
          }
        } catch (e) {
          // Catch any errors in the template startup process
          debugPrint('WorkoutController.startWorkout(): Error starting template workout: $e');
        }
        
        // If we get here, template start failed - log it and continue with default workout
        debugPrint('WorkoutController.startWorkout(): Template start failed, falling back to default workout');
      }
      
      // If 'Custom' is set but didn't match any template, return with message
      if (normalizedWorkoutType == 'custom') {
        debugPrint('WorkoutController.startWorkout(): Custom workout with no template');
        StatusToast.showError('No exercises found for this custom workout');
        isProcessingAction.value = false;
        return;
      }

      // Start a new workout with default exercises
      debugPrint('WorkoutController.startWorkout(): Starting default workout for type: ${currentWorkout.value}');
      
      // Clear previous active status
      isWorkoutActive.value = false;
      activeExercises.clear();

      // Set new exercise list based on workout type
      final exercises = WorkoutData.getExercisesForType(currentWorkout.value);
      
      debugPrint('WorkoutController.startWorkout(): Found ${exercises.length} exercises for ${currentWorkout.value}');
      
      if (exercises.isEmpty) {
        debugPrint('WorkoutController.startWorkout(): No exercises found for type: ${currentWorkout.value}');
        // Try with normalized workout type as fallback
        final fallbackExercises = WorkoutData.getExercisesForType(normalizedWorkoutType);
        
        if (fallbackExercises.isEmpty) {
          // Allow custom workouts to start even with no exercises
          debugPrint('WorkoutController.startWorkout(): Starting empty custom workout: ${currentWorkout.value}');
          
          // Set workout as active anyway
          isWorkoutActive.value = true;
          
          // Reset completed/skipped status
          _silentResetTodaysWorkoutStatus();
          
          // Record start time
          _recordWorkoutStartTime();
          
          // Navigate to active workout screen
          _navigateToActiveWorkout();
          
          // Add direct fallback navigation after a short delay
          Future.delayed(const Duration(milliseconds: 800), () {
            if (isWorkoutActive.value && 
                Get.currentRoute != '/active-workout') {
              debugPrint('WorkoutController.startWorkout(): Main navigation may have failed, using direct fallback');
              // Get.offAll() is more reliable than named routes when navigation is stuck
              Get.offAll(() => const ActiveWorkoutScreen());
            }
          });
          
          // Show toast AFTER navigation
          Future.delayed(const Duration(milliseconds: 300), () {
            StatusToast.showInfo('Starting ${currentWorkout.value} workout');
          });
          
          return;
        } else {
          debugPrint('WorkoutController.startWorkout(): Found ${fallbackExercises.length} exercises with normalized type');
          activeExercises.assignAll(fallbackExercises);
        }
      } else {
        activeExercises.assignAll(exercises);
      }
      
      debugPrint('WorkoutController.startWorkout(): Loaded ${activeExercises.length} exercises');

      // Reset progress
      activeExerciseIndex.value = 0;

      // Reset all exercise sets
      for (var exercise in activeExercises) {
        exercise.completedSets.value = 0;
      }

      // Set workout as active
      isWorkoutActive.value = true;
      debugPrint('WorkoutController.startWorkout(): Set workout active to true');

      // Reset completed/skipped status (without showing toast)
      _silentResetTodaysWorkoutStatus();

      // Record start time with storage
      _recordWorkoutStartTime();

      // Debug info before navigation
      debugPrint('WorkoutController.startWorkout(): Active workout: ${isWorkoutActive.value}, Exercises: ${activeExercises.length}');
      
      // Use the navigation helper
      _navigateToActiveWorkout();

      // Add direct fallback navigation after a short delay in case main navigation fails
      Future.delayed(const Duration(milliseconds: 800), () {
        if (isWorkoutActive.value && 
            activeExercises.isNotEmpty &&
            Get.currentRoute != '/active-workout') {
          debugPrint('WorkoutController.startWorkout(): Main navigation may have failed, using direct fallback');
          // Get.offAll() is more reliable than named routes when navigation is stuck
          Get.offAll(() => const ActiveWorkoutScreen());
        }
      });

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

      // Navigate to workout screen using our helper
      _navigateToActiveWorkout();

      // Add direct fallback navigation after a short delay in case main navigation fails
      Future.delayed(const Duration(milliseconds: 800), () {
        if (isWorkoutActive.value && 
            activeExercises.isNotEmpty &&
            Get.currentRoute != '/active-workout') {
          debugPrint('WorkoutController._continueWorkoutInternal(): Main navigation may have failed, using direct fallback');
          // Get.offAll() is more reliable than named routes when navigation is stuck
          Get.offAll(() => const ActiveWorkoutScreen());
        }
      });

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

  // Save current workout progress with storage updates
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

      // Save completed sets - the observers will handle storage updates
      savedCompletedSets.clear();
      for (int i = 0; i < activeExercises.length; i++) {
        savedCompletedSets[i] = activeExercises[i].completedSets.value;
      }

      // This will be saved via the observer
      debugPrint('Saved workout progress: index=${lastExerciseIndex.value}, sets=$savedCompletedSets');

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

  // Clear saved workout progress with storage updates
  void _clearSavedWorkoutProgress() {
    debugPrint('Clearing saved workout progress');
    hasIncompleteWorkout.value = false;
    lastExerciseIndex.value = 0;
    savedCompletedSets.clear();
    
    // Clear from storage
    _storage.remove(kHasIncompleteWorkout);
    _storage.remove(kLastExerciseIndex);
    _storage.remove(kSavedCompletedSets);
    _storage.remove(kWorkoutStartTime);
  }

  // Helper method to update active exercises for a new workout type
  void _updateActiveExercises(String workoutType) {
    if (!isWorkoutActive.value) return;
    
    // Get exercises for the new workout type
    final newExercises = WorkoutData.getExercisesForType(workoutType);
    
    // If we found exercises, update the active exercises list
    if (newExercises.isNotEmpty) {
      debugPrint('Updating active exercises for new workout type: $workoutType');
      activeExercises.clear();
      activeExercises.assignAll(newExercises);
      
      // Reset exercise index and completed sets
      activeExerciseIndex.value = 0;
      for (var exercise in activeExercises) {
        exercise.completedSets.value = 0;
      }
    } else {
      // Try with normalized workout type as fallback
      final normalizedWorkoutType = workoutType.toLowerCase();
      final fallbackExercises = WorkoutData.getExercisesForType(normalizedWorkoutType);
      
      if (fallbackExercises.isNotEmpty) {
        debugPrint('Using fallback exercises with normalized type: $normalizedWorkoutType');
        activeExercises.clear();
        activeExercises.assignAll(fallbackExercises);
        
        // Reset exercise index and completed sets
        activeExerciseIndex.value = 0;
        for (var exercise in activeExercises) {
          exercise.completedSets.value = 0;
        }
      } else {
        // No exercises found, deactivate workout
        debugPrint('No exercises found for new workout type: $workoutType');
        isWorkoutActive.value = false;
        activeExercises.clear();
      }
    }
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
      
      // Update active exercises if workout is currently active
      _updateActiveExercises(newWorkoutType);

      StatusToast.showSuccess('Today\'s workout updated to $newWorkoutType');
    } catch (e) {
      StatusToast.showError('Failed to update workout: $e');
    } finally {
      Future.delayed(const Duration(milliseconds: 500), () {
        isProcessingAction.value = false;
      });
    }
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
          
          // Update active exercises if workout is currently active
          _updateActiveExercises(workoutType);
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

  // Reset entire workout schedule to defaults
  void resetWorkoutSchedule() {
    if (!_canPerformAction('resetWorkoutSchedule')) return;

    isProcessingAction.value = true;

    try {
      // Clear the map first to trigger change detection
      workoutSchedule.clear();
      
      // Reset to default schedule
      workoutSchedule.assignAll(defaultWorkoutSchedule);
      
      // Force update by cloning and reassigning 
      final Map<String, String> updatedSchedule = Map.from(workoutSchedule);
      workoutSchedule.assignAll(updatedSchedule);
      
      // Update today's workout
      currentWorkout.value = workoutSchedule[currentDay.value] ?? 'Rest';
      isRestDay.value = currentWorkout.value.toLowerCase() == 'rest';

      // Clear any saved progress
      _clearSavedWorkoutProgress();
      
      // Reset workout status
      _silentResetTodaysWorkoutStatus();
      
      StatusToast.showSuccess('Workout schedule reset to defaults');
    } catch (e) {
      StatusToast.showError('Failed to reset workout schedule: $e');
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
      // Validate template
      if (template.exercises.isEmpty) {
        debugPrint('WorkoutController.startTemplateWorkout(): Template has no exercises');
        // Instead of showing error and returning, let's get default exercises
        final defaultExercises = WorkoutData.getExercisesForType(template.name);
        
        if (defaultExercises.isEmpty) {
          debugPrint('WorkoutController.startTemplateWorkout(): No default exercises available');
          StatusToast.showError('No exercises available for this workout');
          isProcessingAction.value = false;
          return;
        }
        
        debugPrint('WorkoutController.startTemplateWorkout(): Using ${defaultExercises.length} default exercises');
        activeExercises.assignAll(defaultExercises);
      } else {
        // Clear previous active status
        isWorkoutActive.value = false;
        activeExercises.clear();

        // Convert template exercises to workout exercises with validation
        final List<Exercise> exercises = [];
        for (var e in template.exercises) {
          // Ensure target sets and reps are valid
          final targetSets = e.targetSets > 0 ? e.targetSets : 3;
          final targetReps = e.targetReps > 0 ? e.targetReps : 10;
          
          exercises.add(Exercise(
            name: e.name,
            workoutType: template.type,
            primaryMuscle: template.type, // Default primary muscle to template type
            secondaryMuscles: [], // Empty secondary muscles
            equipment: 'Unknown', // Default equipment
            targetSets: targetSets,
            targetReps: targetReps,
            notes: e.notes,
          ));
        }

        // Validate converted exercises
        if (exercises.isEmpty) {
          debugPrint('WorkoutController.startTemplateWorkout(): Failed to convert template exercises');
          
          // Try to get default exercises as fallback
          final defaultExercises = WorkoutData.getExercisesForType(template.name);
          if (defaultExercises.isNotEmpty) {
            debugPrint('WorkoutController.startTemplateWorkout(): Using ${defaultExercises.length} default exercises as fallback');
            activeExercises.assignAll(defaultExercises);
          } else {
            throw Exception('Failed to convert template exercises');
          }
        } else {
          activeExercises.assignAll(exercises);
        }
      }

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
      debugPrint('WorkoutController: Set workout active to true');

      // Reset completed/skipped status (without showing toast)
      _silentResetTodaysWorkoutStatus();

      // Record start time with storage
      _recordWorkoutStartTime();

      // Handle navigation directly here for consistency using the navigation helper
      _navigateToActiveWorkout();

      // Add direct fallback navigation after a short delay in case main navigation fails
      Future.delayed(const Duration(milliseconds: 800), () {
        if (isWorkoutActive.value && 
            activeExercises.isNotEmpty &&
            Get.currentRoute != '/active-workout') {
          debugPrint('WorkoutController.startTemplateWorkout(): Main navigation may have failed, using direct fallback');
          // Get.offAll() is more reliable than named routes when navigation is stuck
          Get.offAll(() => const ActiveWorkoutScreen());
        }
      });

      // Show toast AFTER navigation
      Future.delayed(const Duration(milliseconds: 300), () {
        StatusToast.showInfo('Starting ${template.name} workout');
      });
    } catch (e) {
      debugPrint('Error in startTemplateWorkout: $e');
      StatusToast.showError('Failed to start template workout: $e');

      // Reset active state if failed
      isWorkoutActive.value = false;
      
      // Clear any saved workout progress in case of error
      _clearSavedWorkoutProgress();
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
      currentWorkout.value = workoutName;

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

      // Record start time with storage
      _recordWorkoutStartTime();

      // Navigate to workout screen using our helper
      _navigateToActiveWorkout();

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

  // Helper method to get current exercise safely
  Exercise? getCurrentExercise() {
    if (activeExercises.isEmpty) return null;
    
    final index = activeExerciseIndex.value.clamp(0, activeExercises.length - 1);
    return activeExercises[index];
  }

  // Helper method to validate exercise index
  bool isValidExerciseIndex(int index) {
    return index >= 0 && index < activeExercises.length;
  }

  // Move to the next exercise with validation
  void nextExercise() {
    if (!_canPerformAction('nextExercise')) return;

    isProcessingAction.value = true;
    
    try {
      // Only advance if not on the last exercise
      if (activeExerciseIndex.value < activeExercises.length - 1) {
        activeExerciseIndex.value++;
      }
    } catch (e) {
      debugPrint('Error in nextExercise: $e');
    } finally {
      Future.delayed(const Duration(milliseconds: 500), () {
        isProcessingAction.value = false;
      });
    }
  }

  // Move to the previous exercise with validation
  void previousExercise() {
    if (!_canPerformAction('previousExercise')) return;

    isProcessingAction.value = true;
    
    try {
      // Only go back if not on the first exercise
      if (activeExerciseIndex.value > 0) {
        activeExerciseIndex.value--;
      }
    } catch (e) {
      debugPrint('Error in previousExercise: $e');
    } finally {
      Future.delayed(const Duration(milliseconds: 500), () {
        isProcessingAction.value = false;
      });
    }
  }

  // Record start time and save to storage
  void _recordWorkoutStartTime() {
    workoutStartTime = DateTime.now();
    _storage.write(kWorkoutStartTime, workoutStartTime!.toIso8601String());
  }
}
