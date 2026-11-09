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

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/providers/provider_read.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/controllers/bottom_sheet.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_container_selection.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/sheet.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/tab_pick_request.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/entities/split_pair.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/providers/split_view.dart';
import 'package:weblibre/features/geckoview/features/split_view/presentation/utils/split_pair_l10n.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/utils/ui_helper.dart';

/// The search screen's tab type for a tab of [mode], so the picker starts in
/// the source's privacy class.
TabType splitPickerTabType(TabMode? mode) =>
    mode?.toTabType() ?? TabType.regular;

/// The tab types the picker offers beside a source of the given privacy:
/// those of the same class. A child tab follows [selectedTabType] (the tab it
/// would be opened from).
Set<TabType> splitPickerTabTypes({
  required bool sourcePrivate,
  required TabType? selectedTabType,
}) => {
  for (final type in TabType.values)
    if (switch (type) {
          TabType.private => true,
          TabType.child => selectedTabType == TabType.private,
          TabType.regular || TabType.isolated => false,
        } ==
        sourcePrivate)
      type,
};

/// The open tabs the picker leaves out: the source, and every tab of the other
/// privacy class, which could not be shown beside it. [modes] holds every open
/// tab's mode. A source that is gone excludes only itself; `pair` reports it.
Set<String> splitPickerExcludedTabIds({
  required String sourceTabId,
  required Map<String, TabMode> modes,
}) {
  final sourceMode = modes[sourceTabId];
  return {
    sourceTabId,
    for (final MapEntry(:key, :value) in modes.entries)
      if (!canShareSplit(value, sourceMode)) key,
  };
}

/// The open tabs that can be shown beside [sourceTabId], in the order of
/// [tabs] (most recently used first): of the source's privacy class, neither
/// the source nor one of [excludedTabIds] (the pair's members, when the
/// other page is being replaced).
List<TabStateWithContainer> splitPartnerCandidates({
  required List<TabStateWithContainer> tabs,
  required String sourceTabId,
  Set<String> excludedTabIds = const {},
}) {
  final source = tabs.firstWhereOrNull((entry) => entry.$1.id == sourceTabId);
  if (source == null) return const [];
  return [
    for (final entry in tabs)
      if (entry.$1.id != sourceTabId &&
          !excludedTabIds.contains(entry.$1.id) &&
          canShareSplit(entry.$1.tabMode, source.$1.tabMode))
        entry,
  ];
}

/// The search screen as a picker for the page to show beside [sourceTabId].
SearchRoute _splitSearchRoute(ProviderRead read, String sourceTabId) =>
    SearchRoute(
      tabType: splitPickerTabType(read(tabStateProvider(sourceTabId))?.tabMode),
      splitWithTabId: sourceTabId,
    );

/// Opens the search screen as a picker for the page to show beside
/// [sourceTabId].
Future<void> openSplitPicker(
  BuildContext context,
  ProviderRead read,
  String sourceTabId,
) async {
  final route = _splitSearchRoute(read, sourceTabId);
  read(bottomSheetControllerProvider.notifier).requestDismiss();
  await route.push(context);
}

/// The tab tray as a picker for the page shown beside [sourceTabId]: in
/// place of the other page when [pair] holds the source ("Replace other
/// page"), otherwise to start a split with it. It offers the open tabs of the
/// source's privacy class except the source and the pair's members, and its
/// new-tab button opens the search screen as a picker. With no such tab at
/// all, the search screen opens straight away.
///
/// Everything a pick needs is read now: whatever asks closes first.
Future<void> showSplitPartnerPicker(
  BuildContext context,
  ProviderRead read, {
  required String sourceTabId,
  SplitPair? pair,
}) async {
  final excluded = {
    if (pair != null && pair.contains(sourceTabId)) ...[
      pair.firstTabId,
      pair.secondTabId,
    ],
  };
  final candidates = splitPartnerCandidates(
    tabs: read(fifoTabStatesProvider).value,
    sourceTabId: sourceTabId,
    excludedTabIds: excluded,
  );
  if (candidates.isEmpty) {
    await openSplitPicker(context, read, sourceTabId);
    return;
  }

  final l10n = AppLocalizations.of(context);
  final source = read(tabStateProvider(sourceTabId));
  final sheets = read(bottomSheetControllerProvider.notifier);
  final destination = SplitPickerDestination.capture(
    context,
    read,
    sourceTabId: sourceTabId,
  );
  final router = GoRouter.of(context);
  final searchPicker = _splitSearchRoute(read, sourceTabId).location;

  sheets.show(
    TabPickerSheet(
      TabPickRequest(
        title: excluded.isEmpty
            ? l10n.splitView_pickerTitle
            : l10n.splitView_replaceTitle,
        privateTabs: source?.tabMode is PrivateTabMode,
        excludedTabIds: {sourceTabId, ...excluded},
        initialContainer: read(selectedContainerDataProvider).value,
        onPicked: (tabId) async {
          sheets.requestDismiss();
          await destination.pair(tabId);
        },
        onNewTab: () {
          sheets.requestDismiss();
          unawaited(router.push(searchPicker));
        },
      ),
    ),
  );
}

