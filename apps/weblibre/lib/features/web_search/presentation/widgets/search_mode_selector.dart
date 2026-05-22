import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:search_backend/search_backend.dart';
import 'package:weblibre/features/search_credits/domain/repositories/web_search_settings.dart';

class SearchModeSelector extends ConsumerWidget {
  const SearchModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final searchMode = ref.watch(
      webSearchSettingsControllerProvider.select((s) => s.searchMode),
    );

    return MenuAnchor(
      builder: (context, controller, _) => InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => controller.isOpen ? controller.close() : controller.open(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_iconFor(searchMode), color: colorScheme.primary, size: 18),
              const SizedBox(width: 6),
              Text(
                _labelFor(searchMode),
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.arrow_drop_down_rounded,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
      menuChildren: [
        for (final mode in SearchMode.values)
          MenuItemButton(
            onPressed: () {
              ref
                  .read(webSearchSettingsControllerProvider.notifier)
                  .setSearchMode(mode);
            },
            leadingIcon: Icon(
              _iconFor(mode),
              size: 20,
              color: mode == searchMode
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
            trailingIcon: mode == searchMode
                ? Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: colorScheme.primary,
                  )
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _labelFor(mode),
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: mode == searchMode
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                Text(
                  _descriptionFor(mode),
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static IconData _iconFor(SearchMode mode) => switch (mode) {
    SearchMode.general => Icons.public,
    SearchMode.independentWeb => Icons.volunteer_activism,
    SearchMode.smallWeb => Icons.explore,
  };

  static String _labelFor(SearchMode mode) => switch (mode) {
    SearchMode.general => 'General',
    SearchMode.independentWeb => 'Independent Web',
    SearchMode.smallWeb => 'Small Web',
  };

  static String _descriptionFor(SearchMode mode) => switch (mode) {
    SearchMode.general => 'Balanced results across the open web',
    SearchMode.independentWeb => 'Favor smaller and less corporate sources',
    SearchMode.smallWeb => 'Independent, personal & niche sites',
  };
}
