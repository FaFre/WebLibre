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
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_suggestions.dart';
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
  final bool showGroupSuggestions;

  final ContainerData? selectedContainer;
  final bool Function(ContainerDataWithCount)? containerFilter;
  final void Function(ContainerDataWithCount?)? onSelected;
  final void Function(ContainerDataWithCount)? onDeleted;

  final ValueListenable<TextEditingValue>? searchTextListenable;

  const ContainerChips({
    required this.selectedContainer,
    required this.onSelected,
    required this.onDeleted,
    this.containerFilter,
    this.searchTextListenable,
    this.displayMenu = true,
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
              if (selectedContainer != null || availableContainers.isNotEmpty)
                Expanded(
                  child: SelectableChips(
                    deleteIcon: false,
                    itemId: (container) => container.id,
                    itemAvatar: (container) => Container(
                      width: 20.0,
                      height: 20.0,
                      decoration: BoxDecoration(
                        color: container.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    itemLabel: (container) =>
                        ContainerTitle(container: container),
                    itemBadgeCount: (container) => container.tabCount,
                    itemWrap: (child, container) {
                      return TabDragContainerTarget(
                        container: container,
                        child: child,
                      );
                    },
                    prefixListItems: [
                      TabDragContainerTarget(
                        container: null,
                        child: Consumer(
                          builder: (context, ref, child) {
                            final tabCount = ref.watch(
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
                              data: (data) {
                                if (data.isEmpty) {
                                  return const SizedBox.shrink();
                                }

                                return FilterChip(
                                  avatar: const Icon(MdiIcons.autoFix),
                                  label: Text(data!.length.toString()),
                                  showCheckmark: false,
                                  onSelected: (value) {},
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
                                return const SizedBox.shrink();
                              },
                            );
                          },
                        ),
                    ],
                    availableItems: availableContainers,
                    selectedItem: selectedContainer,
                    onSelected: onSelected,
                    onDeleted: onDeleted,
                  ),
                )
              else
                Visibility(
                  visible: displayMenu,
                  child: Expanded(
                    child: Text(
                      "Press '>' to manage Containers.",
                      style: TextStyle(
                        color: Theme.of(context).hintColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              if (displayMenu)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () async {
                    await ContainerListRoute().push(context);
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
