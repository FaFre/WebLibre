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

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/bangs/domain/providers/bangs.dart';
import 'package:weblibre/features/bangs/domain/providers/search.dart';
import 'package:weblibre/features/geckoview/domain/controllers/bottom_sheet.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_container_selection.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_session.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_module_order.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/animated_tab_type_switcher.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/clipboard_fill.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/empty_state/containers_section.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/empty_state/history_highlights_section.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/empty_state/recent_feed_articles_section.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/empty_state/recent_history_section.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/empty_state/recent_tabs_section.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/empty_state/top_sites_section.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_field.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_module_reorder_view.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/bookmark_search.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/feed_search.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/full_search_suggestions.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/history_suggestions.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/search_modules/tab_search.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/isolation_context.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/widgets/compact_container_selector.dart';
import 'package:weblibre/features/tor/presentation/controllers/start_tor_proxy.dart';
import 'package:weblibre/features/tor/presentation/widgets/tor_dialog.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/hooks/on_listenable_change_selector.dart';
import 'package:weblibre/presentation/hooks/sampled_value_notifier.dart';
import 'package:weblibre/utils/input_classification.dart';
import 'package:weblibre/utils/text_field_line_count.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

class SearchScreen extends HookConsumerWidget {
  final String? initialSearchText;
  final TabType tabType;
  final bool launchedFromIntent;

  /// When provided, URLs will be loaded into this existing tab.
  /// When null, a new tab will be created.
  final String? tabId;

  const SearchScreen({
    super.key,
    required this.initialSearchText,
    required this.tabType,
    this.launchedFromIntent = false,
    this.tabId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = AppColors.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final createChildTabsOption = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (value) => value.createChildTabsOption,
      ),
    );
    final settings = ref.watch(generalSettingsWithDefaultsProvider);

    final initialTabType =
        !settings.showIsolatedTabUi && tabType == TabType.isolated
        ? TabType.regular
        : tabType;

    final selectedTabType = useState(initialTabType);
    final currentTabTabType = ref.watch(selectedTabTypeProvider);

    useEffect(() {
      if (!settings.showIsolatedTabUi &&
          selectedTabType.value == TabType.isolated) {
        selectedTabType.value = TabType.regular;
      }
      return null;
    }, [settings.showIsolatedTabUi]);

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

    final effectiveTabMode = isEditMode
        ? existingTabState.tabMode
        : switch (selectedTabType.value) {
            TabType.regular => TabMode.regular,
            TabType.private => TabMode.private,
            TabType.isolated => TabMode.newIsolated(),
            TabType.child => switch (currentTabTabType) {
              TabType.private => TabMode.private,
              TabType.isolated => TabMode.isolated(
                ref.watch(selectedTabStateProvider)?.isolationContextId ??
                    newIsolatedContextId(),
              ),
              _ => TabMode.regular,
            },
          };

    final privateTabMode = effectiveTabMode is PrivateTabMode;

    final searchTextController = useTextEditingController(
      text: initialSearchText,
    );
    final sampledSearchText = useSampledValueNotifier(
      source: searchTextController,
      sampleDuration: const Duration(milliseconds: 150),
    );
    final hasUserProvidedInput = useState(
      initialSearchText?.isNotEmpty == true,
    );

    // Track if we started with a URL (edit mode) to show empty state initially
    final startedWithUrl = useMemoized(() {
      if (initialSearchText == null || initialSearchText!.isEmpty) return false;
      return classifyAddressBarInput(initialSearchText!)
          is NavigateInputClassification;
    });
    final hasUserModifiedInput = useState(false);
    final isUrlInput = useState(false);

    useOnListenableChangeSelector(
      searchTextController,
      () => searchTextController.text,
      () {
        final text = searchTextController.text;
        hasUserProvidedInput.value = text.isNotEmpty;
        if (startedWithUrl) {
          hasUserModifiedInput.value = text != initialSearchText;
        }
        isUrlInput.value =
            text.isNotEmpty &&
            classifyAddressBarInput(text) is NavigateInputClassification;
      },
    );

    final showNoInputSections =
        (startedWithUrl && !hasUserModifiedInput.value) ||
        (!hasUserProvidedInput.value && searchTextController.text.isEmpty);

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
          // Add 2px to account for SearchField container border
          preferredHeight.value = measuredHeight + 2;
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

