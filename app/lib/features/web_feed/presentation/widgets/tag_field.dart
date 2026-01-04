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
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

final _tagSplitPatter = RegExp(r'[,\s]+');

class TagField extends HookWidget {
  final Set<String> initialTags;
  final void Function(Set<String> tags) onTagsUpdate;

  const TagField({
    super.key,
    required this.initialTags,
    required this.onTagsUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final textController = useTextEditingController();
    final tags = useState(initialTags);

    useOnListenableChange(tags, () {
      onTagsUpdate(tags.value);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tags', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8.0,
          children: tags.value
              .map(
                (tag) => InputChip(
                  label: Text(tag),
                  onDeleted: () {
                    tags.value = {...tags.value}..remove(tag);
                  },
                ),
              )
              .toList(),
        ),
        TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'tag1, tag2, ...',
            prefixIcon: Icon(MdiIcons.tagMultiple),
          ),
          onChanged: (String value) {
            if (value.isNotEmpty) {
              final values = value.split(_tagSplitPatter);

              if (values.length > 1) {
                final trimmed = values
                    .map((str) => str.trim())
                    .where((str) => str.isNotEmpty);

                if (trimmed.isNotEmpty) {
                  textController.clear();

                  tags.value = {...tags.value, ...trimmed};
                }
              }
            }
          },
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              final values = value
                  .split(_tagSplitPatter)
                  .map((str) => str.trim())
                  .where((str) => str.isNotEmpty)
                  .toList();

              if (values.isNotEmpty) {
                textController.clear();

                tags.value = {...tags.value, ...values};
              }
            }
          },
        ),
      ],
    );
  }
}
