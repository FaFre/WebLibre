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

import 'package:flutter/widgets.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/providers/router.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/browser_actions/data/models/browser_action.dart';
import 'package:weblibre/features/geckoview/domain/controllers/bottom_sheet.dart';
import 'package:weblibre/features/geckoview/domain/providers/desktop_mode.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_session.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/repositories/bookmarks.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/font_size_constants.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/sheet.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/tab_list_scope.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/toolbar_visibility.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/dialogs/delete_data.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/utils/close_tab_helper.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/share_bottom_sheet.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/translation_bottom_sheet.dart';
import 'package:weblibre/features/geckoview/features/find_in_page/presentation/controllers/find_in_page.dart';
import 'package:weblibre/features/geckoview/features/readerview/presentation/controllers/readerable.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/entities/container_cycle.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/presentation/dialogs/quit_browser_dialog.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/web_search/domain/controllers/sandbox_capture_controller.dart';
import 'package:weblibre/utils/exit_app.dart';
import 'package:weblibre/utils/move_to_background.dart';

part 'browser_action_dispatcher.g.dart';

/// Carries out [BrowserAction]s against the currently selected tab.
///
/// The single meaning of every action: gestures and keyboard shortcuts only
/// resolve their trigger to an action and hand it here, so an action cannot
/// behave differently depending on how it was invoked.
@Riverpod(keepAlive: true)
class BrowserActionDispatcher extends _$BrowserActionDispatcher {
  @override
  void build() {}

