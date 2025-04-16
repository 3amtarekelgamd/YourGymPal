import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../controllers/workout_controller.dart';
import '../controllers/settings_controller.dart';
import '../controllers/templates_controller.dart';
import '../models/exercise.dart';
import '../models/workout_template.dart';
import '../services/image_service.dart';
import '../widgets/common/app_button.dart';
import '../widgets/status/status_widgets.dart';
import '../widgets/workout/weight_input_field.dart';

class CreateCustomWorkoutScreen extends StatefulWidget {
  const CreateCustomWorkoutScreen({super.key});

  @override
  State<CreateCustomWorkoutScreen> createState() =>
      _CreateCustomWorkoutScreenState();
}

class _CreateCustomWorkoutScreenState extends State<CreateCustomWorkoutScreen> {
  final WorkoutController workoutController = Get.find<WorkoutController>();
  final ImageService imageService = Get.find<ImageService>();
  final SettingsController settingsController = Get.find<SettingsController>();
  final exercises = <Exercise>[].obs;
  final workoutNameController =
      TextEditingController(text: 'My Custom Workout');

  // Removed workoutTypeController since we'll use the name as the type

  // New exercise form controllers
  final exerciseNameController = TextEditingController();
  final setsController = TextEditingController(text: '3');
  final repsController = TextEditingController(text: '10');
  final weightController = TextEditingController(text: '0.0');
  final muscleController = TextEditingController();
  final equipmentController = TextEditingController();
  String? selectedImagePath;

  // Use a regular double instead of RxDouble
  double currentWeight = 0.0;

  @override
  void dispose() {
    workoutNameController.dispose();
    exerciseNameController.dispose();
    setsController.dispose();
    repsController.dispose();
    weightController.dispose();
    muscleController.dispose();
    equipmentController.dispose();
    super.dispose();
  }

  void addExercise() {
    if (exerciseNameController.text.isEmpty) {
      StatusToast.showError('Exercise name is required');
      return;
    }

    final sets = int.tryParse(setsController.text) ?? 3;
    final reps = int.tryParse(repsController.text) ?? 10;

    // Use the regular double instead of .value
    final displayWeight = currentWeight;

    // Convert to kg for storage if needed
    final storageWeight =
        settingsController.displayWeightToStored(displayWeight);

    final exercise = Exercise(
      name: exerciseNameController.text,
      workoutType: 'Custom',
      primaryMuscle:
          muscleController.text.isNotEmpty ? muscleController.text : 'Custom',
      secondaryMuscles: [],
      equipment: equipmentController.text.isNotEmpty
          ? equipmentController.text
          : 'Custom',
      targetSets: sets,
      targetReps: reps,
      initialWeight: storageWeight,
      imageUrl: selectedImagePath,
      notes: null,
    );

    exercises.add(exercise);

    // Reset form
    exerciseNameController.clear();
    setsController.text = '3';
    repsController.text = '10';
    weightController.text = '0.0';
    setState(() {
      currentWeight = 0.0;
    });
    muscleController.clear();
    equipmentController.clear();
    setState(() {
      selectedImagePath = null;
    });

    StatusToast.showSuccess('Exercise added');
  }

  void removeExercise(int index) {
    exercises.removeAt(index);
    StatusToast.showInfo('Exercise removed');
  }

  Future<void> pickImage() async {
    final path = await imageService.pickImageFromGallery();
    if (path != null) {
      setState(() {
        selectedImagePath = path;
      });
    }
  }

  void saveWorkout() {
    if (exercises.isEmpty) {
      StatusToast.showError('Add at least one exercise to the workout');
      return;
    }

    if (workoutNameController.text.trim().isEmpty) {
      StatusToast.showError('Please enter a workout name');
      return;
    }

    // Don't allow 'Rest' as a workout name
    if (workoutNameController.text.trim().toLowerCase() == 'rest') {
      StatusToast.showError('"Rest" is not allowed as a workout name');
      return;
    }

    final templatesController = Get.find<TemplatesController>();

    // Convert exercises to template exercises
    final templateExercises = exercises
        .map((exercise) => TemplateExercise(
              name: exercise.name,
              targetSets: exercise.targetSets,
              targetReps: exercise.targetReps,
              weight: exercise.weight.value,
              imagePath: exercise.imageUrl,
              notes: exercise.notes,
            ))
        .toList();

    // Get workout name
    final workoutName = workoutNameController.text.trim();

    // Create a new template with the name as the type
    final template = WorkoutTemplate(
      id: const Uuid().v4(),
      name: workoutName,
      type: 'Custom', // Type is always 'Custom' for organization
      description: 'Custom workout',
      exercises: templateExercises,
    );

    // Add the template
    templatesController.addTemplate(template);

    // First workout message if this is the first template
    if (templatesController.templates.length == 1) {
      StatusToast.showInfo('First workout created! You can now schedule it');
    }

    // Update the workout controller with the new workout name
    workoutController.addCustomWorkoutType(workoutName);

    // Show success message and go back
    StatusToast.showSuccess('Workout saved as template');
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Custom Workout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workout name field
            TextField(
              controller: workoutNameController,
              decoration: const InputDecoration(
                labelText: 'Workout Name',
                border: OutlineInputBorder(),
                hintText: 'Enter a name for your workout',
              ),
            ),
            const SizedBox(height: 8),

            // Help text
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Text(
                'The workout name will be used to identify this workout in your schedule',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Exercise list
            const Text(
              'Exercises',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            Obx(() => exercises.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text('No exercises added yet'),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = exercises[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        child: ListTile(
                          leading: exercise.imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(4.0),
                                  child: Image.file(
                                    File(exercise.imageUrl!),
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(Icons.fitness_center),
                          title: Text(exercise.name),
                          subtitle: Obx(
                            () => Text(
                                '${exercise.targetSets} sets × ${exercise.targetReps} reps • ${exercise.weight.value > 0 ? settingsController.getFormattedWeight(exercise.weight.value) : 'No weight'}'),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => removeExercise(index),
                          ),
                        ),
                      );
                    },
                  )),

            const SizedBox(height: 20),

            // Add new exercise form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add New Exercise',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Exercise name
                    TextField(
                      controller: exerciseNameController,
                      decoration: const InputDecoration(
                        labelText: 'Exercise Name *',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Sets and reps in a row
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: setsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Sets',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: repsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Reps',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Weight field
                    WeightInputField(
                      weight: (currentWeight).obs,
                      label: 'Weight',
                      controller: weightController,
                      onValueChanged: (newValue) {
                        setState(() {
                          currentWeight = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // Optional fields in a row
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: muscleController,
                            decoration: const InputDecoration(
                              labelText: 'Muscle Group',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: equipmentController,
                            decoration: const InputDecoration(
                              labelText: 'Equipment',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Image picker
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: 'Select Image',
                            icon: Icons.image,
                            onPressed: pickImage,
                          ),
                        ),
                        if (selectedImagePath != null) ...[
                          const SizedBox(width: 12),
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.file(
                                File(selectedImagePath!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Add exercise button
                    AppButton(
                      text: 'Add Exercise',
                      icon: Icons.add,
                      onPressed: addExercise,
                      fullWidth: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Save workout button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text(
                  'Save & Start Workout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: saveWorkout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
