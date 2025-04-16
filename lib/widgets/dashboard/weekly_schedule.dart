import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/workout_controller.dart';
import 'schedule_day_item.dart';

class WeeklySchedule extends StatelessWidget {
  final WorkoutController controller;
  final Function(String day, String workout) onEditDay;

  const WeeklySchedule({
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

        return ScheduleDayItem(
          day: day,
          workout: workout!,
          isToday: isToday,
          isCompleted: isToday && controller.isTodayWorkoutCompleted.value,
          isSkipped: isToday && controller.isTodayWorkoutSkipped.value,
          getWorkoutColor: controller.getWorkoutColor,
          onTap: () => onEditDay(day, workout),
        );
      },
    ));
  }
} 