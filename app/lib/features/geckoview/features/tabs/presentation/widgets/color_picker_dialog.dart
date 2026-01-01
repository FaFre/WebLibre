/*
 * Copyright (c) 2024-2025 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/material_color_picker.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/container_colors.dart';

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
        displayAlpha: ContainerColors.defaultAlpha,
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
