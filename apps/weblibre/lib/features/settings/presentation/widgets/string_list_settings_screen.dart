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
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/settings/presentation/widgets/string_list_editor.dart';

/// Settings sub-screen that manages a list of unique string entries: an
/// optional description followed by a [StringListEditor]. Callers own the
/// state — pass [values] and handle persistence in [onChanged] — keeping this
/// screen provider-agnostic and reusable across features (e.g. gesture-excluded
/// sites, per-site desktop mode).
class StringListSettingsScreen extends StatelessWidget {
  final String title;

  /// Optional explanatory text shown above the editor.
  final String? description;

  final List<String> values;
  final ValueChanged<List<String>> onChanged;

  /// Hint shown in the add field.
  final String hintText;

  /// Canonicalises raw input before adding. Returns null to reject the value.
  final String? Function(String input) normalize;

  /// Leading icon for each entry row.
  final IconData itemIcon;

  /// Message shown when the list is empty.
  final String emptyLabel;

  const StringListSettingsScreen({
    required this.title,
    required this.values,
    required this.onChanged,
    required this.hintText,
    required this.normalize,
    this.description,
    this.itemIcon = Icons.link,
    this.emptyLabel = 'Nothing added yet.',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsCustomScrollScaffold(
      title: title,
      slivers: [
        if (description != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: StringListEditor(
            values: values,
            hintText: hintText,
            itemIcon: itemIcon,
            emptyLabel: emptyLabel,
            normalize: normalize,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
