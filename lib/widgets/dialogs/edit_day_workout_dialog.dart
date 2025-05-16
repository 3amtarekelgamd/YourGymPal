import 'package:flutter/material.dart';

class EditDayWorkoutDialog extends StatefulWidget {
  final String day;
  final String currentWorkout;
  final List<String> workoutTypes;
  final Function(String) getWorkoutColor;
  final Function(String) onWorkoutChanged;

  const EditDayWorkoutDialog({
    super.key,
    required this.day,
    required this.currentWorkout,
    required this.workoutTypes,
    required this.getWorkoutColor,
    required this.onWorkoutChanged,
  });

  @override
  State<EditDayWorkoutDialog> createState() => _EditDayWorkoutDialogState();
}

class _EditDayWorkoutDialogState extends State<EditDayWorkoutDialog> {
  bool _isProcessing = false;
  late String _selectedWorkout;
  late List<String> _uniqueWorkoutTypes;

  @override
  void initState() {
    super.initState();

    // Ensure we have a list with no duplicates and it includes the current workout
    _uniqueWorkoutTypes = _getUniqueWorkoutTypesList();

    // Make sure the selected workout is in our list
    if (_uniqueWorkoutTypes.contains(widget.currentWorkout)) {
      _selectedWorkout = widget.currentWorkout;
    } else {
      // If for some reason the current workout isn't in the list,
      // get a case-insensitive match or use the first item
      final lowerCurrentWorkout = widget.currentWorkout.toLowerCase();
      final matchingIndex = _uniqueWorkoutTypes
          .indexWhere((type) => type.toLowerCase() == lowerCurrentWorkout);

      if (matchingIndex >= 0) {
        _selectedWorkout = _uniqueWorkoutTypes[matchingIndex];
      } else {
        _selectedWorkout = _uniqueWorkoutTypes.first;
      }
    }
  }

  // Create a list with no duplicates that includes the current workout
  List<String> _getUniqueWorkoutTypesList() {
    final uniqueTypes = <String>{};

    // First add the current workout to ensure it's included
    uniqueTypes.add(widget.currentWorkout);

    // Add all other workout types
    for (final type in widget.workoutTypes) {
      uniqueTypes.add(type);
    }

    return uniqueTypes.toList();
  }

  void _saveAndClose() {
    if (_selectedWorkout == widget.currentWorkout) {
      // No changes, just close
      Navigator.of(context).pop();
      return;
    }

    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    // Close dialog and call the change handler
    Navigator.of(context).pop();
    widget.onWorkoutChanged(_selectedWorkout);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isProcessing,
      child: AlertDialog(
        title: Text('Edit ${widget.day} Workout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current workout: ${widget.currentWorkout}'),
            const SizedBox(height: 16),
            // Use our unique list for the dropdown
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: _selectedWorkout,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              ),
              items: _uniqueWorkoutTypes.map((String value) {
                final bool isRestOption = value.toLowerCase() == 'rest';

                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: widget.getWorkoutColor(value),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      if (isRestOption) ...[
                        const Icon(Icons.hotel, size: 16),
                        const SizedBox(width: 4.0),
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
              onChanged: _isProcessing
                  ? null
                  : (String? value) {
                      if (value != null) {
                        setState(() {
                          _selectedWorkout = value;
                        });
                      }
                    },
            ),
            const SizedBox(height: 8),
            if (_selectedWorkout.toLowerCase() == 'rest')
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.grey),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Rest days are important for recovery!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: _isProcessing ? null : _saveAndClose,
            child: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('SAVE'),
          ),
        ],
      ),
    );
  }
}