/// The page the split view toggle shows beside [tabId], and how: the
/// partner of its latest pair, in that pair's sides, layout and ratios, when
/// that tab is still one it can be shown with; otherwise the most recently
/// used such tab, as a fresh pair with [tabId] first. Null when there is none.
///
/// [tabs] are the open tabs, most recently used first.
({String first, String second, SplitPair? arrangement})? splitToggleTarget({
  required List<TabStateWithContainer> tabs,
  required String tabId,
  required SplitPair? lastPair,
}) {
  final candidates = splitPartnerCandidates(tabs: tabs, sourceTabId: tabId);
  final remembered = lastPair?.partnerOf(tabId);
  if (lastPair != null &&
      remembered != null &&
      candidates.any((entry) => entry.$1.id == remembered)) {
    return (
      first: lastPair.firstTabId,
      second: lastPair.secondTabId,
      arrangement: lastPair,
    );
  }

  final previous = candidates.firstOrNull;
  if (previous == null) return null;
  return (first: tabId, second: previous.$1.id, arrangement: null);
}

/// The split view toggle's "on": [tabId] beside its last partner, or the tab
/// used before it ([splitToggleTarget]), keeping [tabId] focused.
///
/// Returns false, doing nothing, when there is no such tab; the caller then
/// lets the user pick one ([showSplitPartnerPicker]). Everything is read
/// before the first await.
Future<bool> splitWithRememberedTab(
  ProviderRead read, {
  required String tabId,
  required SplitErrorReporter onError,
}) async {
  final target = splitToggleTarget(
    tabs: read(fifoTabStatesProvider).value,
    tabId: tabId,
    lastPair: read(splitViewControllerProvider.notifier).lastPairOf(tabId),
  );
  if (target == null) return false;

  await SplitPairing.of(read).pairAndSelect(
    first: target.first,
    second: target.second,
    arrangement: target.arrangement,
    select: null,
    onError: onError,
  );
  return true;
}

/// What the split view toggle stands for on a tab.
enum SplitToggleState {
  /// The tab is not in a split.
  off,

  /// The tab is in a split and both pages are on screen.
  shown,

  /// The tab is in a split, but "Show only this page" hides the other one.
  collapsed,
}

/// The toggle's state for a tab in [pair], or in none when null. For the
/// selected tab that is `activeSplitPairProvider`.
SplitToggleState splitToggleStateOf(SplitPair? pair) => pair == null
    ? SplitToggleState.off
    : pair.focusedOnly
    ? SplitToggleState.collapsed
    : SplitToggleState.shown;

/// The split view toggle, the same from the menu's quick toggle, the toolbar
/// button and the Split view action:
///
/// - [SplitToggleState.shown] ends the split; both tabs stay open.
/// - [SplitToggleState.collapsed] shows both pages again rather than ending a
///   split the user cannot see.
/// - [SplitToggleState.off] shows [tabId] beside its last partner, or the tab
///   used before it ([splitWithRememberedTab]).
///
/// Returns false, doing nothing, when there is no tab to show beside
/// [tabId]; the caller then lets the user pick one ([showSplitPartnerPicker]).
Future<bool> toggleSplitView(
  ProviderRead read, {
  required String tabId,
  required SplitToggleState state,
  required SplitErrorReporter onError,
}) async {
  final split = read(splitViewControllerProvider.notifier);
  switch (state) {
    case SplitToggleState.shown:
      split.end();
      return true;
    case SplitToggleState.collapsed:
      split.setFocusedOnly(false);
      return true;
    case SplitToggleState.off:
      return await splitWithRememberedTab(read, tabId: tabId, onError: onError);
  }
}

/// Reports a pair that could not be formed.
typedef SplitErrorReporter = void Function(SplitViewError error);

/// A [SplitErrorReporter] showing a snackbar. Resolved from [context] now,
/// so it still works after the widget that asked is gone (a closed dialog).
SplitErrorReporter splitErrorReporter(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  final show = errorMessengerFor(context);
  return (error) => show(error.describe(l10n));
}

/// Where a page opened to be shown beside [sourceTabId] goes: the source's
/// container unless the URL's site is assigned elsewhere, as for a link
/// opened from that page. The source need not be the selected tab, so the
/// selected container says nothing about it.
///
/// Reads before its first await.
Future<TabContainerSelection> splitPartnerContainerSelection(
  ProviderRead read,
  String sourceTabId,
) async {
  final container = await read(
    tabDataRepositoryProvider.notifier,
  ).getTabContainerData(sourceTabId);
  return TabContainerSelection.preferred(container);
}

/// What pairing needs, read up front, for a caller that leaves its screen
/// before it pairs.
class SplitPairing {
  final SplitViewController split;
  final TabRepository tabs;

