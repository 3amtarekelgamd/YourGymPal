import 'package:flutter/material.dart';
import '../status/status_chip.dart';

class ScheduleDayItem extends StatelessWidget {
  final String day;
  final String workout;
  final bool isToday;
  final bool isCompleted;
  final bool isSkipped;
  final Function(String) getWorkoutColor;
  final VoidCallback onTap;

  const ScheduleDayItem({
    super.key,
    required this.day,
    required this.workout,
    required this.isToday,
    required this.isCompleted,
    required this.isSkipped,
    required this.getWorkoutColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRestDay = workout.toLowerCase() == 'rest';

    return Card(
      elevation: isToday ? 2 : 1,
      color: isToday ? Theme.of(context).colorScheme.primaryContainer : null,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: getWorkoutColor(workout),
          child: isRestDay
              ? const Icon(Icons.hotel, color: Colors.white)
              : Text(
                  day.substring(0, 3),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        title: Text(
          day,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: isRestDay
            ? Text(
                workout,
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                ),
              )
            : Text(workout),
        trailing: isToday ? _buildStatusChip() : null,
        onTap: onTap,
      ),
    );
  }

  Widget _buildStatusChip() {
    if (isCompleted) {
      return const StatusChip(
        label: 'COMPLETED',
        backgroundColor: Colors.green,
      );
    } else if (isSkipped) {
      return const StatusChip(
        label: 'SKIPPED',
        backgroundColor: Colors.orange,
      );
    } else {
      return const StatusChip(label: 'TODAY');
    }
  }
}
