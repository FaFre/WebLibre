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

/// A [TextField] for secret values. Hidden by default; tap the trailing eye
/// icon to reveal. Obscuring forces single-line; [revealedMinLines] and
/// [revealedMaxLines] control how the field expands once revealed.
class ObscurableTextField extends HookWidget {
  final TextEditingController? controller;
  final bool enabled;
  final InputDecoration decoration;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final int? revealedMinLines;
  final int? revealedMaxLines;
  final ValueChanged<String>? onChanged;

  const ObscurableTextField({
    super.key,
    this.controller,
    this.enabled = true,
    this.decoration = const InputDecoration(),
    this.textInputAction,
    this.keyboardType,
    this.revealedMinLines,
    this.revealedMaxLines,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final obscured = useState(true);

    final suffix = IconButton(
      tooltip: obscured.value ? 'Show' : 'Hide',
      icon: Icon(
        obscured.value
            ? Icons.visibility_outlined
            : Icons.visibility_off_outlined,
      ),
      onPressed: enabled ? () => obscured.value = !obscured.value : null,
    );

    return TextField(
      controller: controller,
      enabled: enabled,
      obscureText: obscured.value,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      minLines: obscured.value ? 1 : revealedMinLines,
      maxLines: obscured.value ? 1 : (revealedMaxLines ?? 1),
      autocorrect: false,
      enableSuggestions: false,
      decoration: decoration.copyWith(suffixIcon: suffix),
      onChanged: onChanged,
    );
  }
}
