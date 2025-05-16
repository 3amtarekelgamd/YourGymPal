import 'package:flutter/material.dart';

class WorkoutSkippedView extends StatelessWidget {
  final VoidCallback onUndoSkip;

  const WorkoutSkippedView({
    super.key,
    required this.onUndoSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Icon(
            Icons.skip_next,
            color: Colors.orange,
            size: 48,
          ),
          const SizedBox(height: 8),
          const Text(
            'You skipped today\'s workout.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'No worries! Everyone needs a break sometimes.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onUndoSkip,
            child: const Text('UNDO SKIP'),
          ),
        ],
      ),
    );
  }
}
