import 'package:flutter/material.dart';
import 'workout_type_indicator.dart';

/// Widget to select workout type from dropdown
class WorkoutTypeDropdown extends StatelessWidget {
  final String currentValue;
  final List<String> items;
  final Function(String?) onChanged;
  final String? description;
  final bool isCustomSchedule;

  const WorkoutTypeDropdown({
    super.key,
    required this.currentValue,
    required this.items,
    required this.onChanged,
    this.description,
    this.isCustomSchedule = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (description != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              description!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        DropdownButtonFormField<String>(
          value: currentValue,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            hintText: 'Select workout type',
          ),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Row(
                children: [
                  WorkoutTypeIndicator(workoutType: value),
                  const SizedBox(width: 8.0),
                  Text(value),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
