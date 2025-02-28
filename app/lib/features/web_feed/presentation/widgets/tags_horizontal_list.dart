import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:lensai/extensions/nullable.dart';
import 'package:lensai/features/web_feed/data/models/feed_category.dart';

class TagsHorizontalList extends StatelessWidget {
  late final List<Widget> _tags;

  TagsHorizontalList({
    required List<FeedCategory> tags,
    Set<String> selectedTags = const {},
    void Function(String tagId, bool value)? onTagSelected,
  }) {
    _tags =
        tags
            .map(
              (tag) => Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(
                    '${tag.id} ${tag.title.mapNotNull((title) => '($title)') ?? ''}'
                        .trim(),
                  ),
                  selected: selectedTags.contains(tag.id),
                  onSelected: onTagSelected.mapNotNull(
                    (onTagSelected) => (value) {
                      onTagSelected(tag.id, value);
                    },
                  ),
                ),
              ),
            )
            .toList();
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
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => _tags[index],
          );
        },
      ),
    );
  }
}