  /// Runs [action] on [tabId], or on the selected tab when none is given.
  ///
  /// [tabId] is for triggers that belong to one tab, such as a swipe on its
  /// card in the tab view, so the action lands on that tab rather than on
  /// whichever one is selected.
  ///
  /// Actions that work on a page do nothing while no tab is selected; the ones
  /// that act on the browser itself (opening a tab, a screen, switching
  /// containers) still run.
  Future<void> run(BrowserAction action, {String? tabId}) async {
    tabId ??= ref.read(selectedTabProvider);
    if (tabId == null && _requiresTab(action)) return;

    try {
      await _execute(action, tabId);
    } catch (error, stackTrace) {
      logger.e(
        'Error executing browser action ${action.name}',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Whether [action] needs a selected tab to mean anything.
  ///
  /// Anything not listed is assumed to act on the page, which is the safe
  /// default for a newly added action.
  static bool _requiresTab(BrowserAction action) => switch (action) {
    BrowserAction.focusAddressBar ||
    BrowserAction.newTab ||
    BrowserAction.newPrivateTab ||
    BrowserAction.reopenClosedTab ||
    BrowserAction.selectTab1 ||
    BrowserAction.selectTab2 ||
    BrowserAction.selectTab3 ||
    BrowserAction.selectTab4 ||
    BrowserAction.selectTab5 ||
    BrowserAction.selectTab6 ||
    BrowserAction.selectTab7 ||
    BrowserAction.selectTab8 ||
    BrowserAction.selectLastTab ||
    BrowserAction.resetFontSize ||
    BrowserAction.showTabView ||
    BrowserAction.showDownloads ||
    BrowserAction.showAddons ||
    BrowserAction.openSettings ||
    BrowserAction.showKeyboardShortcuts ||
    BrowserAction.clearBrowsingData ||
    BrowserAction.nextContainer ||
    BrowserAction.previousContainer ||
    BrowserAction.showHome ||
    BrowserAction.showHistory ||
    BrowserAction.showBookmarks ||
    BrowserAction.showContainers ||
    BrowserAction.toggleTabBar ||
    BrowserAction.moveToBackground ||
    BrowserAction.quitBrowser => false,
    _ => true,
  };

  /// Performs [action]. [tabId] is only null for actions [_requiresTab] lets
  /// through.
  Future<void> _execute(BrowserAction action, String? tabId) async {
    final tabRepository = ref.read(tabRepositoryProvider.notifier);
    // Only evaluated by the page actions, which [run] never lets through
    // without a selected tab.
    late final pageTabId = tabId!;

    switch (action) {
      case BrowserAction.focusAddressBar:
        await _focusAddressBar(tabId);
      case BrowserAction.back:
        await ref.read(tabSessionProvider(tabId: pageTabId).notifier).goBack();
      case BrowserAction.forward:
        await ref
            .read(tabSessionProvider(tabId: pageTabId).notifier)
            .goForward();
      case BrowserAction.reload:
        await ref.read(tabSessionProvider(tabId: pageTabId).notifier).reload();
      case BrowserAction.hardReload:
        await ref
            .read(tabSessionProvider(tabId: pageTabId).notifier)
            .reload(flags: LoadUrlFlags.BYPASS_CACHE);
      case BrowserAction.scrollTop:
        await ref
            .read(tabSessionProvider(tabId: pageTabId).notifier)
            .scrollToTop();
      case BrowserAction.scrollBottom:
        await ref
            .read(tabSessionProvider(tabId: pageTabId).notifier)
            .scrollToBottom();
      case BrowserAction.pageUp:
        await ref.read(tabSessionProvider(tabId: pageTabId).notifier).pageUp();
      case BrowserAction.pageDown:
        await ref
            .read(tabSessionProvider(tabId: pageTabId).notifier)
            .pageDown();
      case BrowserAction.newTab:
        await _openNewTab(tabId);
      case BrowserAction.newPrivateTab:
        await _pushLocation(
          const SearchRoute(tabType: TabType.private).location,
        );
      case BrowserAction.closeTab:
        // Confirms the last tab of an isolation group and offers undo, like the
        // tab bar's close button: a stroke or a key press is no less likely to
        // be a mistake than a tap.
        final context = await _navigatorContext();
        if (context != null && context.mounted) {
          await closeTabWithConfirmationAndUndoUsing(
            context,
            ref.read,
            pageTabId,
          );
        }
      case BrowserAction.reopenClosedTab:
        await tabRepository.undoClose();
      case BrowserAction.duplicateTab:
        final containerData = await ref
            .read(tabDataRepositoryProvider.notifier)
            .getTabContainerData(pageTabId);
        await tabRepository.duplicateTab(
          selectTabId: pageTabId,
          containerData: containerData,
          selectTab: true,
        );
      case BrowserAction.nextTab:
        await tabRepository.selectNextTab(pageTabId);
      case BrowserAction.previousTab:
        await tabRepository.selectPreviousTab(pageTabId);
      case BrowserAction.lastUsedTab:
        await tabRepository.selectPreviouslyOpenedTab(pageTabId);
      case BrowserAction.selectTab1:
        await _selectTabAt(1);
      case BrowserAction.selectTab2:
        await _selectTabAt(2);
      case BrowserAction.selectTab3:
        await _selectTabAt(3);
      case BrowserAction.selectTab4:
        await _selectTabAt(4);
      case BrowserAction.selectTab5:
        await _selectTabAt(5);
      case BrowserAction.selectTab6:
        await _selectTabAt(6);
      case BrowserAction.selectTab7:
        await _selectTabAt(7);
      case BrowserAction.selectTab8:
        await _selectTabAt(8);
      case BrowserAction.selectLastTab:
        await _selectTabAt(null);
      case BrowserAction.moveTabBackward:
        await _moveTab(pageTabId, towardEnd: false, toEdge: false);
      case BrowserAction.moveTabForward:
        await _moveTab(pageTabId, towardEnd: true, toEdge: false);
      case BrowserAction.moveTabToStart:
        await _moveTab(pageTabId, towardEnd: false, toEdge: true);
      case BrowserAction.moveTabToEnd:
        await _moveTab(pageTabId, towardEnd: true, toEdge: true);
      case BrowserAction.togglePinTab:
        final pinned =
            ref.read(watchPinnedTabIdsProvider).value?.contains(pageTabId) ??
            false;
        await ref
            .read(tabDataRepositoryProvider.notifier)
            .setPinned(pageTabId, pinned: !pinned);
      case BrowserAction.nextContainer:
        await _switchContainer(ContainerCycleDirection.next);
      case BrowserAction.previousContainer:
        await _switchContainer(ContainerCycleDirection.previous);
      case BrowserAction.toggleReaderMode:
        // One-shot reads from this keep-alive service take no subscription,
        // so nothing auto-disposed is pinned by them.
        final readerActive =
            // ignore: riverpod_lint/only_use_keep_alive_inside_keep_alive
            ref.read(tabStateProvider(pageTabId))?.readerableState.active ??
            false;
        await ref
            .read(readerableScreenControllerProvider.notifier)
            .toggleReaderView(!readerActive);
      case BrowserAction.toggleDesktopMode:
        ref.read(desktopModeProvider(pageTabId).notifier).toggle();
      case BrowserAction.findInPage:
        ref.read(findInPageControllerProvider(pageTabId).notifier).show();
      case BrowserAction.findNext:
        await _findNext(pageTabId, forward: true);
      case BrowserAction.findPrevious:
        await _findNext(pageTabId, forward: false);
      case BrowserAction.increaseFontSize:
        await _adjustFontSize(increase: true);
      case BrowserAction.decreaseFontSize:
        await _adjustFontSize(increase: false);
      case BrowserAction.resetFontSize:
        await _setFontSize(fontSizeDefault);
      case BrowserAction.showHome:
        ref.read(forceBrowserHomeProvider.notifier).request();
      case BrowserAction.toggleTabBar:
        // Keyed by the nullable tab id: the home screen, with no tab selected,
        // has a tab bar too.
        final controller = ref.read(
          toolbarVisibilityControllerProvider(tabId).notifier,
        );
        // Dismissing is the only state the user cannot leave by scrolling, so
        // the same action has to bring the bar back.
        if (ref.read(toolbarVisibilityControllerProvider(tabId)) ==
            ToolbarVisibility.dismissed) {
          controller.forceShow();
        } else {
          controller.dismiss();
        }
      case BrowserAction.showHistory:
        await _pushLocation(const HistoryRoute().location);
      case BrowserAction.showBookmarks:
        await _pushLocation(
          BookmarkListRoute(entryGuid: BookmarkRoot.root.id).location,
        );
      case BrowserAction.showContainers:
        await _pushLocation(const ContainerListRoute().location);
      case BrowserAction.showTabView:
        await _showTabView();
      case BrowserAction.showDownloads:
        await _pushLocation(const HistoryDownloadsRoute().location);
      case BrowserAction.showAddons:
        await _pushLocation(const AddonManagerRoute().location);
      case BrowserAction.openSettings:
        await _pushLocation(SettingsRoute().location);
      case BrowserAction.showKeyboardShortcuts:
        await _pushLocation(const KeyboardShortcutsOverviewRoute().location);
      case BrowserAction.toggleBookmark:
        await _toggleBookmark(pageTabId);
      case BrowserAction.sharePage:
        final context = await _navigatorContext();
        if (context != null && context.mounted) {
          await showShareBottomSheet(context, selectedTabId: pageTabId);
        }
      case BrowserAction.translatePage:
        final context = await _navigatorContext();
        if (context != null && context.mounted) {
          await showTranslationBottomSheet(context, selectedTabId: pageTabId);
        }
      case BrowserAction.printPage:
        await ref
            .read(tabSessionProvider(tabId: pageTabId).notifier)
            .printContent();
      case BrowserAction.clearBrowsingData:
        final context = await _navigatorContext();
        if (context != null && context.mounted) {
          await showDeleteDataDialog(context);
        }
      case BrowserAction.moveToBackground:
        await moveToBackground();
      case BrowserAction.quitBrowser:
        final context = await _navigatorContext();
        if (context != null && context.mounted) {
          final confirmed = await showQuitBrowserDialog(context);
          if (confirmed == true && context.mounted) {
            await exitApp(ProviderScope.containerOf(context, listen: false));
          }
        }
    }
  }

  /// What tapping the address bar does: edit the selected tab's address, or
  /// start a new search when there is no tab.
  Future<void> _focusAddressBar(String? tabId) async {
    final tabState =
        // ignore: riverpod_lint/only_use_keep_alive_inside_keep_alive
        tabId == null ? null : ref.read(tabStateProvider(tabId));

    final route = tabState == null
        ? SearchRoute(
            tabType: ref
                .read(generalSettingsWithDefaultsProvider)
                .effectiveDefaultCreateTabType,
          )
        : SearchRoute(
            tabId: tabState.id,
            searchText: searchTextForTab(
              tabState,
              // ignore: riverpod_lint/only_use_keep_alive_inside_keep_alive
              ref.read(sandboxSourceUriForTabProvider(tabId: tabState.id)),
            ),
            tabType: tabState.tabMode.toTabType(),
          );

    await _pushLocation(route.location);
  }

  /// Moves the selection one container along the chip order, wrapping at the
  /// ends, and resumes that container's most recently used tab.
  ///
  /// Resuming a tab is what makes this useful from web content: leaving the
  /// selected tab behind in another container would only ever land on the home
  /// screen (see [shouldShowBrowserHome]), which is still what happens when the
  /// target container has no tabs left.
  ///
  /// Unlike the tray's two-finger swipe this cannot offer to start the
  /// container's proxy — a stroke gesture has no context to host the dialog —
  /// so it relies on [SelectedContainer.setContainerId] refusing a container
  /// whose routing is not ready, like the quick tab switcher does.
  Future<void> _switchContainer(ContainerCycleDirection direction) async {
    // Containers are hidden entirely when their UI is off, and stepping through
    // them would move browsing state the user cannot see.
    if (!ref.read(generalSettingsWithDefaultsProvider).showContainerUi) return;

    // ignore: riverpod_lint/only_use_keep_alive_inside_keep_alive
    final cycleOrder = ref.read(containerCycleOrderProvider);
    final index = adjacentContainerIndex(
      cycleOrder.map((container) => container?.id).toList(),
      ref.read(selectedContainerProvider),
      direction,
    );
    if (index == null) return;

    final container = cycleOrder[index];
    if (container == null) {
      ref.read(selectedContainerProvider.notifier).clearContainer();
    } else {
      final result = await ref
          .read(selectedContainerProvider.notifier)
          .setContainerId(container.id);
      if (result == SetContainerResult.failed) return;
    }

    if (!ref.mounted) return;

    await ref
        .read(tabRepositoryProvider.notifier)
        .resumeLatestContainerTab(container?.id);
  }

  /// Adds the current page to bookmarks, or removes it if already bookmarked,
  /// mirroring the contextual toolbar's bookmark toggle button.
  Future<void> _toggleBookmark(String tabId) async {
    // ignore: riverpod_lint/only_use_keep_alive_inside_keep_alive
    final tabState = ref.read(tabStateProvider(tabId));
    if (tabState == null) return;

    final bookmarkUrl =
        // ignore: riverpod_lint/only_use_keep_alive_inside_keep_alive
        ref.read(sandboxSourceUriForTabProvider(tabId: tabId)) ?? tabState.url;

    final repository = ref.read(bookmarksRepositoryProvider.notifier);
    final existingGuids = await repository.bookmarkGuidsForUrl(bookmarkUrl);
    if (existingGuids.isNotEmpty) {
      for (final guid in existingGuids) {
        await repository.delete(guid);
      }
    } else {
      await repository.addBookmark(
        parentGuid: BookmarkRoot.mobile.id,
        url: bookmarkUrl,
        title: tabState.titleOrAuthority,
      );
    }
  }

  /// Resolves the root navigator's [BuildContext] for actions that open a
  /// dialog/sheet. Null when the navigator is not currently mounted.
  Future<BuildContext?> _navigatorContext() async {
    final router = await ref.read(routerProvider.future);
    if (!ref.mounted) return null;
    return router.routerDelegate.navigatorKey.currentContext;
  }

  Future<void> _pushLocation(String location) async {
    final router = await ref.read(routerProvider.future);
    if (!ref.mounted) return;
    await router.push(location);
  }

  Future<void> _adjustFontSize({required bool increase}) {
    final current = ref.read(engineSettingsWithDefaultsProvider).fontSizeFactor;
    return _setFontSize(
      increase ? current + fontSizeStep : current - fontSizeStep,
    );
  }

  Future<void> _setFontSize(double factor) async {
    final settings = ref.read(engineSettingsWithDefaultsProvider);

    // Manual adjustment is a no-op while automatic font sizing is enabled.
    if (settings.automaticFontSizeAdjustment) return;

    final rounded = (factor.clamp(fontSizeMin, fontSizeMax) * 10).round() / 10;
    if (rounded == settings.fontSizeFactor) return;

    await ref
        .read(saveEngineSettingsControllerProvider.notifier)
        .save(
          (currentSettings) => currentSettings.copyWith.fontSizeFactor(rounded),
        );
  }

  /// Selects the tab at [position] in the selected container's tab bar, or its
  /// last tab when [position] is null (see [shortcutTabTarget]).
  Future<void> _selectTabAt(int? position) async {
    // The rendered order is kept alive by this provider, including the
    // selected container's rows; null means the tree data has not arrived.
    if (ref.read(sequentialTabNavigationOrderProvider).value == null) return;

    // ignore: riverpod_lint/only_use_keep_alive_inside_keep_alive
    final items = ref
        .read(
          visibleTabListItemsProvider(
            containerId: ref.read(selectedContainerProvider),
            scope: TabListScope.presentation,
          ),
        )
        .value;

    final target = shortcutTabTarget([
      for (final item in items) item.tabId,
    ], position);
    if (target != null) {
      await ref.read(tabRepositoryProvider.notifier).selectTab(target);
    }
  }

  /// Moves [tabId] among its siblings along the tab bar: one place, or with
  /// [toEdge] all the way to the start or end of its group.
  ///
  /// Storage order runs against the bar when the bar shows the newest tab
  /// first, so the direction is flipped for it.
  Future<void> _moveTab(
    String tabId, {
    required bool towardEnd,
    required bool toEdge,
  }) async {
    final newestFirst =
        ref.read(generalSettingsWithDefaultsProvider).tabBarDirection ==
        TabDirection.newestFirst;

    await ref
        .read(tabDataRepositoryProvider.notifier)
        .moveTabAmongSiblings(
          tabId,
          down: towardEnd != newestFirst,
          toEdge: toEdge,
        );
  }

  /// Steps through the matches of the find bar's last search, or opens the
  /// find bar when nothing has been searched for yet.
  Future<void> _findNext(String tabId, {required bool forward}) async {
    final lastSearchText = ref
        .read(findInPageControllerProvider(tabId))
        .lastSearchText;
    final controller = ref.read(findInPageControllerProvider(tabId).notifier);

    if (lastSearchText == null || lastSearchText.isEmpty) {
      controller.show();
      return;
    }

    await controller.findNext(fallbackText: lastSearchText, forward: forward);
  }

  /// Opens the tab view the way the tab bar's tab count button does: as a
  /// sheet or as its own screen, depending on the user's setting.
  Future<void> _showTabView() async {
    if (ref.read(bottomSheetControllerProvider) != null) return;

    if (ref.read(generalSettingsWithDefaultsProvider).tabViewBottomSheet) {
      ref.read(bottomSheetControllerProvider.notifier).show(ViewTabsSheet());
    } else {
      await _pushLocation(const TabViewRoute().location);
    }
  }

  Future<void> _openNewTab(String? tabId) async {
    final router = await ref.read(routerProvider.future);
    if (!ref.mounted) return;

    final settings = ref.read(generalSettingsWithDefaultsProvider);
    final selectedTabType = tabId == null
        ? null
        : ref.read(tabStatesProvider)[tabId]?.tabMode.toTabType();

    final route = SearchRoute(
      tabType: selectedTabType ?? settings.effectiveDefaultCreateTabType,
    );
    await router.push(route.location);
  }
}

/// The tab a Ctrl+1…9 style shortcut selects in [order]: the tab at
/// [position], counted from one, or the last tab when [position] is null.
///
/// A position past the end selects nothing, as in Firefox, rather than falling
/// back to the last tab.
@visibleForTesting
String? shortcutTabTarget(List<String> order, int? position) {
  assert(position == null || position >= 1, 'Positions count from one');

  if (order.isEmpty) return null;
  if (position == null) return order.last;
  return position <= order.length ? order[position - 1] : null;
}