  SplitPairing.of(ProviderRead read)
    : split = read(splitViewControllerProvider.notifier),
      tabs = read(tabRepositoryProvider.notifier);

  /// Pairs [first] and [second], then selects [select] once native shows the
  /// pair. Reports through [onError] and returns false when the pair cannot
  /// be formed; with [selectAloneOnFailure], [select] is then shown on its
  /// own.
  ///
  /// A request superseded by a newer one (or by ending the split) returns
  /// true without selecting anything: the newer request decides what is
  /// shown.
  Future<bool> pairAndSelect({
    required String first,
    required String second,
    required String? select,
    required SplitErrorReporter onError,
    bool selectAloneOnFailure = false,
    SplitPair? arrangement,
  }) async {
    try {
      await split.pair(first, second, arrangement: arrangement);
    } on SplitViewError catch (error) {
      if (error.kind == SplitViewErrorKind.superseded) return true;
      logger.w('Could not form split pair: $error');
      onError(error);
      if (selectAloneOnFailure && select != null) {
        await tabs.selectTab(select);
      }
      return false;
    }

    if (select != null) {
      await tabs.selectTab(select);
    }
    return true;
  }
}

/// A page picked to be shown beside [sourceTabId], with everything the pick
/// needs read while the picker is still up: [pair] and [present] run after
/// it is gone.
class SplitPickerDestination {
  final String sourceTabId;
  final TabContainerSelection? _pickedContainer;
  final TabDataRepository _tabData;
  final SplitPairing _pairing;
  final SplitErrorReporter _onError;
  final GoRouter _router;

  /// [pickedContainer] is where a new page goes, when the user picked one.
  SplitPickerDestination.capture(
    BuildContext context,
    ProviderRead read, {
    required this.sourceTabId,
    TabContainerSelection? pickedContainer,
  }) : _pickedContainer = pickedContainer,
       _tabData = read(tabDataRepositoryProvider.notifier),
       _pairing = SplitPairing.of(read),
       _onError = splitErrorReporter(context),
       _router = GoRouter.of(context);

  /// Where a new page goes: the picked container, otherwise the source's
  /// ([splitPartnerContainerSelection]).
  Future<TabContainerSelection> containerSelection() async =>
      _pickedContainer ??
      TabContainerSelection.preferred(
        await _tabData.getTabContainerData(sourceTabId),
      );

  /// Pairs [tabId] with the source and selects it once the pair is shown; if
  /// the pair cannot be formed it reports why and selects the tab on its own.
  Future<void> pair(String tabId) => _pairing.pairAndSelect(
    first: sourceTabId,
    second: tabId,
    select: tabId,
    selectAloneOnFailure: true,
    onError: _onError,
  );

  /// Goes to the browser, then [pair]s [tabId], opened unselected.
  ///
  /// The browser comes first: pairing waits for the new page's first state
  /// and its routing, and the picker must not stay up meanwhile.
  Future<void> present(String tabId) async {
    _router.go(const BrowserRoute().location);
    await pair(tabId);
  }
}

/// "Show beside current tab": the current tab and [tabId] together, with
/// [tabId] focused (it was picked explicitly). Closes the sheet that asked,
/// and once paired goes to the browser: the full-screen tray is a route of
/// its own, and the split would form behind it.
Future<void> showBesideCurrentTab(
  BuildContext context,
  ProviderRead read,
  String tabId,
) async {
  final current = read(selectedTabProvider);
  final router = GoRouter.maybeOf(context);
  final onError = splitErrorReporter(context);
  read(bottomSheetControllerProvider.notifier).requestDismiss();
  if (current == null || current == tabId) return;
  final paired = await SplitPairing.of(read).pairAndSelect(
    first: current,
    second: tabId,
    select: tabId,
    onError: onError,
  );
  if (paired) router?.go(const BrowserRoute().location);
}

/// "Open in split view" on a link: a new tab next to [sourceTabId], which
/// keeps focus. Same tab policy as "Open in new tab", in the source's
/// container unless the site is assigned elsewhere.
///
/// Everything is read from [ref] before the first await: the menu that asks
/// closes right away.
Future<void> openLinkInSplitView(
  WidgetRef ref, {
  required String sourceTabId,
  required Uri url,
  required SplitErrorReporter onError,
}) async {
  final source = ref.read(tabStateProvider(sourceTabId));
  if (source == null) return;
  final tabs = ref.read(tabRepositoryProvider.notifier);
  final pairing = SplitPairing.of(ref.read);

  final containerSelection = await splitPartnerContainerSelection(
    ref.read,
    sourceTabId,
  );

  final newTabId = await tabs.addTab(
    url: url,
    tabMode: source.tabMode,
    parentId: sourceTabId,
    selectTab: false,
    containerSelection: containerSelection,
  );

  await pairing.pairAndSelect(
    first: sourceTabId,
    second: newTabId,
    select: null,
    onError: onError,
  );
}
