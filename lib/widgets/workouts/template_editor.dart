import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../controllers/templates_controller.dart';
import '../../models/workout_template.dart';
import '../common/image_picker_tile.dart';

class TemplateEditor extends StatefulWidget {
  final WorkoutTemplate? template;

  const TemplateEditor({
    super.key,
    this.template,
  });

  @override
  State<TemplateEditor> createState() => _TemplateEditorState();
}

class _TemplateEditorState extends State<TemplateEditor> {
  late WorkoutTemplate _template;
  final _formKey = GlobalKey<FormState>();
  final _templatesController = Get.find<TemplatesController>();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.template != null;

    if (_isEditing) {
      // Create a copy to avoid modifying the original
      _template = widget.template!;
    } else {
      // Create a new template
      _template = WorkoutTemplate(
        id: const Uuid().v4(),
        name: '',
        type: 'Custom',
        description: '',
        exercises: [],
        coverImagePath: null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isEditing ? 'Edit Template' : 'Create Template',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Template cover image
                    ImagePickerTile(
                      currentImagePath: _template.coverImagePath,
                      title: 'Cover Image',
                      height: 200,
                      onPickImage: _pickCoverImage,
                      onRemoveImage: _removeCoverImage,
                    ),

                    const SizedBox(height: 16),

                    // Template name
                    TextFormField(
                      initialValue: _template.name,
                      decoration: const InputDecoration(
                        labelText: 'Template Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _template = _template.copyWith(name: value);
                      },
                    ),

                    const SizedBox(height: 16),

                    // Workout type
                    DropdownButtonFormField<String>(
                      value: _template.type,
                      decoration: const InputDecoration(
                        labelText: 'Workout Type',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        'Push',
                        'Pull',
                        'Legs',
                        'Upper Body',
                        'Lower Body',
                        'Full Body',
                        'Custom'
                      ]
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          _template = _template.copyWith(type: value);
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      initialValue: _template.description,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      onChanged: (value) {
                        _template = _template.copyWith(description: value);
                      },
                    ),

                    const SizedBox(height: 24),

                    // Exercises section
                    const Text(
                      'Exercises',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Exercise list
                    ..._buildExerciseList(),

                    const SizedBox(height: 16),

                    // Add exercise button
                    ElevatedButton.icon(
                      onPressed: _addExercise,
                      icon: const Icon(Icons.add),
                      label: const Text('ADD EXERCISE'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Save button
                    ElevatedButton(
                      onPressed: _saveTemplate,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                          _isEditing ? 'UPDATE TEMPLATE' : 'CREATE TEMPLATE'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildExerciseList() {
    if (_template.exercises.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              'No exercises added yet',
              style: TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      ];
    }

    return _template.exercises.asMap().entries.map((entry) {
      final index = entry.key;
      final exercise = entry.value;

      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: ExpansionTile(
          title: Text(exercise.name),
          subtitle:
              Text('${exercise.targetSets} sets × ${exercise.targetReps} reps'),
          leading: const Icon(Icons.fitness_center),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Exercise image
                  ImagePickerTile(
                    currentImagePath: exercise.imagePath,
                    title: 'Exercise Image',
                    height: 120,
                    onPickImage: () => _pickExerciseImage(index),
                    onRemoveImage: () => _removeExerciseImage(index),
                  ),

                  const SizedBox(height: 16),

                  // Exercise name
                  TextFormField(
                    initialValue: exercise.name,
                    decoration: const InputDecoration(
                      labelText: 'Exercise Name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      _updateExercise(index, exercise.copyWith(name: value));
                    },
                  ),

                  const SizedBox(height: 16),

                  // Sets and reps
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: exercise.targetSets.toString(),
                          decoration: const InputDecoration(
                            labelText: 'Sets',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final sets =
                                int.tryParse(value) ?? exercise.targetSets;
                            _updateExercise(
                                index, exercise.copyWith(targetSets: sets));
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          initialValue: exercise.targetReps.toString(),
                          decoration: const InputDecoration(
                            labelText: 'Reps',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final reps =
                                int.tryParse(value) ?? exercise.targetReps;
                            _updateExercise(
                                index, exercise.copyWith(targetReps: reps));
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Notes
                  TextFormField(
                    initialValue: exercise.notes,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    onChanged: (value) {
                      _updateExercise(index, exercise.copyWith(notes: value));
                    },
                  ),

                  const SizedBox(height: 16),

                  // Delete exercise button
                  OutlinedButton.icon(
                    onPressed: () => _removeExercise(index),
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('REMOVE EXERCISE',
                        style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  void _updateExercise(int index, TemplateExercise exercise) {
    final exercises = [..._template.exercises];
    exercises[index] = exercise;

    setState(() {
      _template = _template.copyWith(exercises: exercises);
    });
  }

  void _addExercise() {
    final exercises = [..._template.exercises];
    exercises.add(TemplateExercise(
      name: 'New Exercise',
      targetSets: 3,
      targetReps: 10,
    ));

    setState(() {
      _template = _template.copyWith(exercises: exercises);
    });
  }

  void _removeExercise(int index) {
    final exercises = [..._template.exercises];
    final removedExercise = exercises.removeAt(index);

    // Handle image deletion if needed
    if (removedExercise.imagePath != null &&
        removedExercise.imagePath!.isNotEmpty) {
      // Try to safely delete the image file
      try {
        final file = File(removedExercise.imagePath!);
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (e) {
        debugPrint('Failed to delete exercise image: $e');
      }
    }

    setState(() {
      _template = _template.copyWith(exercises: exercises);
    });
  }

  Future<void> _pickCoverImage() async {
    final imagePath = await _templatesController.pickTemplateCoverImage();
    if (imagePath != null) {
      setState(() {
        _template = _template.copyWith(coverImagePath: imagePath);
      });
    }
  }

  void _removeCoverImage() {
    if (_template.coverImagePath != null) {
      _templatesController.deleteImage(_template.coverImagePath);
      setState(() {
        _template = _template.copyWith(coverImagePath: null);
      });
    }
  }

  Future<void> _pickExerciseImage(int exerciseIndex) async {
    final imagePath = await _templatesController.pickExerciseImage();
    if (imagePath != null) {
      final exercise = _template.exercises[exerciseIndex];
      _updateExercise(exerciseIndex, exercise.copyWith(imagePath: imagePath));
    }
  }

  void _removeExerciseImage(int exerciseIndex) {
    final exercise = _template.exercises[exerciseIndex];
    if (exercise.imagePath != null) {
      _templatesController.deleteImage(exercise.imagePath);
      _updateExercise(exerciseIndex, exercise.copyWith(imagePath: null));
    }
  }

  void _saveTemplate() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_isEditing) {
        _templatesController.updateTemplate(_template);
      } else {
        _templatesController.addTemplate(_template);
      }
      Navigator.pop(context);
    }
  }
}
