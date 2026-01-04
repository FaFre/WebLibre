import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/browser_data.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_view_controllers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/dialogs/clear_container_data_dialog.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/dialogs/close_all_private_tabs_dialog.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/dialogs/close_all_tabs_dialog.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/dialogs/enable_ai_tab_suggestions_dialog.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab_search.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/container_chips.dart';
import 'package:weblibre/features/tor/presentation/controllers/start_tor_proxy.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/hooks/menu_controller.dart';
import 'package:weblibre/presentation/widgets/speech_to_text_button.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

class TabViewHeader extends HookConsumerWidget {
  static const headerSize = 124.0;

  final TabsViewMode tabsViewMode;
  final VoidCallback onClose;

  const TabViewHeader({required this.onClose, required this.tabsViewMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchMode = useState(false);
    final searchTextFocus = useFocusNode();
    final searchTextController = useTextEditingController();

    final viewModeMenuController = useMenuController();
    final tabsActionMenuController = useMenuController();

    final hasSearchText = useListenableSelector(
      searchTextController,
      () => searchTextController.text.isNotEmpty,
    );

    final enableAiFeatures = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (settings) => settings.enableLocalAiFeatures,
      ),
    );

    useOnListenableChange(searchTextController, () async {
      if (ref.exists(tabSearchRepositoryProvider(TabSearchPartition.preview))) {
        await ref
            .read(
              tabSearchRepositoryProvider(TabSearchPartition.preview).notifier,
            )
            .addQuery(searchTextController.text);
      }
    });

