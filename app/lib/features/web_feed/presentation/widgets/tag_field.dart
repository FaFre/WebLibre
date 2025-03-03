import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:lensai/presentation/hooks/listenable_callback.dart';

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

    useListenableCallback(tags, () {
      onTagsUpdate(tags.value);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tags', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8.0,
          children:
              tags.value
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
              final values =
                  value
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
