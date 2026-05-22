import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:intl/intl.dart';
import 'package:nullability/nullability.dart';
import 'package:search_protocol/search_protocol.dart';

class PageMetadataChips extends HookWidget {
  final PageMetadata metadata;

  const PageMetadataChips({super.key, required this.metadata});

  @override
  Widget build(BuildContext context) {
    final chips = useMemoized(() {
      final chips = <Widget>[];

      final parsedDate = metadata.date.mapNotNull(DateTime.tryParse);

      if (parsedDate != null) {
        chips.add(
          Chip(
            avatar: const Icon(Icons.calendar_month),
            label: Text(DateFormat.yMMMd().format(parsedDate)),
          ),
        );
      }

      if (metadata.sitename case final String sitename
          when sitename.isNotEmpty) {
        chips.add(
          Chip(avatar: const Icon(MdiIcons.domain), label: Text(sitename)),
        );
      }

      if (metadata.author case final String author when author.isNotEmpty) {
        chips.add(Chip(avatar: const Icon(Icons.person), label: Text(author)));
      }

      if (metadata.license case final String license when license.isNotEmpty) {
        chips.add(
          Chip(avatar: const Icon(MdiIcons.license), label: Text(license)),
        );
      }

      return chips;
    });

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(spacing: 8, runSpacing: 8, children: chips);
  }
}
