import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CalorieTrackerController extends GetxController {
  var selectedExercise = 'Treadmill (Running)'.obs;
  var distance = 0.0.obs;
  var duration = 0.0.obs;
  var weight = 70.0.obs;
  var caloriesBurned = 0.0.obs;

  void calculateCalories() {
    if (duration.value <= 0 || weight.value <= 0) {
      caloriesBurned.value = 0;
      return;
    }

    double metValue = 0;
    switch (selectedExercise.value) {
      case 'Treadmill (Running)':
        metValue = 8.0;
        break;
      case 'Treadmill (Walking)':
        metValue = 4.0;
        break;
      case 'Exercise Bike':
        metValue = 7.0;
        break;
      default:
        metValue = 5.0;
    }

    caloriesBurned.value = metValue * weight.value * (duration.value / 60);
  }
}

class CalorieTrackerScreen extends StatelessWidget {
  const CalorieTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CalorieTrackerController());

    return Scaffold(
      appBar: AppBar(title: const Text('Calorie Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Exercise Dropdown
            Card(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    const Text('Select Exercise',
                        style: TextStyle(fontSize: 16)),
                    Obx(() => DropdownButton<String>(
                          value: controller.selectedExercise.value,
                          items: [
                            'Treadmill (Running)',
                            'Treadmill (Walking)',
                            'Exercise Bike',
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            controller.selectedExercise.value = value!;
                            controller.calculateCalories();
                          },
                        )),
                  ],
                ),
              ),
            ),

            // Input Fields
            Card(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    TextField(
                      decoration:
                          const InputDecoration(labelText: 'Distance (km)'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        controller.distance.value =
                            double.tryParse(value) ?? 0.0;
                        controller.calculateCalories();
                      },
                    ),
                    TextField(
                      decoration: const InputDecoration(
                          labelText: 'Duration (minutes)'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        controller.duration.value =
                            double.tryParse(value) ?? 0.0;
                        controller.calculateCalories();
                      },
                    ),
                    TextField(
                      decoration:
                          const InputDecoration(labelText: 'Weight (kg)'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        controller.weight.value =
                            double.tryParse(value) ?? 70.0;
                        controller.calculateCalories();
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Results
            Obx(() => Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Text('Calories Burned',
                            style: TextStyle(fontSize: 20)),
                        Text(
                          '${controller.caloriesBurned.value.toStringAsFixed(1)} kcal',
                          style: const TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
