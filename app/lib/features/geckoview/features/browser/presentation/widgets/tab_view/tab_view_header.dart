import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_view_controllers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab_search.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/container_chips.dart';
import 'package:weblibre/features/tor/presentation/controllers/start_tor_proxy.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/hooks/listenable_callback.dart';
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

    useListenableCallback(searchTextController, () async {
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

                              return IconButton.filledTonal(
                                icon: const Icon(MdiIcons.imageAutoAdjust),
                                isSelected: tabSuggestionsEnabled,
                                iconSize: 18,
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  ref
                                      .read(
                                        tabSuggestionsControllerProvider
                                            .notifier,
                                      )
                                      .toggle();
                                },
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
                                onPressed: () {
                                  ref
                                      .read(
                                        tabsReorderableControllerProvider
                                            .notifier,
                                      )
                                      .toggle();
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
                            final result = await showDialog<bool?>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  icon: const Icon(Icons.warning),
                                  title: const Text('Close All Tabs'),
                                  content: const Text(
                                    'Are you sure you want to close all displayed tabs?',
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, false);
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, true);
                                      },
                                      child: const Text('Close'),
                                    ),
                                  ],
                                );
                              },
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
                                  count: count,
                                );
                              }
                            }
                          },
                        ),
                        MenuItemButton(
                          leadingIcon: const Icon(MdiIcons.incognitoCircleOff),
                          child: const Text('Close Private Tabs'),
                          onPressed: () async {
                            final result = await showDialog<bool?>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  icon: const Icon(Icons.warning),
                                  title: const Text('Close All Private Tabs'),
                                  content: const Text(
                                    'Are you sure you want to close all displayed private tabs?',
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, false);
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, true);
                                      },
                                      child: const Text('Close'),
                                    ),
                                  ],
                                );
                              },
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
                                  count: count,
                                );
                              }
                            }
                          },
                        ),
                      ],
                      child: IconButton(
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
              if (switch (tabsViewMode) {
                TabsViewMode.list || TabsViewMode.grid => true,
                TabsViewMode.tree => false,
              })
                Consumer(
                  builder: (context, ref, child) {
                    final selectedContainer = ref.watch(
                      selectedContainerDataProvider.select(
                        (value) => value.value,
                      ),
                    );

                    return ContainerChips(
                      showGroupSuggestions: true,
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
