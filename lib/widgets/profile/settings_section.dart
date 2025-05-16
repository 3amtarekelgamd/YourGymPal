import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/settings_controller.dart';
import 'package:flutter/services.dart';

class TimerSettingsSection extends StatelessWidget {
  const TimerSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();

    return Obx(() => Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Timer Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Set Rest Duration
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Rest between sets:'),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          border: OutlineInputBorder(),
                          suffix: Text('s'),
                        ),
                        controller: TextEditingController(
                            text: controller.setRestDuration.value.toString()),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            final newValue = int.tryParse(value);
                            if (newValue != null && newValue > 0) {
                              controller.updateSetRestDuration(newValue);
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Workout Rest Duration
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Rest between exercises:'),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          border: OutlineInputBorder(),
                          suffix: Text('s'),
                        ),
                        controller: TextEditingController(
                            text: controller.workoutRestDuration.value
                                .toString()),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            final newValue = int.tryParse(value);
                            if (newValue != null && newValue > 0) {
                              controller.updateWorkoutRestDuration(newValue);
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),

                const Divider(),

                // Sound alerts
                SwitchListTile(
                  title: const Text('Sound alerts'),
                  value: controller.enableSoundAlerts.value,
                  onChanged: (_) => controller.toggleSoundAlerts(),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),

                // Vibration
                SwitchListTile(
                  title: const Text('Vibration'),
                  value: controller.enableVibration.value,
                  onChanged: (_) => controller.toggleVibration(),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),

                // Auto-start timer
                SwitchListTile(
                  title: const Text('Auto-start timer'),
                  subtitle: const Text('Automatically start rest timer'),
                  value: controller.autoStartTimer.value,
                  onChanged: (_) => controller.toggleAutoStartTimer(),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ));
  }
}

class AppearanceSettingsSection extends StatelessWidget {
  const AppearanceSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();

    return Obx(() => Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Appearance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Dark mode
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  value: controller.isDarkMode.value,
                  onChanged: (_) => controller.toggleDarkMode(),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),

                // Show completed workouts
                SwitchListTile(
                  title: const Text('Show completed workouts'),
                  subtitle: const Text('Display completed workouts in history'),
                  value: controller.showCompletedWorkouts.value,
                  onChanged: (value) {
                    controller.showCompletedWorkouts.value = value;
                    controller.saveSettings();
                  },
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ));
  }
}

class MeasurementSettingsSection extends StatelessWidget {
  const MeasurementSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();

    return Obx(() => Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Measurements',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Weight unit
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Weight unit:'),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment<String>(
                          value: 'kg',
                          label: Text('kg'),
                        ),
                        ButtonSegment<String>(
                          value: 'lb',
                          label: Text('lb'),
                        ),
                      ],
                      selected: {controller.weightUnit.value},
                      onSelectionChanged: (Set<String> selection) {
                        if (selection.isNotEmpty) {
                          controller.setWeightUnit(selection.first);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
