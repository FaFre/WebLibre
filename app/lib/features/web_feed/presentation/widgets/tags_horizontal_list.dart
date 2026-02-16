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
import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/features/web_feed/data/models/feed_category.dart';

class TagsHorizontalList extends StatelessWidget {
  late final List<Widget> _tags;

  TagsHorizontalList({super.key, 
    required List<FeedCategory> tags,
    Set<String> selectedTags = const {},
    void Function(String tagId, bool value)? onTagSelected,
  }) {
    _tags = tags.map((tag) {
      final label = Text(
        '${tag.id} ${tag.title.mapNotNull((title) => '($title)') ?? ''}'.trim(),
      );

      return Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child:
            onTagSelected.mapNotNull(
              (onTagSelected) => FilterChip(
                label: label,
                selected: selectedTags.contains(tag.id),
                onSelected: (value) {
                  onTagSelected(tag.id, value);
                },
              ),
            ) ??
            Chip(label: label),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: FadingScroll(
        fadingSize: 15,
        builder: (context, controller) {
          return ListView.builder(
            itemCount: _tags.length,
            controller: controller,
            //Improve list performance by not rendering outside screen at all
            cacheExtent: 0,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => _tags[index],
          );
        },
      ),
    );
  }
}
