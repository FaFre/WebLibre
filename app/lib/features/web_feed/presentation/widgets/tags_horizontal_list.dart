import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/features/web_feed/data/models/feed_category.dart';

class TagsHorizontalList extends StatelessWidget {
  late final List<Widget> _tags;

  TagsHorizontalList({
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
