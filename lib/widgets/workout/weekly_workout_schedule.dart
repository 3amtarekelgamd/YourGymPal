import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/workout_controller.dart';

class WeeklyWorkoutSchedule extends StatelessWidget {
  final WorkoutController controller;
  final Function(String day, String workout) onEditDay;

  const WeeklyWorkoutSchedule({
    super.key,
    required this.controller,
    required this.onEditDay,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() => ListView.builder(
          itemCount: controller.workoutSchedule.length,
          itemBuilder: (context, index) {
            final day = controller.workoutSchedule.keys.elementAt(index);
            final workout = controller.workoutSchedule[day];
            final bool isToday = day == controller.currentDay.value;

            return Card(
              elevation: isToday ? 2 : 1,
              color: isToday
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text(day),
                subtitle: Text(workout!),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => onEditDay(day, workout),
                ),
              ),
            );
          },
        ));
  }
}
