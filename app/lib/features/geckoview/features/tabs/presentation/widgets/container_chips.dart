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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_view_controllers.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/container_filter.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/gecko_inference.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/container_title.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/tab_drag_container_target.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/widgets/selectable_chips.dart';

class ContainerChips extends HookConsumerWidget {
  final bool displayMenu;
  final bool showUnassignedChip;
  final bool showGroupSuggestions;

  final ContainerData? selectedContainer;
  final bool Function(ContainerDataWithCount)? containerFilter;
  final int Function(ContainerDataWithCount?)? containerBadgeCount;
  final void Function(ContainerDataWithCount?)? onSelected;
  final void Function(ContainerDataWithCount)? onDeleted;
  final void Function(ContainerDataWithCount)? onLongPress;

  final ValueListenable<TextEditingValue>? searchTextListenable;

  const ContainerChips({
    required this.selectedContainer,
    required this.onSelected,
    required this.onDeleted,
    this.onLongPress,
    this.containerFilter,
    this.containerBadgeCount,
    this.searchTextListenable,
    this.displayMenu = true,
    this.showUnassignedChip = true,
    this.showGroupSuggestions = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchText = useListenableSelector(
      searchTextListenable,
      () => searchTextListenable?.value.text,
    );

    final containersAsync = ref.watch(
      matchSortedContainersWithCountProvider(searchText),
    );

    return containersAsync.when(
      skipLoadingOnReload: true,
      data: (containers) {
        final availableContainers =
            containerFilter.mapNotNull(
              (filter) => containers.where(filter).toList(),
            ) ??
            containers;

        if (selectedContainer == null &&
            availableContainers.isEmpty &&
            !displayMenu) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: 48,
          child: Row(
            children: [
              Expanded(
                child: SelectableChips(
                  enableDelete: false,
                  itemId: (container) => container.id,
                  itemBackgroundColor: (container) =>
                      container.color.withValues(alpha: 0.33),
                  itemLabel: (container) =>
                      ContainerTitle(container: container),
                  itemBadgeCount: (container) =>
                      containerBadgeCount?.call(container) ??
                      container.tabCount,
                  itemWrap: (child, container) {
                    return TabDragContainerTarget(
                      container: container,
                      child: child,
                    );
                  },
                  prefixListItems: [
                    if (showUnassignedChip)
                      TabDragContainerTarget(
                        container: null,
                        child: Consumer(
                          builder: (context, ref, child) {
                            final int tabCount =
                                containerBadgeCount?.call(null) ??
                                ref.watch(
                                  containerTabCountProvider(
                                    // ignore: provider_parameters
                                    ContainerFilterById(containerId: null),
                                  ).select((value) => value.value ?? 0),
                                );

                            return FilterChip(
                              avatar: const Icon(MdiIcons.folderHidden),
                              labelPadding: (tabCount > 0)
                                  ? null
                                  : const EdgeInsets.only(right: 2.0),
                              label: (tabCount > 0)
                                  ? Text(tabCount.toString())
                                  : const SizedBox.shrink(),
                              selected: selectedContainer == null,
                              showCheckmark: false,
                              onSelected: (value) {
                                if (value) {
                                  onSelected?.call(null);
                                }
                              },
                            );
                          },
                        ),
                      ),
                    if (showGroupSuggestions)
                      Consumer(
                        builder: (context, ref, child) {
                          final tabSuggestionsEnabled = ref.watch(
                            tabSuggestionsControllerProvider,
                          );
                          final enableAiFeatures = ref.watch(
                            generalSettingsWithDefaultsProvider.select(
                              (settings) => settings.enableLocalAiFeatures,
                            ),
                          );

                          if (!enableAiFeatures || !tabSuggestionsEnabled) {
                            return const SizedBox.shrink();
                          }

                          final suggestions = ref.watch(
                            suggestClustersProvider,
                          );

                          return suggestions.when(
                            skipLoadingOnReload: true,
                            data: (data) {
                              if (data.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              return FilterChip(
                                avatar: const Icon(MdiIcons.autoFix),
                                label: Text(data!.length.toString()),
                                showCheckmark: false,
                                onSelected: (_) async {
                                  await const ContainerDraftRoute().push(
                                    context,
                                  );
                                },
                              );
                            },
                            error: (error, stackTrace) {
                              logger.e(
                                'Error suggesting containers',
                                error: error,
                                stackTrace: stackTrace,
                              );
                              return const SizedBox.shrink();
                            },
                            loading: () {
                              return const FilterChip(
                                avatar: Icon(MdiIcons.autoFix),
                                label: Skeletonizer(child: Text('0')),
                                showCheckmark: false,
                                onSelected: null,
                              );
                            },
                          );
                        },
                      ),
                  ],
                  availableItems: availableContainers,
                  selectedItem: selectedContainer,
                  onSelected: onSelected,
                  onDeleted: onDeleted,
                  onLongPress: onLongPress,
                ),
              ),
              if (displayMenu)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () async {
                    await const ContainerListRoute().push(context);
                  },
                  icon: const Icon(Icons.chevron_right),
                ),
            ],
          ),
        );
      },
      error: (error, stackTrace) => const SizedBox.shrink(),
      loading: () => const SizedBox(height: 48, width: double.infinity),
    );
  }
}
