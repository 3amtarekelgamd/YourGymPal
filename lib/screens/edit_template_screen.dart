import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/templates_controller.dart';
import '../widgets/status/status_widgets.dart';
import 'dart:io';

class EditTemplateScreen extends StatefulWidget {
  const EditTemplateScreen({super.key});

  @override
  State<EditTemplateScreen> createState() => _EditTemplateScreenState();
}

class _EditTemplateScreenState extends State<EditTemplateScreen> {
  final TemplatesController _templatesController =
      Get.find<TemplatesController>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'Push';

  @override
  void initState() {
    super.initState();

    // Load template data if editing an existing template
    if (_templatesController.editingTemplate.value != null) {
      final template = _templatesController.editingTemplate.value!;
      _nameController.text = template.name;
      _descriptionController.text = template.description;
      _selectedType = template.type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveTemplate() {
    if (_nameController.text.isEmpty) {
      StatusToast.showError('Template name is required');
      return;
    }

    if (_templatesController.editingTemplate.value != null) {
      // Update existing template
      final updatedTemplate =
          _templatesController.editingTemplate.value!.copyWith(
        name: _nameController.text,
        description: _descriptionController.text,
        type: _selectedType,
      );

      _templatesController.updateTemplate(updatedTemplate);
    } else {
      // Create new template
      StatusToast.showInfo('Create template functionality not implemented yet');
    }

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(_templatesController.editingTemplate.value != null
            ? 'Edit Template'
            : 'New Template')),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveTemplate,
            tooltip: 'Save Template',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image
            Obx(() {
              final template = _templatesController.editingTemplate.value;
              return GestureDetector(
                onTap: () async {
                  if (template != null) {
                    final imagePath =
                        await _templatesController.pickTemplateCoverImage();
                    if (imagePath != null) {
                      _templatesController.updateTemplateWithNewImage(
                          template, imagePath);
                    }
                  }
                },
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                    image: template?.coverImagePath != null
                        ? DecorationImage(
                            image: FileImage(File(template!.coverImagePath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: template?.coverImagePath == null
                      ? const Center(
                          child: Icon(
                            Icons.add_photo_alternate,
                            size: 64,
                            color: Colors.grey,
                          ),
                        )
                      : null,
                ),
              );
            }),

            const SizedBox(height: 16),

            // Template name
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Template Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Workout type dropdown
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Workout Type',
                border: OutlineInputBorder(),
              ),
              items: ['Push', 'Pull', 'Legs', 'Custom']
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),

            const SizedBox(height: 16),

            // Description
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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

            const SizedBox(height: 8),

            // Exercise list
            Obx(() {
              final template = _templatesController.editingTemplate.value;

              if (template == null) {
                return const Center(
                  child: Text('Create template first to add exercises'),
                );
              }

              if (template.exercises.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No exercises added yet'),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: template.exercises.length,
                itemBuilder: (context, index) {
                  final exercise = template.exercises[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: exercise.imagePath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.file(
                                File(exercise.imagePath!),
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.fitness_center),
                      title: Text(exercise.name),
                      subtitle: Text(
                          '${exercise.targetSets} sets × ${exercise.targetReps} reps'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              // Edit exercise logic
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              // Remove exercise logic
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),

            const SizedBox(height: 16),

            // Add exercise button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Add exercise logic
                },
                icon: const Icon(Icons.add),
                label: const Text('ADD EXERCISE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
