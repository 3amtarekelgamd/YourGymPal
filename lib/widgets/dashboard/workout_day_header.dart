import 'package:flutter/material.dart';

class WorkoutDayHeader extends StatelessWidget {
  final String day;
  final String workout;
  final Function(String) getWorkoutColor;
  final bool isCompleted;
  final bool isSkipped;

  const WorkoutDayHeader({
    super.key,
    required this.day,
    required this.workout,
    required this.getWorkoutColor,
    required this.isCompleted,
    required this.isSkipped,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: getWorkoutColor(workout),
          radius: 24,
          child: Text(
            day.isNotEmpty ? day.substring(0, 3).toUpperCase() : '',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "TODAY'S WORKOUT",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            Text(
              workout,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Spacer(),
        if (isCompleted)
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 32,
          )
        else if (isSkipped)
          const Icon(
            Icons.cancel,
            color: Colors.red,
            size: 32,
          ),
      ],
    );
  }
}