    return Material(
      //Fix layout issue https://github.com/flutter/flutter/issues/78748#issuecomment-1194680555
      child: Align(
        child: Padding(
          padding: const EdgeInsets.only(right: 8.0, left: 8.0, top: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!searchMode.value)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(MdiIcons.tabSearch),
                          iconSize: 18,
                          padding: EdgeInsets.zero,
                          tooltip: 'Search inside tabs',
                          onPressed: () {
                            switch (ref.read(tabsViewModeControllerProvider)) {
                              case TabsViewMode.tree:
                              case TabsViewMode.list:
                                break;
                              case TabsViewMode.grid:
                                ref
                                    .read(
                                      tabsViewModeControllerProvider.notifier,
                                    )
                                    .set(TabsViewMode.list);
                            }

                            searchMode.value = true;
                            searchTextFocus.requestFocus();
                          },
                        ),
                        const SizedBox(
                          height: 32,
                          child: VerticalDivider(indent: 4, endIndent: 4),
                        ),
                        MenuAnchor(
                          controller: viewModeMenuController,
                          menuChildren: TabsViewMode.values
                              .map(
                                (mode) => MenuItemButton(
                                  leadingIcon: Icon(mode.icon),
                                  child: Text(mode.label),
                                  onPressed: () {
                                    ref
                                        .read(
                                          tabsViewModeControllerProvider
                                              .notifier,
                                        )
                                        .set(mode);
                                  },
                                ),
                              )
                              .toList(),
                          child: IconButton(
                            tooltip: 'Change view mode',
                            onPressed: () {
                              if (viewModeMenuController.isOpen) {
                                viewModeMenuController.close();
                              } else {
                                viewModeMenuController.open();
                              }
                            },
                            icon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(tabsViewMode.icon, size: 18),
                                const Icon(Icons.arrow_drop_down, size: 18),
                              ],
                            ),
                          ),
                        ),
                        if (enableAiFeatures &&
                            switch (tabsViewMode) {
                              TabsViewMode.list || TabsViewMode.grid => true,
                              TabsViewMode.tree => false,
                            })
                          Consumer(
                            builder: (context, ref, child) {
                              final tabSuggestionsEnabled = ref.watch(
                                tabSuggestionsControllerProvider,
                              );
                              final downloadProgress = ref.watch(
                                mlDownloadStateProvider,
                              );

                              return Badge(
                                isLabelVisible: downloadProgress != null,
                                offset: const Offset(-2, 2),
                                label: downloadProgress != null
                                    ? Text(
                                        '${downloadProgress.progress.toInt()}%',
                                        style: const TextStyle(fontSize: 10),
                                      )
                                    : null,
                                child: IconButton.filledTonal(
                                  icon: const Icon(MdiIcons.imageAutoAdjust),
                                  isSelected: tabSuggestionsEnabled,
                                  iconSize: 18,
                                  padding: EdgeInsets.zero,
                                  tooltip: downloadProgress != null
                                      ? 'Downloading AI models (${downloadProgress.progress.toInt()}%)'
                                      : tabSuggestionsEnabled
                                      ? 'Disable AI tab suggestions'
                                      : 'Enable AI tab suggestions',
                                  onPressed: () async {
                                    if (!tabSuggestionsEnabled) {
                                      final result =
                                          await showEnableAiTabSuggestionsDialog(
                                            context,
                                          );

                                      if (result == true) {
                                        ref
                                            .read(
                                              tabSuggestionsControllerProvider
                                                  .notifier,
                                            )
                                            .enable();
                                      }
                                    } else {
                                      ref
                                          .read(
                                            tabSuggestionsControllerProvider
                                                .notifier,
                                          )
                                          .disable();
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                        if (switch (tabsViewMode) {
                          TabsViewMode.list || TabsViewMode.grid => true,
                          TabsViewMode.tree => false,
                        })
                          Consumer(
                            builder: (context, ref, child) {
                              final tabsReorderabe = ref.watch(
                                tabsReorderableControllerProvider,
                              );

                              return IconButton.filledTonal(
                                icon: const Icon(
                                  MdiIcons.orderNumericAscending,
                                ),
                                isSelected: tabsReorderabe,
                                iconSize: 18,
                                padding: EdgeInsets.zero,
                                tooltip: tabsReorderabe
                                    ? 'Disable reordering mode'
                                    : 'Enable reordering mode',
                                onPressed: () {
                                  final wasEnabled = tabsReorderabe;

                                  ref
                                      .read(
                                        tabsReorderableControllerProvider
                                            .notifier,
                                      )
                                      .toggle();

                                  // Show info when enabling reordering
                                  if (!wasEnabled && context.mounted) {
                                    ui_helper.showInfoMessage(
                                      context,
                                      'Drag and drop tabs to reorder them',
                                    );
                                  }
                                },
                              );
                            },
                          ),
                      ],
                    ),
                    MenuAnchor(
                      controller: tabsActionMenuController,
                      menuChildren: [
                        MenuItemButton(
                          leadingIcon: const Icon(MdiIcons.bookmarkPlusOutline),
                          child: const Text('Bookmark all'),
                          onPressed: () async {
                            final containerId = ref.read(
                              selectedContainerProvider,
                            );

                            final tabData = await ref
                                .read(tabDataRepositoryProvider.notifier)
                                .getContainerTabsData(containerId);

                            for (final tab in tabData) {
                              if (context.mounted) {
                                await BookmarkEntryAddRoute(
                                  bookmarkInfo: jsonEncode(
                                    BookmarkInfo(
                                      title: tab.title,
                                      url: tab.url.toString(),
                                    ).encode(),
                                  ),
                                ).push(context);
                              }
                            }
                          },
                        ),
                        MenuItemButton(
                          leadingIcon: const Icon(MdiIcons.closeCircle),
                          child: const Text('Close All Tabs'),
                          onPressed: () async {
                            final result = await showCloseAllTabsDialog(
                              context,
                            );

                            if (result == true) {
                              final container = ref.read(
                                selectedContainerProvider,
                              );

                              final count = await ref
                                  .read(tabDataRepositoryProvider.notifier)
                                  .closeContainerTabs(container);

                              if (context.mounted) {
                                ui_helper.showTabUndoClose(
                                  context,
                                  ref
                                      .read(tabRepositoryProvider.notifier)
                                      .undoClose,
                                  count: count.length,
                                );
                              }
                            }
                          },
                        ),
                        MenuItemButton(
                          leadingIcon: const Icon(MdiIcons.incognitoCircleOff),
                          child: const Text('Close Private Tabs'),
                          onPressed: () async {
                            final result = await showCloseAllPrivateTabsDialog(
                              context,
                            );

                            if (result == true) {
                              final container = ref.read(
                                selectedContainerProvider,
                              );

                              final count = await ref
                                  .read(tabDataRepositoryProvider.notifier)
                                  .closeContainerTabs(
                                    container,
                                    includeRegular: false,
                                  );

                              if (context.mounted) {
                                ui_helper.showTabUndoClose(
                                  context,
                                  ref
                                      .read(tabRepositoryProvider.notifier)
                                      .undoClose,
                                  count: count.length,
                                );
                              }
                            }
                          },
                        ),
                        Consumer(
                          builder: (context, ref, child) {
                            final selectedContainer = ref.watch(
                              selectedContainerDataProvider.select(
                                (value) => value.value,
                              ),
                            );

                            // Only show if container has cookie isolation
                            if (selectedContainer
                                    ?.metadata
                                    .contextualIdentity ==
                                null) {
                              return const SizedBox.shrink();
                            }

                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Divider(),
                                MenuItemButton(
                                  closeOnActivate: false,
                                  leadingIcon: const Icon(
                                    MdiIcons.databaseRemove,
                                  ),
                                  child: const Text('Clear Container Data'),
                                  onPressed: () async {
                                    final containerId = selectedContainer!.id;
                                    final tabs = await ref
                                        .read(
                                          tabDataRepositoryProvider.notifier,
                                        )
                                        .getContainerTabsData(containerId);

                                    if (!context.mounted) return;

                                    final result =
                                        await showClearContainerDataDialog(
                                          context,
                                          tabs.length,
                                        );

                                    if (result?.confirmed == true) {
                                      final shouldReopenTabs =
                                          result!.reopenTabs;

                                      try {
                                        final closedTabIds = await ref
                                            .read(
                                              tabDataRepositoryProvider
                                                  .notifier,
                                            )
                                            .closeContainerTabs(containerId);

                                        await ref
                                            .read(
                                              browserDataServiceProvider
                                                  .notifier,
                                            )
                                            .clearDataForContext(
                                              selectedContainer
                                                  .metadata
                                                  .contextualIdentity!,
                                            );

                                        if (shouldReopenTabs) {
                                          await ref
                                              .read(
                                                tabRepositoryProvider.notifier,
                                              )
                                              .addMultipleTabs(
                                                tabs: tabs.map((tab) {
                                                  var parentId = tab.parentId;
                                                  while (parentId != null &&
                                                      closedTabIds.contains(
                                                        parentId,
                                                      )) {
                                                    parentId = tabs
                                                        .firstWhereOrNull(
                                                          (old) =>
                                                              old.id ==
                                                              parentId,
                                                        )
                                                        ?.parentId;
                                                  }

                                                  return AddTabParams(
                                                    url: tab.url.toString(),
                                                    startLoading: true,
                                                    parentId: parentId,
                                                    private:
                                                        tab.isPrivate ?? false,
                                                    flags: LoadUrlFlags.NONE
                                                        .toValue(),
                                                    source: Internal.newTab
                                                        .toValue(),
                                                    contextId: selectedContainer
                                                        .metadata
                                                        .contextualIdentity,
                                                  );
                                                }).toList(),
                                                container: Value(
                                                  selectedContainer,
                                                ),
                                              );
                                        }

                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                shouldReopenTabs
                                                    ? 'Container data cleared successfully'
                                                    : 'Container data cleared. ${tabs.length} tab(s) closed.',
                                              ),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Error clearing data: $e',
                                              ),
                                              backgroundColor: Theme.of(
                                                context,
                                              ).colorScheme.error,
                                            ),
                                          );
                                        }
                                      }
                                    }

                                    if (context.mounted) {
                                      MenuController.maybeOf(context)?.close();
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                      child: IconButton(
                        tooltip: 'Tab actions',
                        onPressed: () {
                          if (tabsActionMenuController.isOpen) {
                            tabsActionMenuController.close();
                          } else {
                            tabsActionMenuController.open();
                          }
                        },
                        icon: const Icon(MdiIcons.dotsVertical),
                      ),
                    ),
                  ],
                )
              else
                TextField(
                  controller: searchTextController,
                  focusNode: searchTextFocus,
                  // enableIMEPersonalizedLearning: !incognitoEnabled,
                  decoration: InputDecoration(
                    // border: InputBorder.none,
                    prefixIcon: const Icon(MdiIcons.tabSearch, size: 18),
                    hintText: 'Search inside tabs...',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!hasSearchText)
                          SpeechToTextButton(
                            onTextReceived: (data) {
                              searchTextController.text = data.toString();
                            },
                          ),
                        IconButton(
                          onPressed: () {
                            searchTextController.clear();
                            searchTextFocus.requestFocus();
                            searchMode.value = false;
                          },
                          icon: const Icon(Icons.clear),
                        ),
                      ],
                    ),
                  ),
                ),
              Consumer(
                builder: (context, ref, child) {
                  final selectedContainer = ref.watch(
                    selectedContainerDataProvider.select(
                      (value) => value.value,
                    ),
                  );

                  return ContainerChips(
                    showGroupSuggestions: switch (tabsViewMode) {
                      TabsViewMode.list || TabsViewMode.grid => true,
                      TabsViewMode.tree => false,
                    },
                    enableDragAndDrop: switch (tabsViewMode) {
                      TabsViewMode.list || TabsViewMode.grid => true,
                      TabsViewMode.tree => false,
                    },
                    selectedContainer: selectedContainer,
                    onSelected: (container) async {
                      if (container != null) {
                        final result = await ref
                            .read(selectedContainerProvider.notifier)
                            .setContainerId(container.id);

                        if (context.mounted &&
                            result == SetContainerResult.successHasProxy) {
                          await ref
                              .read(startProxyControllerProvider.notifier)
                              .maybeStartProxy(context);
                        }
                      } else {
                        ref
                            .read(selectedContainerProvider.notifier)
                            .clearContainer();
                      }
                    },
                    onDeleted: (container) {
                      ref
                          .read(selectedContainerProvider.notifier)
                          .clearContainer();
                    },
                    onLongPress: (container) async {
                      await ContainerEditRoute(
                        containerData: jsonEncode(container.toJson()),
                      ).push(context);
                    },
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
