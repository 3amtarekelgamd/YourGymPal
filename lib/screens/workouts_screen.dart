import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/workouts_controller.dart';
import '../widgets/workout/workout_card.dart';

class WorkoutsScreen extends GetView<WorkoutsController> {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Workouts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search workouts',
            onPressed: () => _showSearchDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh workouts',
            onPressed: () => controller.refreshTemplates(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/create-custom-workout'),
        tooltip: 'Create custom workout',
        child: const Icon(Icons.add),
      ),
      body: _buildWorkoutsList(),
    );
  }

  Widget _buildWorkoutsList() {
    return Obx(() {
      // Show loading indicator while loading
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      // Show search term if active
      final searchActive = controller.searchTerm.value.isNotEmpty;

      // Get filtered templates
      final templates = controller.filteredTemplates;

      if (templates.isEmpty) {
        // No workouts found
        if (searchActive) {
          // No results for search
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.search_off,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No workouts found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'No results for "${controller.searchTerm.value}"',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () => controller.clearSearch(),
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear Search'),
                ),
              ],
            ),
          );
        } else {
          // No workouts at all
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.fitness_center,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No custom workouts yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Create your first workout to get started',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Get.toNamed('/create-custom-workout'),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Workout'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      }

      // Show search indicator if active
      final searchWidget = searchActive
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              color: Colors.blue.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Search: "${controller.searchTerm.value}"',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => controller.clearSearch(),
                    child: const Icon(Icons.clear, size: 18),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink();

      return Column(
        children: [
          // Search indicator
          searchWidget,

          // Workout cards
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final template = templates[index];
                final color = controller.getWorkoutColor(template.type);

                return Dismissible(
                  key: Key(template.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: const Text('Delete Workout'),
                          content: Text(
                              'Are you sure you want to delete "${template.name}"?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(false),
                              child: const Text('CANCEL'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(true),
                              child: const Text('DELETE'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) {
                    controller.deleteTemplate(template.id);
                  },
                  child: WorkoutCard(
                    template: template,
                    cardColor: color,
                    onEdit: () => controller.editTemplate(template),
                    onStart: () => controller.startWorkout(template.id),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  /// Show search dialog
  void _showSearchDialog(BuildContext context) {
    final searchController =
        TextEditingController(text: controller.searchTerm.value);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Search Workouts'),
          content: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: 'Search by name, type, exercises...',
              prefixIcon: Icon(Icons.search),
            ),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Clear and close
                controller.clearSearch();
                Navigator.of(dialogContext).pop();
              },
              child: const Text('CLEAR'),
            ),
            TextButton(
              onPressed: () {
                // Cancel and close
                Navigator.of(dialogContext).pop();
              },
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                // Apply search and close
                controller.search(searchController.text);
                Navigator.of(dialogContext).pop();
              },
              child: const Text('SEARCH'),
            ),
          ],
        );
      },
    );
  }
}
