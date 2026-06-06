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

/// Reusable editor for a list of unique string entries: a labelled input field
/// with an add button, followed by the current entries each with a delete
/// action.
///
/// Entries are passed through [normalize] before being added; returning null
/// rejects the input (e.g. an unparseable value), and duplicates are ignored.
class StringListEditor extends HookWidget {
  final List<String> values;
  final ValueChanged<List<String>> onChanged;

  /// Hint shown in the input field.
  final String hintText;

  /// Leading icon for each entry row.
  final IconData itemIcon;

  /// Message shown when the list is empty.
  final String emptyLabel;

  /// Canonicalises raw input before adding. Returns null to reject the value.
  final String? Function(String input) normalize;

  const StringListEditor({
    required this.values,
    required this.onChanged,
    required this.hintText,
    required this.normalize,
    this.itemIcon = Icons.link,
    this.emptyLabel = 'Nothing added yet.',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    // Rebuild the add button's enabled state as the field changes.
    useListenable(controller);

    void add() {
      final normalized = normalize(controller.text);
      if (normalized == null) return;
      if (!values.contains(normalized)) {
        onChanged([...values, normalized]);
      }
      controller.clear();
    }

    void remove(String value) {
      onChanged(values.where((v) => v != value).toList());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => add(),
                  decoration: InputDecoration(
                    hintText: hintText,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                icon: const Icon(Icons.add),
                tooltip: 'Add',
                onPressed: controller.text.trim().isEmpty ? null : add,
              ),
            ],
          ),
        ),
        if (values.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              emptyLabel,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          )
        else
          for (final value in values)
            ListTile(
              leading: Icon(itemIcon),
              title: Text(value),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Remove',
                onPressed: () => remove(value),
              ),
            ),
      ],
    );
  }
}
