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
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/container_colors.dart';

/// Freeform color picker for power users.
///
/// Returns a [Color] (full opacity) intended to be used as the container's
/// stored color with `useCustomColor: true`. The preview swatch shows the
/// actual `containerColor` that [ContainerColors.palette] will produce in
/// custom mode, so what the user sees is what the chip will look like.
class CustomColorPickerDialog extends HookWidget {
  final Color initialColor;

  const CustomColorPickerDialog(this.initialColor, {super.key});

  @override
  Widget build(BuildContext context) {
    final hsl = useState<HSLColor>(HSLColor.fromColor(initialColor));
    final hexController = useTextEditingController(text: _toHex(initialColor));

    void updateHsl(HSLColor next) {
      hsl.value = next;
      final hex = _toHex(next.toColor());
      if (hexController.text.toUpperCase() != hex) {
        hexController.text = hex;
      }
    }

    void onHexSubmitted(String value) {
      final parsed = _parseHex(value);
      if (parsed != null) {
        hsl.value = HSLColor.fromColor(parsed);
        hexController.text = _toHex(parsed);
      } else {
        hexController.text = _toHex(hsl.value.toColor());
      }
    }

    final color = hsl.value.toColor();
    final palette = ContainerColors.palette(
      context,
      color,
      useCustomColor: true,
    );

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 8.0,
      ),
      title: const Text('Custom Color'),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PreviewSwatch(palette: palette),
            const SizedBox(height: 16),
            TextField(
              controller: hexController,
              decoration: const InputDecoration(
                labelText: 'Hex',
                prefixText: '#',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9a-fA-F]')),
                LengthLimitingTextInputFormatter(6),
              ],
              onSubmitted: onHexSubmitted,
              onChanged: (value) {
                if (value.length == 6) onHexSubmitted(value);
              },
            ),
            const SizedBox(height: 12),
            _GradientSlider(
              label: 'Hue',
              value: hsl.value.hue,
              max: 360,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFF0000),
                  Color(0xFFFFFF00),
                  Color(0xFF00FF00),
                  Color(0xFF00FFFF),
                  Color(0xFF0000FF),
                  Color(0xFFFF00FF),
                  Color(0xFFFF0000),
                ],
              ),
              onChanged: (v) => updateHsl(hsl.value.withHue(v)),
            ),
            _GradientSlider(
              label: 'Saturation',
              value: hsl.value.saturation,
              max: 1,
              gradient: LinearGradient(
                colors: [
                  HSLColor.fromAHSL(
                    1,
                    hsl.value.hue,
                    0,
                    hsl.value.lightness,
                  ).toColor(),
                  HSLColor.fromAHSL(
                    1,
                    hsl.value.hue,
                    1,
                    hsl.value.lightness,
                  ).toColor(),
                ],
              ),
              onChanged: (v) => updateHsl(hsl.value.withSaturation(v)),
            ),
            _GradientSlider(
              label: 'Lightness',
              value: hsl.value.lightness,
              max: 1,
              gradient: LinearGradient(
                colors: [
                  Colors.black,
                  HSLColor.fromAHSL(
                    1,
                    hsl.value.hue,
                    hsl.value.saturation,
                    0.5,
                  ).toColor(),
                  Colors.white,
                ],
              ),
              onChanged: (v) => updateHsl(hsl.value.withLightness(v)),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop<Color?>(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop<Color?>(context, color),
          child: const Text('Select'),
        ),
      ],
    );
  }
}

class _PreviewSwatch extends StatelessWidget {
  const _PreviewSwatch({required this.palette});

  final ContainerColorPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: palette.containerColor,
        shape: BoxShape.circle,
        border: Border.all(color: palette.outlineColor, width: 2),
      ),
      alignment: Alignment.center,
      child: Icon(Icons.check, color: palette.onContainerColor, size: 32),
    );
  }
}

class _GradientSlider extends StatelessWidget {
  const _GradientSlider({
    required this.label,
    required this.value,
    required this.max,
    required this.gradient,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double max;
  final Gradient gradient;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          SizedBox(
            height: 36,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    gradient: gradient,
                  ),
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.transparent,
                    inactiveTrackColor: Colors.transparent,
                    overlayColor: Colors.transparent,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 10,
                    ),
                  ),
                  child: Slider(
                    value: value.clamp(0, max).toDouble(),
                    max: max,
                    onChanged: onChanged,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _toHex(Color color) {
  final r = (color.r * 255).round().toRadixString(16).padLeft(2, '0');
  final g = (color.g * 255).round().toRadixString(16).padLeft(2, '0');
  final b = (color.b * 255).round().toRadixString(16).padLeft(2, '0');
  return '$r$g$b'.toUpperCase();
}

Color? _parseHex(String value) {
  final cleaned = value.replaceAll('#', '').trim();
  if (cleaned.length != 6) return null;
  final parsed = int.tryParse(cleaned, radix: 16);
  if (parsed == null) return null;
  return Color(0xFF000000 | parsed);
}
