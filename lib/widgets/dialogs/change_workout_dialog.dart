import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/workout_controller.dart';

/// Dialog for changing workout type
class ChangeWorkoutDialog extends StatefulWidget {
  final Function(String) onChangeWorkout;

  const ChangeWorkoutDialog({
    super.key,
    required this.onChangeWorkout,
  });

  @override
  State<ChangeWorkoutDialog> createState() => _ChangeWorkoutDialogState();
}

class _ChangeWorkoutDialogState extends State<ChangeWorkoutDialog> {
  late String selectedWorkout;
  late WorkoutController workoutController;
  List<String> uniqueWorkoutTypes = [];

  @override
  void initState() {
    super.initState();
    workoutController = Get.find<WorkoutController>();
    selectedWorkout = workoutController.currentWorkout.value;

    // We'll initialize the workout types list in didChangeDependencies
    // since we need to wait for the controller to be available
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get unique workout types and ensure current workout is included
    _initializeWorkoutTypes();
  }

  void _initializeWorkoutTypes() {
    // Get available types from controller
    final availableTypes = workoutController.availableWorkoutTypes;

    // Create a set to ensure uniqueness
    final typeSet = <String>{};

    // First add the current workout to ensure it's included
    typeSet.add(selectedWorkout);

    // Add all other types
    typeSet.addAll(availableTypes);

    // Convert to list
    uniqueWorkoutTypes = typeSet.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Change Workout',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select a workout type from your custom templates or default options',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 1,
                ),
              ),
              child: DropdownButton<String>(
                value: selectedWorkout,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down),
                elevation: 16,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                ),
                underline: Container(
                  height: 0,
                ),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedWorkout = newValue;
                    });
                  }
                },
                items: uniqueWorkoutTypes
                    .map<DropdownMenuItem<String>>((String value) {
                  final bool isRestOption = value.toLowerCase() == 'rest';
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Row(
                      children: [
                        Icon(
                          _getIconForType(value),
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        if (isRestOption) ...[
                          Text(
                            value,
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ] else
                          Text(value),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    widget.onChangeWorkout(selectedWorkout);
                    Get.back();
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get an icon for each workout type
  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'push':
        return Icons.fitness_center;
      case 'pull':
        return Icons.sports_gymnastics;
      case 'legs':
        return Icons.directions_run;
      case 'custom':
        return Icons.assignment;
      case 'rest':
        return Icons.hotel;
      default:
        return Icons.fitness_center;
    }
  }
}
