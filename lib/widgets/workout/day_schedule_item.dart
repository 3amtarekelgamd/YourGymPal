import 'package:flutter/material.dart';
import 'workout_type_indicator.dart';

/// Widget for displaying a day's schedule in the dashboard
class DayScheduleItem extends StatelessWidget {
  final String day;
  final String workoutType;
  final bool isToday;
  final bool isCompleted;
  final bool isSkipped;
  final VoidCallback? onTap;

  const DayScheduleItem({
    super.key,
    required this.day,
    required this.workoutType,
    this.isToday = false,
    this.isCompleted = false,
    this.isSkipped = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: isToday ? Colors.blue.withOpacity(0.1) : null,
          border: isToday
              ? Border.all(color: Colors.blue.withOpacity(0.3), width: 1.0)
              : null,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            WorkoutTypeIndicator(workoutType: workoutType),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    workoutType,
                    style: TextStyle(
                      color: isSkipped ? Colors.grey : null,
                      decoration: isSkipped ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ],
              ),
            ),
            if (isCompleted)
              const Icon(Icons.check_circle, color: Colors.green)
            else if (isSkipped)
              const Icon(Icons.cancel, color: Colors.grey)
            else if (isToday)
              const Icon(Icons.edit, color: Colors.blue, size: 18.0),
          ],
        ),
      ),
    );
  }
}
