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
import 'dart:async';

import 'package:collection/collection.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/controllers/bottom_sheet.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/find_in_page/domain/entities/find_in_page_state.dart';
import 'package:weblibre/features/geckoview/features/find_in_page/presentation/controllers/find_in_page.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/container_filter.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab_search.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/container_chips.dart';
import 'package:weblibre/presentation/widgets/uri_breadcrumb.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';
import 'package:weblibre/utils/text_highlight.dart';

class TabSearch extends HookConsumerWidget {
  static const _matchPrefix = '***';
  static const _matchSuffix = '***';

  final ValueListenable<TextEditingValue> searchTextListenable;

  const TabSearch({required this.searchTextListenable});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedContainer = useState<ContainerData?>(
      ref.read(selectedContainerDataProvider.select((value) => value.value)),
    );

    final tabSearchResults = ref.watch(
      filteredTabPreviewsProvider(
        TabSearchPartition.search,
        // ignore: provider_parameters
        ContainerFilterDisabled(),
      ),
    );

    final containerIdsWithResults = useMemoized(
      () => EquatableValue(
        tabSearchResults.value
            .map((result) => result.containerId)
            .fold(
              <String?, int>{},
              (map, id) =>
                  map..update(id, (value) => ++value, ifAbsent: () => 1),
            ),
      ),
      [tabSearchResults],
    );

    final filteredTabs = useMemoized(
      () => tabSearchResults.value
          .where((result) => result.containerId == selectedContainer.value?.id)
          .toList(),
      [tabSearchResults, selectedContainer.value?.id],
    );

    unawaited(
      useValueChanged(containerIdsWithResults, (_, _) async {
        if (containerIdsWithResults.value.isNotEmpty &&
            !containerIdsWithResults.value.containsKey(
              selectedContainer.value?.id,
            )) {
          selectedContainer.value = await ref
              .read(containerRepositoryProvider.notifier)
              .getAllContainersWithCount()
              .then((containers) {
                return containers.firstWhereOrNull(
                  (container) =>
                      !container.metadata.authSettings.authenticationRequired &&
                      containerIdsWithResults.value.containsKey(container.id),
                );
              });
        }
      }),
    );

    useOnListenableChange(searchTextListenable, () async {
      if (ref.exists(tabSearchRepositoryProvider(TabSearchPartition.search))) {
        await ref
            .read(
              tabSearchRepositoryProvider(TabSearchPartition.search).notifier,
            )
            .addQuery(
              searchTextListenable.value.text,
              // ignore: avoid_redundant_argument_values dont break things
              matchPrefix: _matchPrefix,
              // ignore: avoid_redundant_argument_values dont break things
              matchSuffix: _matchSuffix,
            );
      }
    });

    if (tabSearchResults.value.isEmpty) {
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
                  showUnassignedChip: containerIdsWithResults.value.containsKey(
                    null,
                  ),
                  onSelected: (container) async {
                    if (container != null) {
                      if (await ref
                          .read(selectedContainerProvider.notifier)
                          .authenticateContainer(container)) {
                        selectedContainer.value = container;
                      }
                    } else {
                      selectedContainer.value = container;
                    }
                  },
                  onDeleted: (container) {
                    selectedContainer.value = null;
                  },
                  containerFilter: (container) =>
                      containerIdsWithResults.value.containsKey(container.id),
                  containerBadgeCount: (container) =>
                      containerIdsWithResults.value[container?.id] ?? 0,
                  searchTextListenable: searchTextListenable,
                ),
              ],
            ),
          ),
        ),
        SliverList.builder(
          itemCount: filteredTabs.length,
          itemBuilder: (context, index) {
            final result = filteredTabs[index];

            final content =
                (result.extractedContent?.contains(_matchPrefix) == true)
                ? result.extractedContent
                : result.fullContent;

            final titleHasMatch = result.title.contains(_matchPrefix);
            final urlHasMatch =
                result.highlightedUrl?.contains(_matchPrefix) ?? false;
            final bodyHasMatch = content?.contains(_matchPrefix) ?? false;

            return ListTile(
              leading: RepaintBoundary(
                child:
                    result.icon.mapNotNull(
                      (icon) => icon.value.mapNotNull(
                        (image) =>
                            RawImage(image: image, height: 24, width: 24),
                      ),
                    ) ??
                    UrlIcon([result.url], iconSize: 24),
              ),
              title: result.title.mapNotNull(
                (title) => Text.rich(
                  buildHighlightedText(
                    title,
                    Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    _matchPrefix,
                    _matchSuffix,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              subtitle: (bodyHasMatch || (urlHasMatch && !titleHasMatch))
                  ? Text.rich(
                      buildHighlightedText(
                        (bodyHasMatch ? content! : result.highlightedUrl!),
                        Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                        _matchPrefix,
                        _matchSuffix,
                        normalizeWhitespaces: true,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    )
                  : UriBreadcrumb(uri: result.url),
              onTap: () async {
                await ref
                    .read(tabRepositoryProvider.notifier)
                    .selectTab(result.id);
                if (result.sourceSearchQuery.isNotEmpty &&
                    ref.read(findInPageControllerProvider(result.id)) ==
                        FindInPageState.hidden()) {
                  await ref
                      .read(findInPageControllerProvider(result.id).notifier)
                      .findAll(text: result.sourceSearchQuery!);
                }

                if (context.mounted) {
                  ref
                      .read(bottomSheetControllerProvider.notifier)
                      .requestDismiss();

                  const BrowserRoute().go(context);
                }
              },
            );
          },
        ),
      ],
    );
  }
}
