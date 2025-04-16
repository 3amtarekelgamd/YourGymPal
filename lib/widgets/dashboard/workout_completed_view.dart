import 'package:flutter/material.dart';

class WorkoutCompletedView extends StatelessWidget {
  const WorkoutCompletedView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        children: [
          Icon(
            Icons.emoji_events,
            color: Colors.amber,
            size: 48,
          ),
          SizedBox(height: 8),
          Text(
            'Great job! You completed today\'s workout.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Come back tomorrow for your next workout!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
