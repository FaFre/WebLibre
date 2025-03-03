import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:lensai/extensions/nullable.dart';
import 'package:lensai/features/web_feed/data/models/feed_author.dart';

class AuthorsHorizontalList extends StatelessWidget {
  late final List<Widget> _authors;

  AuthorsHorizontalList({
    required List<FeedAuthor> authors,
    Set<String> selectedTags = const {},
    void Function(String tagId, bool value)? onTagSelected,
  }) {
    _authors =
        authors.map((author) {
          final label = Text(
            '${author.name ?? ''} ${author.email.mapNotNull((email) => '($email)') ?? ''}'
                .trim(),
          );

          return onTagSelected.mapNotNull(
                (onTagSelected) => FilterChip(
                  label: label,
                  selected: selectedTags.contains(author.name),
                  onSelected: (value) {
                    if (author.name.isNotEmpty) {
                      onTagSelected(author.name!, value);
                    }
                  },
                ),
              ) ??
              Chip(label: label);
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
            itemCount: _authors.length,
            controller: controller,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => _authors[index],
          );
        },
      ),
    );
  }
}
