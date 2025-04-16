import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/settings_controller.dart';

class WeightInputField extends StatelessWidget {
  final Rx<double> weight;
  final String? label;
  final bool isDense;
  final bool showIncrement;
  final TextEditingController? controller;
  final Function(double)? onValueChanged;

  const WeightInputField({
    super.key,
    required this.weight,
    this.label,
    this.isDense = false,
    this.showIncrement = false,
    this.controller,
    this.onValueChanged,
  });

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();

    // Create local controller if none is provided
    final textController = controller ??
        TextEditingController(
            text: weight.value > 0
                ? settingsController
                    .storedWeightToDisplay(weight.value)
                    .toString()
                : '');

    return Obx(() {
      // Update controller text when weight changes externally
      if (controller == null &&
          textController.text !=
              settingsController
                  .storedWeightToDisplay(weight.value)
                  .toString() &&
          !textController.text.endsWith('.')) {
        textController.text = weight.value > 0
            ? settingsController.storedWeightToDisplay(weight.value).toString()
            : '';
      }

      final unit = settingsController.weightUnit.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                label!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          TextField(
            controller: textController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            textAlign: isDense ? TextAlign.start : TextAlign.center,
            decoration: InputDecoration(
              contentPadding: isDense
                  ? const EdgeInsets.symmetric(horizontal: 8, vertical: 8)
                  : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: const OutlineInputBorder(),
              suffixText: unit,
              hintText: '0.0',
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                try {
                  final parsedWeight = double.parse(value);
                  final storedWeight =
                      settingsController.displayWeightToStored(parsedWeight);
                  weight.value = storedWeight;
                  onValueChanged?.call(storedWeight);
                } catch (e) {
                  // Invalid input, ignore
                }
              } else {
                weight.value = 0.0;
                onValueChanged?.call(0.0);
              }
            },
            style: TextStyle(
              fontSize: isDense ? 14 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (showIncrement)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIncrementButton(
                    icon: Icons.remove_circle_outline,
                    onPressed: () {
                      final increment = settingsController.getWeightIncrement();
                      final currentWeight = settingsController
                          .storedWeightToDisplay(weight.value);
                      final newWeight = (currentWeight - increment) > 0
                          ? (currentWeight - increment)
                          : 0.0;
                      weight.value =
                          settingsController.displayWeightToStored(newWeight);
                      textController.text = newWeight.toString();
                      onValueChanged?.call(weight.value);
                    },
                  ),
                  const SizedBox(width: 16),
                  _buildIncrementButton(
                    icon: Icons.add_circle_outline,
                    onPressed: () {
                      final increment = settingsController.getWeightIncrement();
                      final currentWeight = settingsController
                          .storedWeightToDisplay(weight.value);
                      final newWeight = currentWeight + increment;
                      weight.value =
                          settingsController.displayWeightToStored(newWeight);
                      textController.text = newWeight.toString();
                      onValueChanged?.call(weight.value);
                    },
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  Widget _buildIncrementButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon),
      ),
    );
  }
}
