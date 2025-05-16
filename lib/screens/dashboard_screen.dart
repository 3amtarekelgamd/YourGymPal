import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/workout_controller.dart';
import '../widgets/dashboard/today_workout_card.dart';
import '../widgets/dashboard/weekly_schedule.dart';
import '../widgets/dialogs/change_workout_dialog.dart';
import '../widgets/dialogs/edit_day_workout_dialog.dart';
import 'calorie_tracker.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WorkoutController controller = Get.find<WorkoutController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () => _showChangeWorkoutDialog(context, controller),
            tooltip: 'Change Today\'s Workout',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.resetWorkoutSchedule,
            tooltip: 'Reset Workout Schedule',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TodayWorkoutCard(controller: controller),
            // بعد TodayWorkoutCard مباشرة
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.local_fire_department),
              label: const Text('Calorie Tracker'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[100],
                foregroundColor: Colors.orange[800],
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () => Get.to(() => const CalorieTrackerScreen()),
            ),
            const SizedBox(height: 24),
            const Text(
              'Weekly Workout Schedule',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: WeeklySchedule(
                controller: controller,
                onEditDay: (day, workout) => _showEditDayWorkoutDialog(
                    context, controller, day, workout),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeWorkoutDialog(
      BuildContext context, WorkoutController controller) {
    showDialog(
      context: context,
      builder: (context) => ChangeWorkoutDialog(
        onChangeWorkout: (value) {
          controller.updateWorkoutSchedule(controller.currentDay.value, value);
        },
      ),
    );
  }

  void _showEditDayWorkoutDialog(BuildContext context,
      WorkoutController controller, String day, String currentWorkout) {
    showDialog(
      context: context,
      builder: (context) => EditDayWorkoutDialog(
        day: day,
        currentWorkout: currentWorkout,
        workoutTypes: controller.availableWorkoutTypes,
        getWorkoutColor: controller.getWorkoutColor,
        onWorkoutChanged: (value) {
          controller.updateWorkoutSchedule(day, value);
        },
      ),
    );
  }
}
