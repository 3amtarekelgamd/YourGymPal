import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController settingsController =
        Get.find<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // App Theme
          Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'App Theme',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Obx(() => SwitchListTile(
                        title: const Text('Dark Mode'),
                        subtitle: const Text('Enable dark theme for the app'),
                        value: settingsController.isDarkMode.value,
                        onChanged: (value) {
                          settingsController.toggleDarkMode();
                        },
                      )),
                ],
              ),
            ),
          ),

          // Rest Timer Settings
          Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rest Timer Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Set Rest Duration
                  Obx(() => ListTile(
                        title: const Text('Set Rest Duration'),
                        subtitle: const Text('Seconds between sets'),
                        trailing: SizedBox(
                          width: 80,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              border: OutlineInputBorder(),
                              suffix: Text('s'),
                            ),
                            controller: TextEditingController(
                                text: settingsController.setRestDuration.value
                                    .toString()),
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                final newValue = int.tryParse(value);
                                if (newValue != null && newValue > 0) {
                                  settingsController
                                      .updateSetRestDuration(newValue);
                                }
                              }
                            },
                          ),
                        ),
                      )),

                  const Divider(),

                  // Exercise Rest Duration
                  Obx(() => ListTile(
                        title: const Text('Exercise Rest Duration'),
                        subtitle: const Text('Seconds between exercises'),
                        trailing: SizedBox(
                          width: 80,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              border: OutlineInputBorder(),
                              suffix: Text('s'),
                            ),
                            controller: TextEditingController(
                                text: settingsController
                                    .workoutRestDuration.value
                                    .toString()),
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                final newValue = int.tryParse(value);
                                if (newValue != null && newValue > 0) {
                                  settingsController
                                      .updateWorkoutRestDuration(newValue);
                                }
                              }
                            },
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ),

          // Notification Settings
          Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notification Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sound Alerts
                  Obx(() => SwitchListTile(
                        title: const Text('Sound Alerts'),
                        subtitle: const Text('Play sounds for timer alerts'),
                        value: settingsController.enableSoundAlerts.value,
                        onChanged: (value) {
                          settingsController.toggleSoundAlerts();
                        },
                      )),

                  // Vibration
                  Obx(() => SwitchListTile(
                        title: const Text('Vibration'),
                        subtitle: const Text('Vibrate device for timer alerts'),
                        value: settingsController.enableVibration.value,
                        onChanged: (value) {
                          settingsController.toggleVibration();
                        },
                      )),

                  // Auto Start Timer
                  Obx(() => SwitchListTile(
                        title: const Text('Auto Start Timer'),
                        subtitle: const Text(
                            'Automatically start rest timer after completing a set'),
                        value: settingsController.autoStartTimer.value,
                        onChanged: (value) {
                          settingsController.toggleAutoStartTimer();
                        },
                      )),
                ],
              ),
            ),
          ),

          // Units
          Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Units',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Weight Unit
                  Obx(() => RadioListTile<String>(
                        title: const Text('Kilograms (kg)'),
                        value: 'kg',
                        groupValue: settingsController.weightUnit.value,
                        onChanged: (value) {
                          if (value != null) {
                            settingsController.setWeightUnit(value);
                          }
                        },
                      )),

                  Obx(() => RadioListTile<String>(
                        title: const Text('Pounds (lb)'),
                        value: 'lb',
                        groupValue: settingsController.weightUnit.value,
                        onChanged: (value) {
                          if (value != null) {
                            settingsController.setWeightUnit(value);
                          }
                        },
                      )),
                ],
              ),
            ),
          ),

          // About
          Card(
            child: ListTile(
              title: const Text('About'),
              subtitle: const Text('App version 1.0.0'),
              leading: const Icon(Icons.info_outline),
              onTap: () {
                // Show about dialog
                showAboutDialog(
                  context: context,
                  applicationName: 'Gym App',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2023 Your Company',
                  children: [
                    const SizedBox(height: 16),
                    const Text('A simple gym workout tracking app.'),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
