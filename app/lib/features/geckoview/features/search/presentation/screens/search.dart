/*
 * Copyright (c) 2024-2026 Fabian Freund.
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

import 'package:drift/drift.dart' hide Column;
import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/bangs/domain/providers/bangs.dart';
import 'package:weblibre/features/bangs/domain/providers/search.dart';
import 'package:weblibre/features/geckoview/domain/controllers/bottom_sheet.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_session.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/clipboard_fill.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_field.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/feed_search.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/full_search_suggestions.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/history_suggestions.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/tab_search.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/container_chips.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/hooks/on_listenable_change_selector.dart';
import 'package:weblibre/presentation/hooks/sampled_value_notifier.dart';
import 'package:weblibre/presentation/icons/weblibre_icons.dart';
import 'package:weblibre/utils/text_field_line_count.dart';
import 'package:weblibre/utils/uri_parser.dart' as uri_parser;

class SearchScreen extends HookConsumerWidget {
  final String? initialSearchText;
  final TabType tabType;
  final bool launchedFromIntent;

  /// When provided, URLs will be loaded into this existing tab.
  /// When null, a new tab will be created.
  final String? tabId;

  const SearchScreen({super.key, 
    required this.initialSearchText,
    required this.tabType,
    this.launchedFromIntent = false,
    this.tabId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = AppColors.of(context);
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final createChildTabsOption = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (value) => value.createChildTabsOption,
      ),
    );

    final selectedTabType = useState(tabType);
    final currentTabTabType = ref.watch(selectedTabTypeProvider);

    final selectedContainer = ref.watch(
      selectedContainerDataProvider.select((value) => value.value),
    );

    // When editing an existing tab, get its state
    // If tab no longer exists (null), fall back to new tab mode
    final existingTabState = tabId != null
        ? ref.watch(tabStateProvider(tabId))
        : null;

    // Determine if we're in edit mode (tabId provided AND tab still exists)
    final isEditMode = tabId != null && existingTabState != null;

    // Derive private mode from existing tab or from selector
    final privateTabMode = isEditMode
        ? existingTabState.isPrivate
        : switch (selectedTabType.value) {
            TabType.regular => false,
            TabType.private => true,
            TabType.child => currentTabTabType == TabType.private,
          };

    final searchTextController = useTextEditingController(
      text: initialSearchText,
    );
    final sampledSearchText = useSampledValueNotifier(
      source: searchTextController,
      sampleDuration: const Duration(milliseconds: 150),
    );
    final searchFocusNode = useFocusNode();
    final textFieldKey = useMemoized(() => GlobalKey());
    final preferredHeight = useState<double>(kToolbarHeight);

    useOnListenableChangeSelector(
      searchFocusNode,
      () => searchFocusNode.hasFocus,
      () {
        if (searchFocusNode.hasFocus && isEditMode) {
          // Select all text when the field is focused
          searchTextController.selection = TextSelection(
            baseOffset: 0,
            extentOffset: searchTextController.text.length,
          );
        }
      },
    );

    useEffect(() {
      if (isEditMode) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          searchTextController.selection = TextSelection(
            baseOffset: 0,
            extentOffset: searchTextController.text.length,
          );
        });
      }
      return null;
    }, []);

    //Request initial focus in a way our useOnListenableChangeSelector is triggered
    useEffect(() {
      //Wait for first frame then request focus
      unawaited(
        Future.delayed(const Duration(milliseconds: 1000 ~/ 60)).whenComplete(
          () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              searchFocusNode.requestFocus();
            });
          },
        ),
      );

      return null;
    }, []);

    Future<void> measureHeightWithRetry() async {
      const delays = [25, 50, 75, 100];

      for (final delay in delays) {
        await Future.delayed(Duration(milliseconds: delay));
        final measuredHeight = getTextFieldHeight(textFieldKey);

        if (measuredHeight != null) {
          preferredHeight.value = measuredHeight;
          return;
        }
      }
    }

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        measureHeightWithRetry(); // ignore: discarded_futures
      });

      return null;
    }, [textFieldKey, isEditMode]);

    useOnListenableChange(isEditMode ? searchTextController : null, () {
      measureHeightWithRetry(); // ignore: discarded_futures
    });

    useOnAppLifecycleStateChange((previous, current) {
      switch (current) {
        case AppLifecycleState.detached:
        case AppLifecycleState.inactive:
        case AppLifecycleState.hidden:
        case AppLifecycleState.paused:
          //Fixes issue with disappearing keyboard after resume (even we request focus)
          searchFocusNode.unfocus();
        case AppLifecycleState.resumed:
          WidgetsBinding.instance.addPostFrameCallback((_) {
            searchFocusNode.requestFocus();
          });
      }
    });

    final defaultSearchBang = ref.watch(
      defaultSearchBangDataProvider.select((value) => value.value),
    );

    // Watch both selection providers - only one should be set at a time
    // due to mutual exclusion in SmartBangSelector
    final siteSelectedBang = isEditMode
        ? ref.watch(selectedBangDataProvider(domain: existingTabState.url.host))
        : null;
    final globalSelectedBang = ref.watch(selectedBangDataProvider());

    // The active selection is whichever one is set (site takes priority if both somehow set)
    final selectedBang = siteSelectedBang ?? globalSelectedBang;
    final activeBang = selectedBang ?? defaultSearchBang;
    final showBangIcon = selectedBang != null;

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        measureHeightWithRetry(); // ignore: discarded_futures
      });

      return null;
    }, [showBangIcon]);

    Future<void> submitSearch(String query) async {
      if (activeBang != null && (formKey.currentState?.validate() == true)) {
        final searchUri = activeBang.getTemplateUrl(query);

        if (!privateTabMode) {
          await ref
              .read(bangSearchProvider.notifier)
              .triggerBangSearch(activeBang, query);
        }

        if (isEditMode) {
          // Load into existing tab
          await ref
              .read(tabSessionProvider(tabId: tabId).notifier)
              .loadUrl(url: searchUri);
        } else {
          // Create new tab
          await ref
              .read(tabRepositoryProvider.notifier)
              .addTab(
                url: searchUri,
                private: privateTabMode,
                parentId: (selectedTabType.value == TabType.child)
                    ? ref.read(selectedTabProvider)
                    : null,
                launchedFromIntent: launchedFromIntent,
                selectTab: true,
                container: Value(selectedContainer),
              );
        }

        if (context.mounted) {
          ref.read(bottomSheetControllerProvider.notifier).requestDismiss();

          const BrowserRoute().go(context);
        }
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: formKey,
          child: FadingScroll(
            builder: (context, controller) {
              return CustomScrollView(
                controller: controller,
                slivers: [
                  SliverAppBar(
                    floating: true,
                    pinned: true,
                    automaticallyImplyLeading: false,
                    toolbarHeight: isEditMode ? 0 : kToolbarHeight + 56,
                    titleSpacing: 0.0,
                    title: isEditMode
                        ? null
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Focus(
                                canRequestFocus: false,
                                child: SegmentedButton(
                                  showSelectedIcon: false,
                                  segments: [
                                    const ButtonSegment(
                                      value: TabType.regular,
                                      label: Text('Regular'),
                                      icon: Icon(MdiIcons.tab),
                                    ),
                                    const ButtonSegment(
                                      value: TabType.private,
                                      label: Text('Private'),
                                      icon: Icon(WebLibreIcons.privateTab),
                                    ),
                                    if (createChildTabsOption)
                                      const ButtonSegment(
                                        value: TabType.child,
                                        label: Text('Child'),
                                        icon: Icon(MdiIcons.fileTree),
                                      ),
                                  ],
                                  selected: {selectedTabType.value},
                                  onSelectionChanged: (value) {
                                    selectedTabType.value = value.first;
                                    // Restore focus to search field after segment change
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          searchFocusNode.requestFocus();
                                        });
                                  },
                                  style: switch (selectedTabType.value) {
                                    TabType.regular => null,
                                    TabType.private =>
                                      SegmentedButton.styleFrom(
                                        selectedBackgroundColor:
                                            appColors.privateSelectionOverlay,
                                      ),
                                    TabType.child =>
                                      (currentTabTabType == TabType.private)
                                          ? SegmentedButton.styleFrom(
                                              selectedBackgroundColor: appColors
                                                  .privateSelectionOverlay,
                                            )
                                          : null,
                                  },
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: SizedBox(
                                  height: 48,
                                  child: ContainerChips(
                                    selectedContainer: selectedContainer,
                                    onSelected: (container) async {
                                      if (container != null) {
                                        await ref
                                            .read(
                                              selectedContainerProvider
                                                  .notifier,
                                            )
                                            .setContainerId(container.id);
                                      } else {
                                        ref
                                            .read(
                                              selectedContainerProvider
                                                  .notifier,
                                            )
                                            .clearContainer();
                                      }
                                    },
                                    onDeleted: (container) {
                                      ref
                                          .read(
                                            selectedContainerProvider.notifier,
                                          )
                                          .clearContainer();
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                    bottom: PreferredSize(
                      preferredSize: Size.fromHeight(preferredHeight.value),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: SearchField(
                          textFieldKey: textFieldKey,
                          showBangIcon: showBangIcon,
                          textEditingController: searchTextController,
                          focusNode: searchFocusNode,
                          maxLines: isEditMode ? 3 : 1,
                          autofocus: true,
                          label: (activeBang != null)
                              ? const Text('Search')
                              : const Text('Address / Search'),
                          unfocusOnTapOutside: false,
                          onSubmitted: (value) async {
                            if (value.isNotEmpty) {
                              var newUrl = uri_parser.tryParseUrl(
                                value,
                                eagerParsing: true,
                              );

                              if (newUrl == null) {
                                // Read from both providers - use site if set, otherwise global
                                final siteBang = isEditMode
                                    ? ref.read(
                                        selectedBangDataProvider(
                                          domain: existingTabState.url.host,
                                        ),
                                      )
                                    : null;
                                final globalBang = ref.read(
                                  selectedBangDataProvider(),
                                );
                                final bang =
                                    siteBang ??
                                    globalBang ??
                                    await ref.read(
                                      defaultSearchBangDataProvider.future,
                                    );

                                if (bang != null) {
                                  newUrl = bang.getTemplateUrl(value);

                                  if (!privateTabMode) {
                                    await ref
                                        .read(bangSearchProvider.notifier)
                                        .triggerBangSearch(bang, value);
                                  }
                                }
                              }

                              if (newUrl != null) {
                                if (isEditMode) {
                                  // Load into existing tab
                                  await ref
                                      .read(
                                        tabSessionProvider(
                                          tabId: tabId,
                                        ).notifier,
                                      )
                                      .loadUrl(url: newUrl);
                                } else {
                                  // Create new tab
                                  await ref
                                      .read(tabRepositoryProvider.notifier)
                                      .addTab(
                                        url: newUrl,
                                        private: privateTabMode,
                                        parentId:
                                            (selectedTabType.value ==
                                                TabType.child)
                                            ? ref.read(selectedTabProvider)
                                            : null,
                                        launchedFromIntent: launchedFromIntent,
                                        selectTab: true,
                                        container: Value(selectedContainer),
                                      );
                                }

                                if (context.mounted) {
                                  ref
                                      .read(
                                        bottomSheetControllerProvider.notifier,
                                      )
                                      .requestDismiss();

                                  const BrowserRoute().go(context);
                                }
                              }
                            }
                          },
                          activeBang: activeBang,
                          showSuggestions: true,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: ClipboardFillLink(controller: searchTextController),
                  ),
                  const SliverToBoxAdapter(child: Divider()),
                  FullSearchTermSuggestions(
                    searchTextController: searchTextController,
                    activeBang: activeBang,
                    submitSearch: submitSearch,
                    domain: isEditMode ? existingTabState.url.host : null,
                  ),
                  TabSearch(searchTextListenable: sampledSearchText),
                  FeedSearch(searchTextNotifier: sampledSearchText),
                  HistorySuggestions(
                    searchTextListenable: sampledSearchText,
                    onUriSelected: (uri) async {
                      if (isEditMode) {
                        // Load into existing tab
                        await ref
                            .read(tabSessionProvider(tabId: tabId).notifier)
                            .loadUrl(url: uri);
                      } else {
                        // Create new tab
                        await ref
                            .read(tabRepositoryProvider.notifier)
                            .addTab(
                              url: uri,
                              private: privateTabMode,
                              parentId: (selectedTabType.value == TabType.child)
                                  ? ref.read(selectedTabProvider)
                                  : null,
                              launchedFromIntent: launchedFromIntent,
                              selectTab: true,
                              container: Value(selectedContainer),
                            );
                      }

                      if (context.mounted) {
                        ref
                            .read(bottomSheetControllerProvider.notifier)
                            .requestDismiss();

                        const BrowserRoute().go(context);
                      }
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
