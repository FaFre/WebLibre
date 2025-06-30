import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:weblibre/features/geckoview/domain/controllers/bottom_sheet.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/container_filter.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab_search.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/container_chips.dart';
import 'package:weblibre/presentation/hooks/listenable_callback.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';

class TabSearch extends HookConsumerWidget {
  static const _matchPrefix = '***';
  static const _matchSuffix = '***';

  final ValueListenable<TextEditingValue> searchTextListenable;

  const TabSearch({required this.searchTextListenable});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedContainer = useState<ContainerData?>(
      ref.read(
        selectedContainerDataProvider.select((value) => value.valueOrNull),
      ),
    );

    final tabs = ref
        .watch(
          seamlessFilteredTabPreviewsProvider(
            TabSearchPartition.search,
            (selectedContainer.value != null)
                ? ContainerFilterById(containerId: selectedContainer.value!.id)
                : ContainerFilterDisabled(),
          ),
        )
        .value;

    useListenableCallback(searchTextListenable, () async {
      await ref
          .read(tabSearchRepositoryProvider(TabSearchPartition.search).notifier)
          .addQuery(
            searchTextListenable.value.text,
            // ignore: avoid_redundant_argument_values dont break things
            matchPrefix: _matchPrefix,
            // ignore: avoid_redundant_argument_values dont break things
            matchSuffix: _matchSuffix,
          );
    });

    if (tabs.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return MultiSliver(
      children: [
        const SliverToBoxAdapter(child: Divider()),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tabs', style: Theme.of(context).textTheme.labelSmall),
                ContainerChips(
                  displayMenu: false,
                  selectedContainer: selectedContainer.value,
                  onSelected: (container) {
                    selectedContainer.value = container;
                  },
                  onDeleted: (container) {
                    selectedContainer.value = null;
                  },
                  containerFilter: (container) => (container.tabCount ?? 0) > 0,
                  searchTextListenable: searchTextListenable,
                ),
              ],
            ),
          ),
        ),
        SliverList.builder(
          itemCount: tabs.length,
          itemBuilder: (context, index) {
            final result = tabs[index];

            final urlHasMatch =
                result.highlightedUrl?.contains(_matchPrefix) ?? false;
            final bodyHasMatch =
                result.content?.contains(_matchPrefix) ?? false;

            return ListTile(
              leading: RepaintBoundary(
                child:
                    result.icon.mapNotNull(
                      (icon) =>
                          RawImage(image: icon.value, height: 24, width: 24),
                    ) ??
                    UrlIcon([result.url], iconSize: 24),
              ),
              title: result.title.mapNotNull(
                (title) => MarkdownBody(
                  data: title,
                  styleSheet: MarkdownStyleSheet(
                    p: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              subtitle: (bodyHasMatch || urlHasMatch)
                  ? MarkdownBody(
                      data: bodyHasMatch
                          ? result.content!
                          : result.highlightedUrl!,
                      styleSheet: MarkdownStyleSheet(
                        p: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        a: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    )
                  : Text(
                      result.url.toString(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
              onTap: () async {
                await ref
                    .read(tabRepositoryProvider.notifier)
                    .selectTab(result.id);

                if (context.mounted) {
                  ref.read(bottomSheetControllerProvider.notifier).dismiss();

                  context.pop();
                }
              },
            );
          },
        ),
      ],
    );
  }
}