    useOnListenableChangeSelector(
      isEditMode ? searchTextController : null,
      () => searchTextController.text,
      () {
        measureHeightWithRetry(); // ignore: discarded_futures
      },
    );

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
                tabMode: effectiveTabMode,
                parentId: (selectedTabType.value == TabType.child)
                    ? ref.read(selectedTabProvider)
                    : null,
                launchedFromIntent: launchedFromIntent,
                selectTab: true,
                containerSelection: selectedContainer == null
                    ? const TabContainerSelection.unassigned()
                    : TabContainerSelection.specific(selectedContainer),
              );
        }

        if (context.mounted) {
          ref.read(bottomSheetControllerProvider.notifier).requestDismiss();

          const BrowserRoute().go(context);
        }
      }
    }

    final reorderGroup = ref.watch(searchReorderModeProvider);

    final emptyStateOrder = ref.watch(
      searchModuleOrderProvider(SearchModuleGroup.emptyState),
    );
    final searchOrder = ref.watch(
      searchModuleOrderProvider(SearchModuleGroup.search),
    );

    Future<void> openUriInTab(Uri uri) async {
      if (isEditMode) {
        await ref
            .read(tabSessionProvider(tabId: tabId).notifier)
            .loadUrl(url: uri);
      } else {
        await ref
            .read(tabRepositoryProvider.notifier)
            .addTab(
              url: uri,
              tabMode: effectiveTabMode,
              parentId: (selectedTabType.value == TabType.child)
                  ? ref.read(selectedTabProvider)
                  : null,
              launchedFromIntent: launchedFromIntent,
              selectTab: true,
              containerSelection: selectedContainer == null
                  ? const TabContainerSelection.unassigned()
                  : TabContainerSelection.specific(selectedContainer),
            );
      }

      if (context.mounted) {
        ref.read(bottomSheetControllerProvider.notifier).requestDismiss();
        const BrowserRoute().go(context);
      }
    }

    final emptyStateWidgets = <SearchModuleType, Widget>{
      SearchModuleType.topSites: TopSitesSection(onUriSelected: openUriInTab),
      SearchModuleType.recentArticles: RecentFeedArticlesSection(
        onArticleSelected: (article) {
          FeedArticleRoute(articleId: article.id).pushReplacement(context);
        },
      ),
      SearchModuleType.recentTabs: RecentTabsSection(
        onTabSelected: (tabId) async {
          await ref.read(tabRepositoryProvider.notifier).selectTab(tabId);

          if (context.mounted) {
            ref.read(bottomSheetControllerProvider.notifier).requestDismiss();
            const BrowserRoute().go(context);
          }
        },
      ),
      SearchModuleType.recentHistory: RecentHistorySection(
        onUriSelected: openUriInTab,
      ),
      SearchModuleType.historyHighlights: HistoryHighlightsSection(
        onUriSelected: openUriInTab,
      ),
      SearchModuleType.containers: ContainersSection(
        onContainerSelected: (container) async {
          final result = await ref
              .read(selectedContainerProvider.notifier)
              .setContainerId(container.id);

          if (!context.mounted) return;

          if (result == SetContainerResult.successHasProxy) {
            final shouldStartProxy = await ref
                .read(startProxyControllerProvider.notifier)
                .shouldPromptProxyStart();

            if (context.mounted && shouldStartProxy) {
              final dialogResult = await showDialog<bool>(
                context: context,
                builder: (_) => const TorDialog(),
              );

              if (dialogResult == true) {
                await ref
                    .read(startProxyControllerProvider.notifier)
                    .startProxy();
              }
            }
          }

          if (context.mounted && result != SetContainerResult.failed) {
            const TabViewRoute().go(context);
          }
        },
      ),
    };

    final searchWidgets = <SearchModuleType, Widget>{
      SearchModuleType.tabs: TabSearch(searchTextListenable: sampledSearchText),
      SearchModuleType.bookmarks: BookmarkSearch(
        searchTextListenable: sampledSearchText,
        onUriSelected: openUriInTab,
      ),
      SearchModuleType.articles: FeedSearch(
        searchTextNotifier: sampledSearchText,
      ),
      SearchModuleType.history: HistorySuggestions(
        searchTextListenable: sampledSearchText,
        onUriSelected: openUriInTab,
      ),
    };

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: formKey,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                pinned: true,
                automaticallyImplyLeading: false,
                backgroundColor: colorScheme.surface,
                scrolledUnderElevation: 0,
                shadowColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                toolbarHeight: isEditMode ? 0 : kToolbarHeight,
                titleSpacing: 0.0,
                title: isEditMode
                    ? null
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Builder(
                          builder: (context) {
                            final tabTypeSwitcher = Focus(
                              canRequestFocus: false,
                              child: AnimatedTabTypeSwitcher(
                                selected: selectedTabType.value,
                                onChanged: (value) {
                                  selectedTabType.value = value;
                                  // Restore focus to search field after segment change
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    searchFocusNode.requestFocus();
                                  });
                                },
                                showChildOption: createChildTabsOption,
                                showIsolatedOption: settings.showIsolatedTabUi,
                                selectedBackgroundColor: switch (selectedTabType
                                    .value) {
                                  TabType.regular => null,
                                  TabType.private =>
                                    appColors.privateSelectionOverlay,
                                  TabType.isolated =>
                                    appColors.isolatedSelectionOverlay,
                                  TabType.child => switch (currentTabTabType) {
                                    TabType.private =>
                                      appColors.privateSelectionOverlay,
                                    TabType.isolated =>
                                      appColors.isolatedSelectionOverlay,
                                    _ => null,
                                  },
                                },
                              ),
                            );

                            if (!settings.showContainerUi) {
                              return Center(
                                child: Transform.scale(
                                  scale: 1.08,
                                  child: tabTypeSwitcher,
                                ),
                              );
                            }

                            return Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: tabTypeSwitcher,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  flex: 2,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: CompactContainerSelector(
                                      selectedContainer: selectedContainer,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(preferredHeight.value),
                  child: SearchField(
                    textFieldKey: textFieldKey,
                    showBangIcon: showBangIcon,
                    textEditingController: searchTextController,
                    focusNode: searchFocusNode,
                    maxLines: isEditMode ? 3 : 1,
                    autofocus: true,
                    label: const Text('Search or enter URL'),
                    unfocusOnTapOutside: false,
                    onSubmitted: (value) async {
                      if (value.isNotEmpty) {
                        final classification = classifyAddressBarInput(value);
                        Uri? newUrl;
                        String? searchQuery;

                        switch (classification) {
                          case NavigateInputClassification(:final uri):
                            newUrl = uri;
                          case SearchInputClassification(:final query):
                            searchQuery = query;
                          case InvalidInputClassification():
                            if (context.mounted) {
                              ui_helper.showErrorMessage(
                                context,
                                'Invalid address',
                              );
                            }
                            return;
                        }

                        if (newUrl == null && searchQuery != null) {
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
                            newUrl = bang.getTemplateUrl(searchQuery);

                            if (!privateTabMode) {
                              await ref
                                  .read(bangSearchProvider.notifier)
                                  .triggerBangSearch(bang, searchQuery);
                            }
                          }
                        }

                        if (newUrl != null) {
                          if (isEditMode) {
                            // Load into existing tab
                            await ref
                                .read(tabSessionProvider(tabId: tabId).notifier)
                                .loadUrl(url: newUrl);
                          } else {
                            // Create new tab
                            await ref
                                .read(tabRepositoryProvider.notifier)
                                .addTab(
                                  url: newUrl,
                                  tabMode: effectiveTabMode,
                                  parentId:
                                      (selectedTabType.value == TabType.child)
                                      ? ref.read(selectedTabProvider)
                                      : null,
                                  launchedFromIntent: launchedFromIntent,
                                  selectTab: true,
                                  containerSelection: selectedContainer == null
                                      ? const TabContainerSelection.unassigned()
                                      : TabContainerSelection.specific(
                                          selectedContainer,
                                        ),
                                );
                          }

                          if (context.mounted) {
                            ref
                                .read(bottomSheetControllerProvider.notifier)
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
              SliverToBoxAdapter(
                child: ClipboardFillLink(controller: searchTextController),
              ),
              if (reorderGroup != null)
                SearchModuleReorderView(group: reorderGroup)
              else if (showNoInputSections) ...[
                for (final entry in emptyStateOrder)
                  if (emptyStateWidgets.containsKey(entry.type))
                    emptyStateWidgets[entry.type]!,
                const _CustomizeSectionsButton(
                  group: SearchModuleGroup.emptyState,
                ),
              ] else ...[
                if (!isUrlInput.value)
                  FullSearchTermSuggestions(
                    searchTextController: searchTextController,
                    activeBang: activeBang,
                    submitSearch: submitSearch,
                    domain: isEditMode ? existingTabState.url.host : null,
                  ),
                for (final entry in searchOrder)
                  if (searchWidgets.containsKey(entry.type) &&
                      (!isUrlInput.value ||
                          entry.type != SearchModuleType.articles))
                    searchWidgets[entry.type]!,
                const _CustomizeSectionsButton(group: SearchModuleGroup.search),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomizeSectionsButton extends ConsumerWidget {
  final SearchModuleGroup group;

  const _CustomizeSectionsButton({required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 24),
          child: TextButton.icon(
            onPressed: () =>
                ref.read(searchReorderModeProvider.notifier).activate(group),
            icon: const Icon(Icons.tune, size: 18),
            label: const Text('Customize sections'),
          ),
        ),
      ),
    );
  }
}
