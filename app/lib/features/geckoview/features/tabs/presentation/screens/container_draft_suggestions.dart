import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/core/uuid.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/sheets/view_tabs.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_preview.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/gecko_inference.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';
import 'package:weblibre/presentation/widgets/selectable_chips.dart';

class ContainerDraftSuggestionsScreen extends HookConsumerWidget {
  const ContainerDraftSuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionsAsync = ref.watch(suggestClustersProvider);

    final selectedContainer = useState<SuggestedContainer?>(null);
    final selectedContainerTabs = useState(<SuggestedContainer, Set<String>>{});

    final selectedTabs = selectedContainer.value != null
        ? selectedContainerTabs.value[selectedContainer.value!]
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Draft Containers')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: suggestionsAsync.when(
            data: (suggestions) {
              final screenWidth = MediaQuery.of(context).size.width;

              final crossAxisCount = useMemoized(() {
                final calculatedCount = calculateCrossAxisItemCount(
                  screenWidth: screenWidth,
                  horizontalPadding: 4.0,
                  crossAxisSpacing: 8.0,
                );

                return math.max(
                  math.min(
                    calculatedCount,
                    selectedContainer.value?.tabIds.length ?? 0,
                  ),
                  2,
                );
              }, [screenWidth, selectedContainer.value?.tabIds.length]);

              return Column(
                children: [
                  SizedBox(
                    height: 48,
                    child: SelectableChips(
                      deleteIcon: false,
                      itemId: (container) => container,
                      itemAvatar: (container) =>
                          const Icon(MdiIcons.creation, size: 20),
                      itemLabel: (container) =>
                          Text(container.topic ?? 'Untitled'),
                      itemBadgeCount: (container) => container.tabIds.length,
                      availableItems: suggestions!,
                      selectedItem: selectedContainer.value,
                      onSelected: (item) {
                        selectedContainer.value = item;
                      },
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 4),
                  if (selectedContainer.value != null)
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          //Sync values for itemHeight calculation _calculateItemHeight
                          childAspectRatio: 0.75,
                          mainAxisSpacing: 8.0,
                          crossAxisSpacing: 8.0,
                          crossAxisCount: crossAxisCount,
                        ),
                        itemCount: selectedContainer.value!.tabIds.length,
                        itemBuilder: (context, index) {
                          final tabId = selectedContainer.value!.tabIds[index];
                          final equatable = selectedContainer.value!;

                          return (selectedContainerTabs.value[equatable]
                                      ?.contains(tabId) ==
                                  true)
                              ? TabPreview(
                                  tabId: tabId,
                                  isActive: false,
                                  onDelete: () {
                                    selectedContainerTabs.value = {
                                      ...selectedContainerTabs.value,
                                      equatable: {
                                        ...?selectedContainerTabs
                                            .value[equatable],
                                      }..remove(tabId),
                                    };
                                  },
                                )
                              : SuggestedSingleTabPreview(
                                  tabId: tabId,
                                  activeTabId: null,
                                  onTap: () {
                                    selectedContainerTabs.value = {
                                      ...selectedContainerTabs.value,
                                      equatable: {
                                        ...?selectedContainerTabs
                                            .value[equatable],
                                        tabId,
                                      },
                                    };
                                  },
                                );
                        },
                      ),
                    ),
                ],
              );
            },
            error: (error, stackTrace) {
              return FailureWidget(
                title: 'Failed to create suggestions',
                onRetry: () {
                  ref.invalidate(suggestClustersProvider);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
      floatingActionButton: (selectedTabs?.isNotEmpty ?? false)
          ? FloatingActionButton(
              child: const Icon(MdiIcons.folderPlus),
              onPressed: () async {
                final initialColor = await ref
                    .read(containerRepositoryProvider.notifier)
                    .unusedRandomContainerColor();

                final initialContainer = ContainerData(
                  id: uuid.v7(),
                  color: initialColor,
                  name: selectedContainer.value?.topic,
                );

                if (context.mounted) {
                  final result = await ContainerCreateRoute(
                    initialContainer,
                  ).push<ContainerData?>(context);

                  if (result != null) {
                    for (final tab in selectedTabs!) {
                      await ref
                          .read(tabDataRepositoryProvider.notifier)
                          .assignContainer(tab, result);
                    }

                    selectedContainerTabs.value = {};
                    selectedContainer.value = null;
                  }
                }
              },
            )
          : null,
    );
  }
}
