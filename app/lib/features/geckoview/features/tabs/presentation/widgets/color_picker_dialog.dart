import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/material_color_picker.dart';

class ColorPickerDialog extends HookWidget {
  final Color initialColor;

  const ColorPickerDialog(this.initialColor);

  @override
  Widget build(BuildContext context) {
    final selectedColor = useState<Color>(initialColor);

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
      contentPadding: const EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        bottom: 24.0,
      ),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 24.0,
      ),
      title: const Text('Select Color'),
      content: MaterialPicker(
        pickerColor: selectedColor.value,
        onColorChanged: (value) {
          selectedColor.value = value;
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop<Color?>(context);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop<Color?>(context, selectedColor.value);
          },
          child: const Text('Select'),
        ),
      ],
    );
  }
}
