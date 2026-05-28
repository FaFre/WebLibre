/*
 * Copyright (c) 2024-2026 Fabian Freund.
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
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/custom_color_picker_dialog.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/color_palette.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/container_colors.dart';

typedef ColorPickerResult = ({Color color, bool useCustomColor});

class ColorPickerDialog extends HookWidget {
  final Color initialColor;
  final bool initialUseCustomColor;

  const ColorPickerDialog(
    this.initialColor, {
    this.initialUseCustomColor = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final selectedColor = useState<Color>(initialColor);
    final useCustom = useState<bool>(initialUseCustomColor);

    Future<void> openCustomPicker() async {
      final result = await showDialog<Color?>(
        context: context,
        builder: (_) => CustomColorPickerDialog(selectedColor.value),
      );
      if (result != null) {
        selectedColor.value = result;
        useCustom.value = true;
      }
    }

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 8.0,
      ),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 24.0,
      ),
      title: const Text('Select Color'),
      content: _ContainerColorGrid(
        selectedColor: selectedColor.value,
        useCustomColor: useCustom.value,
        onSeedSelected: (color) {
          selectedColor.value = color;
          useCustom.value = false;
        },
        onCustomTapped: openCustomPicker,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop<ColorPickerResult?>(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop<ColorPickerResult?>(
            context,
            (color: selectedColor.value, useCustomColor: useCustom.value),
          ),
          child: const Text('Select'),
        ),
      ],
    );
  }
}

class _ContainerColorGrid extends StatelessWidget {
  const _ContainerColorGrid({
    required this.selectedColor,
    required this.useCustomColor,
    required this.onSeedSelected,
    required this.onCustomTapped,
  });

  final Color selectedColor;
  final bool useCustomColor;
  final ValueChanged<Color> onSeedSelected;
  final VoidCallback onCustomTapped;

  @override
  Widget build(BuildContext context) {
    final itemCount = containerSeedColors.length + 1;
    return SizedBox(
      width: 320,
      child: GridView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index == containerSeedColors.length) {
            return _CustomSwatch(
              isSelected: useCustomColor,
              selectedColor: selectedColor,
              onTap: onCustomTapped,
            );
          }
          final seed = containerSeedColors[index];
          final palette = ContainerColors.palette(context, seed);
          final isSelected =
              !useCustomColor && seed.toARGB32() == selectedColor.toARGB32();
          return _Swatch(
            displayColor: palette.containerColor,
            checkColor: palette.onContainerColor,
            isSelected: isSelected,
            onTap: () => onSeedSelected(seed),
          );
        },
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.displayColor,
    required this.checkColor,
    required this.isSelected,
    required this.onTap,
  });

  final Color displayColor;
  final Color checkColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 28,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: displayColor,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(
                  color: Theme.of(context).colorScheme.onSurface,
                  width: 2,
                )
              : null,
        ),
        child: isSelected
            ? Icon(Icons.check, size: 20, color: checkColor)
            : const SizedBox.expand(),
      ),
    );
  }
}

class _CustomSwatch extends StatelessWidget {
  const _CustomSwatch({
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final palette = isSelected
        ? ContainerColors.palette(
            context,
            selectedColor,
            useCustomColor: true,
          )
        : null;
    return InkResponse(
      onTap: onTap,
      radius: 28,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: palette?.containerColor ?? Colors.transparent,
          border: Border.all(
            color: isSelected
                ? colorScheme.onSurface
                : colorScheme.outline.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: isSelected
            ? Icon(Icons.check, size: 20, color: palette!.onContainerColor)
            : Icon(
                Icons.colorize,
                size: 18,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
      ),
    );
  }
}
