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
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:nullability/nullability.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:synchronized/synchronized.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/extensions/uri.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_container_selection.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/providers/pending_tab_selection.dart';
import 'package:weblibre/features/geckoview/domain/providers/restore_complete.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_detail_state.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_list.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/controllers/home_target_controller.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/browser_data.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/startup_browsing_data_cleanup.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/entities/split_pair.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/providers/split_view.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/daos/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/database.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/isolation_context.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_source.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/proxy/domain/repositories/container_proxy.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/proxy_routing_settings.dart';
import 'package:weblibre/utils/debouncer.dart';

part 'tab.g.dart';

@visibleForTesting
ContainerData? resolveAssignedContainerForTabOpen({
  required TabContainerSelection containerSelection,
  required ContainerData? requestedContainer,
  required ContainerData? siteAssignedContainer,
}) {
  return switch (containerSelection) {
    UseSelectedContainerTabSelection() ||
    PreferredContainerTabSelection() ||
    OpenedFromTabContainerSelection() =>
      siteAssignedContainer ?? requestedContainer,
    UnassignedContainerTabSelection() ||
    SpecificContainerTabSelection() => requestedContainer,
  };
}

/// What a background tab's cancelled navigation calls for; see
/// [BackgroundStandIns.request].
@visibleForTesting
sealed class BackgroundReopen {
  const BackgroundReopen();
}

/// No tab stands in for this page yet: open one.
@visibleForTesting
final class OpenStandIn extends BackgroundReopen {
  const OpenStandIn();
}

/// [tabId] stands in for this page: load the new URL in it.
@visibleForTesting
final class LoadInStandIn extends BackgroundReopen {
  final String tabId;

  const LoadInStandIn(this.tabId);
}

/// The stand-in already shows this URL, or is still being opened and picks
/// the URL up once it is ([BackgroundStandIns.opened]).
@visibleForTesting
final class StandInCurrent extends BackgroundReopen {
  const StandInCurrent();
}

/// A page's stand-in: the tab (null while it is being opened), the URL it
/// should show, and the [BackgroundStandIns.stamp] at which it was opened.
class _StandIn {
  String? tabId;
  Uri url;
  int openedAt = 0;

  _StandIn(this.url);
}

/// The tabs that stand in for background tabs' cancelled navigations, so a
/// page that keeps trying reuses one tab instead of opening one per attempt.
///
/// A background page that keeps navigating to a site assigned elsewhere (an
/// auto-refresh, a login redirect on every attempt) would otherwise open a new
/// hidden tab each time. Dropping the repeats instead would lose navigations
/// that only look like them: `/view?id=1` then `/view?id=2`, or a callback
/// with a fresh code. So each page (origin and path) of a background tab gets
/// one stand-in tab, and a later navigation to that page loads its URL there:
/// the latest one wins, as it would have in the tab itself. Another path of
/// the site is another page with its own stand-in.
///
/// Nobody has seen a stand-in: once either tab is selected or closed, the next
/// navigation opens a new one rather than taking over a page the user may be
/// on. [sync] applies both from the native store right before each decision:
/// the Dart tab states keep closed tabs for a while, and the selection events
/// are debounced, so a stand-in closed or picked a moment ago still looks
/// open and unseen there. [forget] covers a tab seen and left again.
@visibleForTesting
class BackgroundStandIns {
  /// By source tab, then page: its stand-in.
  final _standIns = <String, Map<String, _StandIn>>{};

  int _clock = 0;

  /// Now, to pass as [sync]'s `takenAt` when asking the native store for its
  /// state: a stand-in [opened] after this is not in that state yet.
  int get stamp => _clock;

  static String _pageOf(Uri uri) =>
      '${uri.origin}${uri.path.isEmpty ? '/' : uri.path}';

  /// Applies the native store's state, asked for at [takenAt] (a [stamp]):
  /// drops what involves a closed tab (not among [openTabIds]) and the
  /// selected tab ([selectedTabId]), and [retire]s the tabs on screen beside
  /// it ([visibleTabIds], the other page of a split pair).
  ///
  /// The state arrives after an await, during which another report can have
  /// [opened] a stand-in. That tab is missing from [openTabIds] because it is
  /// newer than them, not because it closed, so it is kept. Without
  /// [takenAt], the state is taken to be current.
  void sync({
    required Iterable<String> openTabIds,
    String? selectedTabId,
    Iterable<String> visibleTabIds = const [],
    int? takenAt,
  }) {
    final open = openTabIds.toSet();
    final asOf = takenAt ?? _clock;
    _standIns.removeWhere((source, _) => !open.contains(source));
    for (final pages in _standIns.values) {
      pages.removeWhere(
        (_, standIn) =>
            standIn.tabId != null &&
            standIn.openedAt <= asOf &&
            !open.contains(standIn.tabId),
      );
    }
    _standIns.removeWhere((_, pages) => pages.isEmpty);
    if (selectedTabId != null) forget(selectedTabId);
    visibleTabIds.forEach(retire);
  }

  /// What background tab [sourceTabId]'s cancelled navigation to [uri] calls
  /// for, right after a [sync]. [OpenStandIn] claims the page at once, so a
  /// report arriving while the tab opens does not open a second one; follow
  /// it with [opened], or [release] when no tab came of it.
  BackgroundReopen request(String sourceTabId, Uri uri) {
    final pages = _standIns.putIfAbsent(sourceTabId, () => {});
    final page = _pageOf(uri);
    final standIn = pages[page];
    if (standIn == null) {
      pages[page] = _StandIn(uri);
      return const OpenStandIn();
    }
    if (standIn.url == uri) return const StandInCurrent();

    standIn.url = uri;
    return switch (standIn.tabId) {
      final tabId? => LoadInStandIn(tabId),
      null => const StandInCurrent(),
    };
  }

  /// Records [standInTabId], opened on [requested], as the stand-in. Returns
  /// the newer URL the page wants when a navigation came in while it opened,
  /// for the caller to load in the stand-in right away.
  ///
  /// That navigation belongs to the stand-in even if the user has picked
  /// either tab since: it came in before anyone saw the stand-in, so it would
  /// have loaded there had the tab been open. What comes in later goes
  /// through [request], whose load is sent after the caller's.
  Uri? opened(String sourceTabId, Uri requested, String standInTabId) {
    final standIn = _standIns[sourceTabId]?[_pageOf(requested)];
    // Seen or closed in the meantime: nothing stands in for it any more.
    if (standIn == null) return null;

    standIn
      ..tabId = standInTabId
      ..openedAt = ++_clock;
    return standIn.url == requested ? null : standIn.url;
  }

  /// Gives back a page whose stand-in could not be opened, so the next
  /// navigation tries again.
  void release(String sourceTabId, Uri uri) {
    final pages = _standIns[sourceTabId];
    if (pages == null) return;
    final page = _pageOf(uri);
    if (pages[page]?.tabId == null) pages.remove(page);
    if (pages.isEmpty) _standIns.remove(sourceTabId);
  }

  /// [tabId] was seen: it neither has stand-ins nor stands in any more.
  void forget(String tabId) {
    _standIns.remove(tabId);
    retire(tabId);
  }

  /// [tabId] is on screen: it no longer stands in for anything, so the next
  /// navigation of its page opens a new stand-in rather than replace a page
  /// the user may be reading. Its own stand-ins stay: a split pair's
  /// unfocused page keeps reusing them while it stays on screen, as a page
  /// retrying there would otherwise open a tab per attempt.
  void retire(String tabId) {
    for (final pages in _standIns.values) {
      pages.removeWhere((_, standIn) => standIn.tabId == tabId);
    }
    _standIns.removeWhere((_, pages) => pages.isEmpty);
  }
}

/// What replaced a tab, and the [TabReplacements.undoGeneration] at which the
/// old tab's close was through (null while it is still under way).
class _Replacement {
  final String newTabId;
  int? closedAt;

  _Replacement(this.newTabId, this.closedAt);
}

/// Tabs closed because another took their place (a reopen in the assigned
/// container, a container change), by the tab that replaced them, so a
/// selection still holding the old tab (a "tab opened" prompt) reaches the
/// new one.
///
/// An alias holds until the engine's undo brings the old tab back under its
/// id: that tab is then itself again. The old tab being open says nothing by
/// itself, since it is open until its close is through, and the native store
/// lists it a moment longer. So an alias is dropped only for a tab whose
/// close was through before an undo ran ([undone]) and that is open after
/// it. Each alias keeps the [undoGeneration] at which its close was through,
/// which a replacement recorded only after its new tab opened carries from
/// the close, so an undo in between is not lost.
@visibleForTesting
class TabReplacements {
  /// By old tab: what replaced it.
  final _replacedBy = <String, _Replacement>{};

  /// How many are kept: a prompt holding a replaced tab only lives as long as
  /// its snackbar.
  static const limit = 32;

  int _undoGeneration = 0;

  /// How many undos that brought tabs back have run. Read right after a
  /// close, to pass to [record] as `closedAt` once the replacement exists.
  int get undoGeneration => _undoGeneration;

  /// Records that [newTabId] took the place of [oldTabId], whose close was
  /// through at [closedAt] ([undoGeneration] then; now when omitted).
  void record(String oldTabId, String newTabId, {int? closedAt}) =>
      _put(oldTabId, _Replacement(newTabId, closedAt ?? _undoGeneration));

  /// Records that [newTabId] took the place of [oldTabId], whose close is
  /// still to come: follow with [closed] once it is through, or [drop] when
  /// it fails.
  void recordClosing(String oldTabId, String newTabId) =>
      _put(oldTabId, _Replacement(newTabId, null));

  void _put(String oldTabId, _Replacement replacement) {
    _replacedBy
      ..remove(oldTabId)
      ..[oldTabId] = replacement;
    while (_replacedBy.length > limit) {
      _replacedBy.remove(_replacedBy.keys.first);
    }
  }

  /// [oldTabId]'s close, recorded as still to come, is through.
  void closed(String oldTabId) {
    final entry = _replacedBy[oldTabId];
    if (entry != null) entry.closedAt ??= _undoGeneration;
  }

  /// Forgets that [oldTabId] was replaced: its close failed, and it stays.
  void drop(String oldTabId) => _replacedBy.remove(oldTabId);

  /// The engine's undo ran and brought tabs back. A replaced tab closed
  /// before it may be among them; [resolve] tells by whether it is open.
  void undone() => _undoGeneration++;

  /// Whether [tabId] was replaced, so [resolve] needs the open tabs.
  bool has(String tabId) => _replacedBy.containsKey(tabId);

  /// The tab standing in for [tabId] given the tabs open now
  /// ([openTabIds]): what replaced it, following replacements of
  /// replacements, unless an undo restored it. A restored tab drops its alias,
  /// so a later close of it is a close of its own, not a replacement.
  String resolve(String tabId, {required Set<String> openTabIds}) {
    var current = tabId;
    final seen = <String>{current};
    while (true) {
      final entry = _replacedBy[current];
      if (entry == null) return current;
      final closedAt = entry.closedAt;
      if (closedAt != null &&
          _undoGeneration > closedAt &&
          openTabIds.contains(current)) {
        _replacedBy.remove(current);
        return current;
      }
      if (!seen.add(entry.newTabId)) return current;
      current = entry.newTabId;
    }
  }
}

/// Replaces [oldTabId] with the tab [open] opens, then closes [oldTabId]
/// with [closeOld]. [focused] says whether [oldTabId] was the selected tab
/// when [open] began, and [open] selects the new tab only in that case.
///
/// The user can select [oldTabId] while the replacement opens, e.g. by
/// tapping a background tab's "tab opened" prompt. Closing it would then
/// hand the selection to some other tab. So the native selection
/// ([selectedTabId]) is asked again before the close, and a tab selected in
/// the meantime passes its selection to the replacement first. The close
/// goes by the native selection too, so it leaves the replacement selected.
/// The replacement is selected once more after the close anyway, as for a
/// [focused] tab, so a close that still moved the selection on (it raced the
/// selection) does not decide what the user sees.
///
/// Past the point of no return: once the replacement exists, the swap is
/// finished even if a newer navigation has claimed [oldTabId] since.
/// Abandoning it would leave the new tab created but [oldTabId] still open.
/// Only a disposed repository ([isMounted]) stops it.
@visibleForTesting
Future<String> replaceTabOpeningFirst({
  required String oldTabId,
  required bool focused,
  required Future<String> Function() open,
  required Future<String?> Function() selectedTabId,
  required Future<void> Function(String newTabId) closeOld,
  required Future<void> Function(String tabId) select,
  required bool Function() isMounted,
}) async {
  final newTabId = await open();
  if (!isMounted()) return newTabId;

  final selectedMeanwhile =
      !focused && await selectedTabId() == oldTabId && isMounted();
  if (selectedMeanwhile) await select(newTabId);
  if (!isMounted()) return newTabId;

  await closeOld(newTabId);
  if ((focused || selectedMeanwhile) && isMounted()) await select(newTabId);
  return newTabId;
}

/// The tab to select after the selected [closedTabId] closes, when it is in
/// the split [pair]: its partner, which is on screen already. Null when there
/// is no pair, or the partner closes too ([excludedTabIds]) or is gone, and
/// the usual order (opener, previous, neighbor) decides.
@visibleForTesting
String? splitPartnerAfterClose({
  required SplitPair? pair,
  required String closedTabId,
  required Set<String> excludedTabIds,
  required Iterable<String> openTabIds,
}) {
  final partner = pair?.partnerOf(closedTabId);
  if (partner == null || excludedTabIds.contains(partner)) return null;
  return openTabIds.contains(partner) ? partner : null;
}

/// The tab one step from [currentTabId] in [order], or `null` when there is no
/// step to take.
///
/// Kept as a pure function so the whole of sequential navigation's decision
/// making can be exercised without an engine: which tab is next is settled
/// here, and the repository only carries out the selection.
///
/// Returns `null` — never a fallback pick — in each case where the sequence
/// gives no answer:
///
/// - [currentTabId] is absent from [order]: it is out of this walk's reach
///   (another container, or a tab the engine has not reported yet), so nothing
///   in [order] is "adjacent" to it. Entering at an end instead is what made a
///   swipe jump across the strip in issue #603;
/// - the step falls off an end and [loop] is off;
/// - [order] holds fewer than two tabs, where even a wrap would land back on
///   the tab the user is already looking at, which is not a step.
@visibleForTesting
String? adjacentTabIdInOrder({
  required List<String> order,
  required String currentTabId,
  required bool selectPrevious,
  required bool loop,
}) {
  final index = order.indexOf(currentTabId);
  if (index < 0 || order.length < 2) {
    return null;
  }

  final targetIndex = selectPrevious ? index - 1 : index + 1;

  if (targetIndex < 0) {
    return loop ? order.last : null;
  }
  if (targetIndex >= order.length) {
    return loop ? order.first : null;
  }

  return order[targetIndex];
}

/// What back does once a tab has run out of page history.
///
/// Only for tabs that were opened from somewhere the user expects back to
/// return them to. Without one, back falls through to the double-back-to-close
/// handling, which is right for a tab opened from another tab — its opener is
/// underneath it — and wrong for one opened from a surface that is no longer
/// on screen.
sealed class TabBackBehavior {
  const TabBackBehavior();
}

/// Asks whether to keep the tab, then leaves the app.
///
/// For a tab an external app launched: back belongs to whoever sent us here.
final class BackgroundAppTabBackBehavior extends TabBackBehavior {
  const BackgroundAppTabBackBehavior();
}

/// Asks whether to keep the tab, then reopens the search screen.
final class ReturnToSearchTabBackBehavior extends TabBackBehavior {
  final TabType tabType;

  const ReturnToSearchTabBackBehavior({required this.tabType});
}

/// Shows the browser home surface again, keeping the tab.
///
/// For a tab opened from home — a shortcut, a bookmark, a history entry. Unlike
/// the two above this asks nothing and closes nothing: home is a surface over
/// the selected tab rather than a place the tab has to be given up to reach, and
/// the tab is one tap away again from the tab bar. Back on a shortcut used to
/// land in the double-back-to-close prompt, which offered to throw the page away
/// but never led home (#623).
final class ReturnToBrowserHomeTabBackBehavior extends TabBackBehavior {
  const ReturnToBrowserHomeTabBackBehavior();
}

@Riverpod(keepAlive: true)
class TabRepository extends _$TabRepository {
  final _tabsService = GeckoTabService();
  final _recentlyClosedService = GeckoRecentlyClosedTabsService();
  final _sessionStartedAt = DateTime.now();
  bool _didPruneTombstones = false;
  bool _reclosing = false;
  bool _suppressNextReclose = false;

  final _tabBackBehavior = <String, TabBackBehavior>{};
  final _closeLock = Lock();
  final _pendingIsolationCleanup = <String>{};

  /// The site-assignment request currently being handled for each tab.
  ///
  /// Handling one means waiting for the tab's content state and then reading
  /// containers out of the database, and the engine can start another
  /// navigation in that tab in the meantime. The earlier request is obsolete
  /// once that happens: reopening its URL would pull the tab back to a page the
  /// engine has already left.
  final _latestAssignmentRequests = <String, String>{};

  /// The tabs standing in for background tabs' cancelled navigations; see
  /// [BackgroundStandIns].
  final _backgroundStandIns = BackgroundStandIns();

  /// Tabs closed because another took their place; see [TabReplacements].
  final _replacements = TabReplacements();

  /// Closes [oldTabId], then opens the tab that takes its place with
  /// [openReplacement] and records the replacement ([TabReplacements]). A
  /// selection of [oldTabId] from then on selects the new tab while
  /// [oldTabId] stays closed: the "tab opened" prompt of a link opened in the
  /// background still holds the tab that a container change replaced.
  Future<String> replaceTabClosingFirst(
    String oldTabId,
    Future<String> Function() openReplacement,
  ) async {
    // The replacement stands in for it, so it was never closed.
    await closeTab(oldTabId, keepOffRecentlyClosed: true);
    // Read now: an undo while the replacement opens may restore it.
    final closedAt = _replacements.undoGeneration;
    final newTabId = await openReplacement();
    if (ref.mounted) {
      _replacements.record(oldTabId, newTabId, closedAt: closedAt);
    }
    return newTabId;
  }

  /// Closes [oldTabId], which [newTabId] took the place of, and records the
  /// replacement before the close: a selection while it is under way (a
  /// close waits for any other in progress) already reaches [newTabId].
  Future<void> _closeReplacedTab(String oldTabId, String newTabId) async {
    _replacements.recordClosing(oldTabId, newTabId);
    try {
      // The replacement stands in for it, so it was never closed.
      await closeTab(oldTabId, keepOffRecentlyClosed: true);
    } catch (_) {
      _replacements.drop(oldTabId);
      rethrow;
    }
    _replacements.closed(oldTabId);
  }

  /// The split pair on screen (shown, with the selected tab in it), as of
  /// the last [_onVisiblePairChange].
  SplitPair? _visiblePair;

  /// A split pair coming on screen shows its unselected page too, which is
  /// seen like a selected one ([BackgroundStandIns.forget]); the selection
  /// listener covers only the selected page. The pair from
  /// [splitPairShownProvider] and the selection, not [activeSplitPairProvider],
  /// which is auto-disposed and so cannot be listened to from here.
  void _onVisiblePairChange() {
    final pair = ref.read(splitPairShownProvider);
    final selectedTabId = ref.read(selectedTabProvider);
    final visible =
        selectedTabId != null && (pair?.contains(selectedTabId) ?? false)
        ? pair
        : null;
    final previous = _visiblePair;
    _visiblePair = visible;
    if (visible == null) return;

    for (final tabId in [visible.firstTabId, visible.secondTabId]) {
      if (previous?.contains(tabId) ?? false) continue;
      _backgroundStandIns.forget(tabId);
    }
  }

  /// Follows [splitPairShownProvider] into [_onVisiblePairChange], listening
  /// through the container rather than [ref]. A `ref.listen` would make this
  /// repository a dependent of [splitViewControllerProvider], which reads this
  /// repository (`SplitViewController.pair` checks routing here): a
  /// [CircularDependencyError] on every pairing in debug builds.
  @visibleForTesting
  void followVisiblePair() {
    final subscription = ref.container.listen(
      splitPairShownProvider,
      (_, _) => _onVisiblePairChange(),
    );
    ref.onDispose(subscription.close);
  }

  TabBackBehavior? backBehaviorFor(String? tabId) {
    if (tabId == null) {
      return null;
    }

    return _tabBackBehavior[tabId];
  }

  void clearBackBehavior(String tabId) {
    _tabBackBehavior.remove(tabId);
  }

  /// Validates the opener of a tab that is about to be created.
  ///
  /// The link is kept even when the new tab lands in a *different* container
  /// than its opener. Following a link into a container-assigned site reopens
  /// that site over there, and the opener is then the only way back once the
  /// reopened tab runs out of its own history — cutting the link stranded the
  /// user in the target container (#530).
  ///
  /// Only a parent that has no row (yet) is dropped: `tab.parent_id` carries a
  /// self-referential foreign key, so writing a dangling id would abort the
  /// insert transaction.
  Future<String?> _resolveParentId(String? parentId) async {
    if (parentId == null) {
      return null;
    }

    final parent = await ref
        .read(tabDatabaseProvider)
        .tabDao
        .getTabDataById(parentId)
        .getSingleOrNull();

    return parent != null ? parentId : null;
  }

  /// Opens a tab and returns its id.
  ///
  /// [onCreated] is called with that id as soon as the engine has created the
  /// tab, before its row is written and, for a selected tab, before the
  /// selected container follows it.
  ///
  /// With [parentIsReferrer] (the default) the page loads as if the parent's
  /// page had linked to it. Pass false for pages the browser opens itself
  /// beside the parent: Gecko refuses privileged about: pages that a web page
  /// links to.
  Future<String> addTab({
    required TabMode tabMode,
    Uri? url,
    required bool selectTab,
    bool startLoading = true,
    String? parentId,
    LoadUrlFlags flags = LoadUrlFlags.NONE,
    Source source = Internal.newTab,
    HistoryMetadataKey? historyMetadata,
    Map<String, String>? additionalHeaders,
    TabContainerSelection containerSelection =
        const TabContainerSelection.useSelected(),
    bool launchedFromIntent = false,
    TabBackBehavior? onBackBehavior,
    void Function(String tabId)? onCreated,
    bool parentIsReferrer = true,
  }) async {
    // The startup cleanup deletes the previous session's cookies, cache and
    // site data; a page opened before it finished would lose its own with them.
    // (Its tab deletion is scoped to restored tabs and cannot reach this one.)
    await ref.read(startupBrowsingDataCleanupProvider.notifier).waitUntilDone();

    final tabDao = ref.read(tabDatabaseProvider).tabDao;

    var assignedContainer = await _requestedContainer(containerSelection);

    if (tabMode is RegularTabMode &&
        url != null &&
        url.hasAuthority &&
        url.isHttpOrHttps) {
      final siteAssignedContainerId = await ref
          .read(containerRepositoryProvider.notifier)
          .siteAssignedContainerId(url);
      final siteAssignedContainer = await siteAssignedContainerId.mapNotNull(
        (id) =>
            ref.read(containerRepositoryProvider.notifier).getContainerData(id),
      );

      assignedContainer = resolveAssignedContainerForTabOpen(
        containerSelection: containerSelection,
        requestedContainer: assignedContainer,
        siteAssignedContainer: siteAssignedContainer,
      );
    }

    final validatedParentId = await _resolveParentId(parentId);

    final effectiveIsolationContextId = tabMode.isolationContextId;

    final effectiveContextId = tabMode is IsolatedTabMode
        ? effectiveIsolationContextId
        : assignedContainer?.metadata.contextualIdentity;

    final newTabId = await tabDao.upsertTabTransactional(
      () async {
        final tabId = await _tabsService.addTab(
          url: url,
          selectTab: selectTab,
          startLoading: startLoading,
          parentId: validatedParentId,
          flags: flags,
          contextId: effectiveContextId,
          source: source,
          private: tabMode is PrivateTabMode,
          historyMetadata: historyMetadata,
          additionalHeaders: additionalHeaders,
          // Carried into the engine so the exclusion is in place before the tab
          // loads; the replicated snapshot only follows once its row is written.
          excludeFromHistory:
              assignedContainer?.metadata.excludeFromHistory ?? false,
          parentIsReferrer: parentIsReferrer,
        );
        onCreated?.call(tabId);
        return tabId;
      },
      parentId: Value(validatedParentId),
      containerId: Value(assignedContainer?.id),
      url: Value(url),
      tabMode: Value(tabMode),
      childPlacement: ref
          .read(generalSettingsWithDefaultsProvider)
          .childTabPlacement,
    );

    if (launchedFromIntent) {
      _tabBackBehavior[newTabId] =
          onBackBehavior ?? const BackgroundAppTabBackBehavior();
    } else if (onBackBehavior != null) {
      _tabBackBehavior[newTabId] = onBackBehavior;
    }

    if (selectTab && ref.mounted) {
      _clearForceBrowserHome();

      await ref
          .read(selectedContainerProvider.notifier)
          .followTab(assignedContainer?.id);
    }

    return newTabId;
  }

  /// The container [selection] asks for, before a site assignment has its
  /// say ([resolveAssignedContainerForTabOpen]).
  Future<ContainerData?> _requestedContainer(
    TabContainerSelection selection,
  ) async => switch (selection) {
    UseSelectedContainerTabSelection() =>
      await ref.read(selectedContainerProvider.notifier).fetchData(),
    UnassignedContainerTabSelection() => null,
    SpecificContainerTabSelection(:final container) => container,
    PreferredContainerTabSelection(:final container) => container,
    OpenedFromTabContainerSelection(:final tabId) =>
      await ref
          .read(tabDataRepositoryProvider.notifier)
          .getContainerForCopy(tabId),
  };

  Future<bool> _closeRestoredPrivateCaptureTabs(List<String> tabIds) async {
    if (tabIds.isEmpty) {
      return false;
    }

    final captureRows = await ref
        .read(tabDatabaseProvider)
        .captureTabDao
        .findAll();
    final tabStates = ref.read(tabStatesProvider);
    final restoredPrivateCaptureTabIds = captureRows
        .where((row) => row.createdAt.isBefore(_sessionStartedAt))
        .map((row) => row.tabId)
        .where((tabId) => tabIds.contains(tabId))
        .where((tabId) => tabStates[tabId]?.tabMode is PrivateTabMode)
        .toList(growable: false);

    if (restoredPrivateCaptureTabIds.isEmpty) {
      return false;
    }

    await _closeTabsInternal(
      restoredPrivateCaptureTabIds,
      recordTombstones: false,
    );
    return true;
  }

  Future<List<String>> addMultipleTabs({
    required List<AddTabParams> tabs,
    String? selectTabId,
    TabContainerSelection containerSelection =
        const TabContainerSelection.unassigned(),
  }) async {
    final tabDao = ref.read(tabDatabaseProvider).tabDao;
    final db = ref.read(tabDatabaseProvider);
    final assignedContainer = await _requestedContainer(containerSelection);
    // Read once for the whole batch rather than per tab: the setting cannot
    // change while these rows are being written.
    final childPlacement = ref
        .read(generalSettingsWithDefaultsProvider)
        .childTabPlacement;

    final createdTabIds = await db.transaction(() async {
      final createdTabIds = await _tabsService.addMultipleTabs(
        tabs: tabs,
        selectTabId: selectTabId,
        // Carried into the engine so the exclusion is in place before these tabs
        // load; the replicated snapshot only follows once their rows are
        // written. One value for the batch — they all land in this container.
        excludeFromHistory:
            assignedContainer?.metadata.excludeFromHistory ?? false,
      );
      // Build sets for validation
      final creatingTabIds = createdTabIds.toSet();
      final parentIdsToValidate = tabs
          .map((tab) => tab.parentId)
          .whereType<String>()
          .where((id) => !creatingTabIds.contains(id))
          .toSet();

      // Batch validate parent IDs that aren't in the current creation batch
      final existingParentIds = await tabDao
          .getExistingTabIds(parentIdsToValidate)
          .get()
          .then((ids) => ids.toSet());

      // Upsert all tabs in the database
      for (var i = 0; i < createdTabIds.length; i++) {
        final tabId = createdTabIds[i];
        final tab = tabs[i];

        // Validate parent exists in either the batch being created or database
        String? validatedParentId;
        if (tab.parentId != null) {
          if (creatingTabIds.contains(tab.parentId) ||
              existingParentIds.contains(tab.parentId)) {
            validatedParentId = tab.parentId;
          }
        }

        await tabDao.insertTab(
          tabId,
          parentId: Value(validatedParentId),
          source: TabSource.manual,
          containerId: Value(assignedContainer?.id),
          url: Value(Uri.tryParse(tab.url)),
          childPlacement: childPlacement,
          tabMode: Value(
            isIsolatedContextId(tab.contextId)
                ? TabMode.isolated(tab.contextId!)
                : tab.private
                ? TabMode.private
                : TabMode.regular,
          ),
        );
      }

      return createdTabIds;
    });

    if (selectTabId != null && ref.mounted) {
      _clearForceBrowserHome();
    }

    return createdTabIds;
  }

  Future<String> duplicateTab({
    required String selectTabId,
    required ContainerData? containerData,
    required bool selectTab,
  }) async {
    final tabDao = ref.read(tabDatabaseProvider).tabDao;

    final sourceTabMode =
        await tabDao.getTabMode(selectTabId).getSingleOrNull() ??
        TabMode.regular;

    // Duplicating an isolated tab creates a new isolation group
    final duplicateIsolationContextId = sourceTabMode is IsolatedTabMode
        ? newIsolatedContextId()
        : null;

    final duplicateTabMode = sourceTabMode is IsolatedTabMode
        ? TabMode.isolated(duplicateIsolationContextId!)
        : sourceTabMode;

    // Isolated tabs always use their isolation context ID
    final effectiveContextId = sourceTabMode is IsolatedTabMode
        ? duplicateIsolationContextId
        : containerData?.metadata.contextualIdentity;

    // Place the duplicate as a sibling of the source — same parent — and
    // insert it right after the source's full subtree, so existing
    // children of the source are not split from their parent.
    final sourceData = await tabDao
        .getTabDataById(selectTabId)
        .getSingleOrNull();
    final sourceParentId = sourceData?.parentId;
    final anchorTabId =
        await tabDao
            .lastSubtreeTabIdByOrderKey(
              selectTabId,
              containerId: containerData?.id,
            )
            .getSingleOrNull() ??
        selectTabId;

    final newTabId = await tabDao.upsertTabTransactional(
      () {
        return _tabsService.duplicateTab(
          selectTabId: selectTabId,
          newContextId: effectiveContextId,
          selectNewTab: selectTab,
          excludeFromHistory:
              containerData?.metadata.excludeFromHistory ?? false,
        );
      },
      parentId: Value(sourceParentId),
      afterTabId: Value(anchorTabId),
      containerId: Value(containerData?.id),
      tabMode: Value(duplicateTabMode),
    );

    // The duplicate is a new isolation group, so it starts with no route of its
    // own — carry the source's over, or the copy silently falls back to its
    // container's routing.
    if (sourceTabMode case IsolatedTabMode(
      :final isolationContextId,
    ) when ref.mounted) {
      await ref
          .read(proxyRoutingSettingsRepositoryProvider.notifier)
          .copyIsolationContextRoute(
            isolationContextId,
            duplicateIsolationContextId!,
          );
    }

    if (selectTab && ref.mounted) {
      _clearForceBrowserHome();
    }

    return newTabId;
  }

  Future<bool> selectPreviouslyOpenedTab(String tabId) async {
    final previousTabId = await ref
        .read(tabDatabaseProvider)
        .definitionsDrift
        .previousTabByTimestamp(tabId: tabId)
        .getSingleOrNull();

    if (ref.mounted && previousTabId != null) {
      return await selectTab(previousTabId);
    }

    return false;
  }

  Future<bool> resumeLatestTab({Set<String> excludedTabIds = const {}}) async {
    final latestTab = await ref
        .read(tabDatabaseProvider)
        .tabDao
        .getTabsFifo(limit: 1, excludedTabIds: excludedTabIds)
        .getSingleOrNull();

    if (!ref.mounted || latestTab == null) {
      return false;
    }

    return await selectTab(latestTab.id);
  }

  Future<bool> resumeLatestContainerTab(
    String? containerId, {
    Set<String> excludedTabIds = const {},
  }) async {
    final latestTab = await ref
        .read(tabDatabaseProvider)
        .tabDao
        .getContainerTabsFifo(
          containerId,
          limit: 1,
          excludedTabIds: excludedTabIds,
        )
        .getSingleOrNull();

    if (!ref.mounted || latestTab == null) {
      return false;
    }

    return await selectTab(latestTab.id);
  }

  Future<bool> selectPreviousTab(
    String tabId, {
    String? containerId,
    bool skipContainerCheck = true,
  }) => _selectAdjacentTab(
    tabId,
    containerId: containerId,
    skipContainerCheck: skipContainerCheck,
    selectPrevious: true,
  );

  Future<bool> selectNextTab(
    String tabId, {
    String? containerId,
    bool skipContainerCheck = true,
  }) => _selectAdjacentTab(
    tabId,
    containerId: containerId,
    skipContainerCheck: skipContainerCheck,
    selectPrevious: false,
  );

  /// Moves the selection one step through the tab sequence.
  ///
  /// Calls that cross containers ([skipContainerCheck] with no explicit
  /// [containerId]) — the tab bar swipe and the next/previous tab gestures —
  /// step through the *rendered* order
  /// ([sequentialTabNavigationOrderProvider]) so navigation matches the tabs the
  /// user sees: the same grouping and pinned-first handling the quick tab
  /// switcher and the tab bar draw, and deliberately none of the tray's own
  /// filters, collapsed groups or sort (see [TabListScope]). That order spans
  /// every populated container while `sequentialTabNavigationCrossContainers` is
  /// on, so this keeps walking past a container boundary exactly like the
  /// storage-order walk did; with the setting off it holds the selected
  /// container only and the walk ends there. It is authoritative once it
  /// exists, and every outcome stays inside it:
  ///
  /// - current tab in the order: step one row, stopping at either end — or
  ///   continuing at the opposite end when `sequentialTabNavigationLoop` is on;
  /// - current tab outside it: do nothing. Since the order excludes nothing,
  ///   the current tab is missing only when it is not in this walk's reach at
  ///   all — another container with cross-container navigation off, or a tab the
  ///   engine has not reported yet. Neither says anything about which tab is
  ///   "next", so there is no step to take; selecting an end of the order
  ///   instead (as this did before #603) turned a swipe into a jump across the
  ///   whole strip.
  /// - nothing visible at all: do nothing.
  ///
  /// Looping is deliberately confined to this path: the storage-order fallback
  /// below serves container-scoped stepping and the window before the tree data
  /// has loaded, where there is no rendered sequence whose ends could be joined.
  ///
  /// The storage-order path is left for calls that scope navigation to a single
  /// container (which the cross-container order cannot answer) and for the brief
  /// window before the tree data has loaded.
  Future<bool> _selectAdjacentTab(
    String tabId, {
    required String? containerId,
    required bool skipContainerCheck,
    required bool selectPrevious,
  }) async {
    if (containerId == null && skipContainerCheck) {
      final visibleOrder = ref.read(sequentialTabNavigationOrderProvider).value;

      if (visibleOrder != null) {
        final targetTabId = adjacentTabIdInOrder(
          order: visibleOrder,
          currentTabId: tabId,
          selectPrevious: selectPrevious,
          loop: ref
              .read(generalSettingsWithDefaultsProvider)
              .sequentialTabNavigationLoop,
        );

        // The rendered order is authoritative once it exists: having no step to
        // take within it is an answer, not a reason to consult storage order.
        return targetTabId != null && await selectTab(targetTabId);
      }
    }

    final adjacentTabId = await _adjacentVisibleTabByOrder(
      tabId,
      containerId: containerId,
      skipContainerCheck: skipContainerCheck,
      selectPrevious: selectPrevious,
    );

    if (ref.mounted && adjacentTabId != null) {
      return await selectTab(adjacentTabId);
    }

    return false;
  }

  Future<bool> selectTab(String requestedTabId) async {
    // A replaced tab: what replaced it is the tab meant, unless an undo
    // brought it back ([TabReplacements]). Whether it is open is asked of the
    // native store; the Dart tab states keep a closed tab for a while.
    final tabId = _replacements.has(requestedTabId)
        ? _replacements.resolve(
            requestedTabId,
            openTabIds: (await _tabsService.getTabIds()).toSet(),
          )
        : requestedTabId;
    if (!ref.mounted) return false;

    // The tab is still a pre-restore placeholder (known to the DB but not to
    // the engine yet): queue the selection until the native state arrives.
    if (!ref.read(browserRestoreCompleteProvider) &&
        !ref.read(tabStatesProvider).containsKey(tabId)) {
      ref.read(pendingTabSelectionProvider.notifier).queue(tabId);
      _clearForceBrowserHome();
      return true;
    }

    // Started before the tab's own check so both run concurrently.
    final partnerCheck = _startSplitPartnerRoutingCheck(tabId);

    final containerData = await ref
        .read(tabDataRepositoryProvider.notifier)
        .getTabContainerData(tabId);

    if (!ref.mounted ||
        !await _routingReadyFor(tabId, containerData) ||
        !ref.mounted) {
      partnerCheck?.result.ignore();
      return false;
    }

    if (partnerCheck != null) {
      // A proxied tab has just waited for the one routing install every
      // container shares, so the partner's check settles at its next probe.
      // A direct tab waited for nothing and is not held back for its partner.
      if (_isProxied(containerData)) {
        await partnerCheck.result;
        if (!ref.mounted) return false;
      }
      if (!partnerCheck.isReadyNow) {
        _showAloneUntilPartnerRouted(
          pairId: partnerCheck.pairId,
          tabId: tabId,
          partnerCheck: partnerCheck.result,
        );
      }
    }

    _clearForceBrowserHome();

    // Selecting the tab that is already selected changes nothing in the
    // engine, so [SelectedContainer], which follows selection *changes*, never
    // hears of it. The tab can still be off screen because another container
    // was picked since (see [shouldShowBrowserHome]); bring its container back
    // with it, or re-selecting it from the tab bar does nothing (#667).
    if (ref.read(selectedTabProvider) == tabId) {
      final result = await ref
          .read(selectedContainerProvider.notifier)
          .followTab(containerData?.id);
      if (!ref.mounted) return false;

      // The tab stays under home, so nothing was shown.
      if (result == SetContainerResult.failed) {
        logger.w(
          'Could not bring back the container of re-selected tab $tabId',
        );
        return false;
      }
    }

    await _tabsService.selectTab(tabId: tabId);
    return true;
  }

  /// Whether [tabId] may be shown as far as its container's proxy routing is
  /// concerned: always for a direct container, and for a proxied one only once
  /// its routing is installed.
  Future<bool> ensureRoutingReady(String tabId) async {
    final containerData = await ref
        .read(tabDataRepositoryProvider.notifier)
        .getTabContainerData(tabId);
    if (!ref.mounted) return false;
    return await _routingReadyFor(tabId, containerData);
  }

  /// Starts checking the routing of the split partner that selecting [tabId]
  /// brings on screen. A split member brings its partner on screen, so the
  /// partner's routing has to be installed too. Rather than refusing the tab
  /// the user asked for, or holding it back, it is shown alone until the
  /// partner can be shown.
  ///
  /// Null when [tabId] has no partner in the shown pair, or the pair is
  /// already on screen: focus moving between the panes waits for nothing,
  /// just as a tap on a pane does not.
  _SplitPartnerRoutingCheck? _startSplitPartnerRoutingCheck(String tabId) {
    final pair = ref.read(splitPairShownProvider);
    final partner = pair?.partnerOf(tabId);
    final selectedBefore = ref.read(selectedTabProvider);
    if (pair == null || partner == null) return null;

    final pairOnScreen = selectedBefore == tabId || selectedBefore == partner;
    if (pairOnScreen) return null;

    return _SplitPartnerRoutingCheck(
      pairId: pair.pairId,
      routingReady: ensureRoutingReady(partner),
    );
  }

  /// Shows [tabId] alone in its pair [pairId] while its partner's routing
  /// is not installed, and both pages again once [partnerCheck] finds it is.
  /// A pair already showing one page is left as it is.
  ///
  /// Both pages come back only while the pair is still exactly what this
  /// collapse made it: anything done to it since (showing both and hiding
  /// one again, a swap, a new partner) is a newer choice, and wins.
  void _showAloneUntilPartnerRouted({
    required String pairId,
    required String tabId,
    required Future<bool> partnerCheck,
  }) {
    final split = ref.read(splitViewControllerProvider.notifier);
    if (ref.read(splitViewControllerProvider)?.focusedOnly ?? true) return;
    if (!split.collapseTo(pairId, tabId)) return;
    final collapsed = ref.read(splitViewControllerProvider);

    unawaited(
      partnerCheck.then((ready) {
        if (!ref.mounted) return;
        if (ready) {
          if (identical(ref.read(splitViewControllerProvider), collapsed)) {
            split.showBothPages(pairId);
          }
        } else {
          logger.w('Split partner of $tabId has no routing; showing it alone');
        }
      }),
    );
  }

  bool _isProxied(ContainerData? containerData) =>
      containerData?.metadata.proxyConnectionId != null;

  Future<bool> _routingReadyFor(
    String tabId,
    ContainerData? containerData,
  ) async {
    if (!_isProxied(containerData)) {
      return true;
    }

    // Routing has to be *installed*, not merely answering: an extension
    // that responds but holds no snapshot blocks this container's traffic,
    // so opening the tab would only show a broken page.
    //
    // Waited on rather than sampled, because the install window is a normal
    // part of a cold start and a tap that lands inside it should open the
    // tab a moment later instead of doing nothing at all.
    final routingReady = await ref
        .read(containerProxyRepositoryProvider.notifier)
        .waitUntilRoutingReady();

    if (!ref.mounted) return false;

    if (!routingReady) {
      logger.w(
        'Tried to open proxied tab $tabId before container routing was installed',
      );
    }
    return routingReady;
  }

  /// Cancels a pending "stay on home", because something is about to be shown.
  ///
  /// Done explicitly at each selection rather than by listening to the selected
  /// tab: the engine selects tabs on its own (restore, session recovery) and
  /// such a listener would immediately undo the flag the home target had just
  /// set. Call it only once the selection is certain — a proxy healthcheck can
  /// still refuse it, and discarding the flag then would drop the user off home
  /// without putting anything in its place.
  void _clearForceBrowserHome() {
    ref.read(forceBrowserHomeProvider.notifier).clear();
  }

  /// Selects [tabId] on behalf of the engine's own follow-up logic, i.e. not
  /// because the user asked for this particular tab.
  ///
  /// Still counts as leaving home: a neighbour is now on screen, so a
  /// "stay on home" left over from an earlier close no longer describes
  /// anything. Safe against the home target's own flag, because the branch of
  /// [_selectNextTab] that sets it is reached only when nothing was selected
  /// here.
  Future<void> _selectTabAfterClose(String tabId) async {
    _clearForceBrowserHome();
    await _tabsService.selectTab(tabId: tabId);
  }

  Future<String?> _adjacentVisibleTabByOrder(
    String tabId, {
    required String? containerId,
    required bool skipContainerCheck,
    required bool selectPrevious,
  }) {
    // Storage-order walk: neighbours by `order_key` only, so it sees neither
    // the tray's sort and filters nor its grouping. User-facing sequential
    // navigation goes through the rendered order in [_selectAdjacentTab] and
    // reaches this only as a fallback; what remains here is picking a tab
    // after a close and container-scoped stepping.
    //
    // "Previous/next" is interpreted relative to the *tab bar* direction,
    // which is the only direction this path has to go by.
    final newestFirst =
        ref.read(generalSettingsWithDefaultsProvider).tabBarDirection ==
        TabDirection.newestFirst;
    final TabDatabase tabDatabase = ref.read(tabDatabaseProvider);
    final definitions = tabDatabase.definitionsDrift;

    if (newestFirst == selectPrevious) {
      return definitions
          .nextTabByOrderKey(
            tabId: tabId,
            containerId: containerId,
            skipContainerCheck: skipContainerCheck,
          )
          .getSingleOrNull();
    }

    return definitions
        .previousTabByOrderKey(
          tabId: tabId,
          containerId: containerId,
          skipContainerCheck: skipContainerCheck,
        )
        .getSingleOrNull();
  }

  Future<String?> _nearestAvailableVisibleTabByOrder(
    String tabId, {
    required String? containerId,
    required Set<String> excludedTabIds,
  }) async {
    Future<String?> walkDirection({required bool selectPrevious}) async {
      var candidate = await _adjacentVisibleTabByOrder(
        tabId,
        containerId: containerId,
        skipContainerCheck: false,
        selectPrevious: selectPrevious,
      );

      while (candidate != null) {
        if (!excludedTabIds.contains(candidate)) {
          return candidate;
        }

        candidate = await _adjacentVisibleTabByOrder(
          candidate,
          containerId: containerId,
          skipContainerCheck: false,
          selectPrevious: selectPrevious,
        );
      }

      return null;
    }

    return await walkDirection(selectPrevious: true) ??
        await walkDirection(selectPrevious: false);
  }

  /// Nearest still-open ancestor of [tabId], or `null` when the chain runs out.
  ///
  /// The stored chain is the authority: `tab_maintain_parent_chain_on_delete`
  /// repoints a child at its grandparent as soon as the parent row goes away,
  /// whereas the engine's `parentId` only reaches Dart with that tab's *next*
  /// content-state event and can still name a tab that is already closed. The
  /// engine value is therefore only consulted while the row itself is missing,
  /// i.e. before the insert for a freshly opened tab has landed.
  ///
  /// An ancestor in another container is a valid target: selecting it moves the
  /// tray along with it (see `SelectedContainer`), which is the way back out of
  /// a container a link pulled the user into (#530).
  Future<String?> _nearestAvailableAncestor(
    String tabId, {
    required Set<String> excludedTabIds,
  }) async {
    final tabDao = ref.read(tabDatabaseProvider).tabDao;
    final row = await tabDao.getTabDataById(tabId).getSingleOrNull();

    if (!ref.mounted) return null;

    var candidate = row != null
        ? row.parentId
        : ref.read(tabStatesProvider)[tabId]?.parentId;

    final liveTabIds = ref.read(tabListProvider).value.toSet();
    final visited = <String>{tabId};

    while (candidate != null && visited.add(candidate)) {
      if (!excludedTabIds.contains(candidate) &&
          liveTabIds.contains(candidate)) {
        return candidate;
      }

      // Closing an ancestor together with this tab (or an engine tab that never
      // materialised) is not the end of the chain — keep climbing.
      final ancestor = await tabDao.getTabDataById(candidate).getSingleOrNull();

      if (!ref.mounted) return null;

      candidate = ancestor?.parentId;
    }

    return null;
  }

  /// Whether closing [tabId] hands the user back to its opener, which may live
  /// in another container (see [_nearestAvailableAncestor]).
  Future<bool> hasOpenAncestor(String tabId) async {
    return await _nearestAvailableAncestor(tabId, excludedTabIds: const {}) !=
        null;
  }

  Future<void> _selectNextTab(
    String tabId, {
    Set<String> excludedTabIds = const {},
  }) async {
    final tabState = ref.read(tabStatesProvider)[tabId];

    final currentContainerId = await ref
        .read(tabDataRepositoryProvider.notifier)
        .getTabContainerId(tabId);

    if (!ref.mounted) return;

    final sameContainerTabs = await ref
        .read(containerRepositoryProvider.notifier)
        .getContainerTabIds(currentContainerId)
        .then(
          (tabs) => tabs
              .where((tab) => tab != tabId && !excludedTabIds.contains(tab))
              .toList(),
        );

    if (!ref.mounted) return;

    // Priority 0: the other page of a split pair, which is on screen already.
    final splitPartner = splitPartnerAfterClose(
      pair: ref.read(splitPairShownProvider),
      closedTabId: tabId,
      excludedTabIds: excludedTabIds,
      openTabIds: ref.read(tabListProvider).value,
    );
    if (splitPartner != null) {
      return await _selectTabAfterClose(splitPartner);
    }

    // Priority 1: hand the user back to whoever opened this tab, across
    // containers if that is where the opener lives.
    final ancestorTabId = await _nearestAvailableAncestor(
      tabId,
      excludedTabIds: excludedTabIds,
    );

    if (!ref.mounted) return;

    if (ancestorTabId != null) {
      return await _selectTabAfterClose(ancestorTabId);
    }

    // Priority 2: Check for previous tab by timestamp
    final previousTabId = await ref
        .read(tabDatabaseProvider)
        .definitionsDrift
        .previousTabByTimestamp(tabId: tabId)
        .getSingleOrNull();

    if (previousTabId != null) {
      if (sameContainerTabs.any((tab) => tab == previousTabId)) {
        return await _selectTabAfterClose(previousTabId);
      }
    }

    if (!ref.mounted) return;

    final orderedNeighborTabId = await _nearestAvailableVisibleTabByOrder(
      tabId,
      containerId: currentContainerId,
      excludedTabIds: excludedTabIds,
    );

    if (orderedNeighborTabId != null) {
      return await _selectTabAfterClose(orderedNeighborTabId);
    }

    if (!ref.mounted) return;

    // Out of candidates in this container. By default the search widens to
    // unassigned tabs and then to other containers, which drags the user out
    // of the container they were working in; the home target keeps them here.
    if (ref
        .read(generalSettingsWithDefaultsProvider)
        .homeTargetOnLastTabClosed) {
      await ref
          .read(homeTargetControllerProvider.notifier)
          .applyTarget(
            // currentContainerId is null for the unassigned container, which is
            // still a scope to stay inside — hence the explicit flag.
            scopeToContainer: true,
            containerId: currentContainerId,
            closingTabUrl: tabState?.url,
            // Tab rows outlive this call — they are deleted only after the next
            // selection is made — so without this the resume would pick the
            // very tab being closed, which sorts first as the active one.
            excludedTabIds: {...excludedTabIds, tabId},
          );
      return;
    }

    final unassignedTabs = await ref
        .read(containerRepositoryProvider.notifier)
        .getContainerTabIds(null)
        .then(
          (tabs) => tabs
              .where((tab) => tab != tabId && !excludedTabIds.contains(tab))
              .toList(),
        );

    if (unassignedTabs.isNotEmpty) {
      return await _selectTabAfterClose(unassignedTabs.first);
    }

    if (!ref.mounted) return;

    final availableContainers = await ref
        .read(containerRepositoryProvider.notifier)
        .getAllContainersWithCount();

    final nextAvailableContainer = availableContainers.firstOrNull;

    if (!ref.mounted) return;

    final nextContainerTabs = await nextAvailableContainer.mapNotNull(
      (container) => ref
          .read(containerRepositoryProvider.notifier)
          .getContainerTabIds(container.id)
          .then(
            (tabs) => tabs
                .where((tab) => tab != tabId && !excludedTabIds.contains(tab))
                .toList(),
          ),
    );

    if (nextContainerTabs.isNotEmpty) {
      return await _selectTabAfterClose(nextContainerTabs!.first);
    }
  }

  Future<void> _closeTabsInternal(
    List<String> tabIds, {
    required bool recordTombstones,
    bool keepOffRecentlyClosed = false,
  }) {
    return _closeLock.synchronized(() async {
      if (tabIds.isEmpty) {
        return;
      }

      if (keepOffRecentlyClosed) {
        await _recentlyClosedService.keepOff(tabIds);
      }

      if (recordTombstones) {
        await ref
            .read(tabDatabaseProvider)
            .tabDao
            .addClosedTabTombstones(tabIds);
      }

      for (final tabId in tabIds) {
        _tabBackBehavior.remove(tabId);
        final isolationContextId = ref
            .read(tabStatesProvider)[tabId]
            ?.isolationContextId;
        if (isolationContextId != null) {
          _pendingIsolationCleanup.add(isolationContextId);
        }
      }

      // Native's selection, not selectedTabProvider: its events are
      // debounced, so a tab selected a moment ago (a replacement taking over
      // a closing tab's selection, say) may not be in it yet, and the old
      // selection would pick a next tab over it.
      final selectedTab = await _tabsService.getSelectedTabId();
      if (!ref.mounted) return;
      if (selectedTab.mapNotNull(tabIds.contains) ?? false) {
        await _selectNextTab(selectedTab!, excludedTabIds: tabIds.toSet());
      }

      await _preservePromotedChildOrderOnClose(tabIds);

      if (tabIds.length == 1) {
        await _tabsService.removeTab(tabId: tabIds.single);
      } else {
        await _tabsService.removeTabs(ids: tabIds);
      }
    });
  }

  /// With [keepOffRecentlyClosed], for a close the user did not ask for (the
  /// tab is recreated elsewhere, its container is deleted), the tab never goes
  /// on the recently closed list.
  Future<void> closeTab(String tabId, {bool keepOffRecentlyClosed = false}) {
    return _closeTabsInternal(
      [tabId],
      recordTombstones: true,
      keepOffRecentlyClosed: keepOffRecentlyClosed,
    );
  }

  /// [keepOffRecentlyClosed] as for [closeTab].
  Future<void> closeTabs(
    List<String> tabIds, {
    bool keepOffRecentlyClosed = false,
  }) {
    return _closeTabsInternal(
      tabIds,
      recordTombstones: true,
      keepOffRecentlyClosed: keepOffRecentlyClosed,
    );
  }

  Future<void> _clearTombstonesForCurrentTabs(List<String> tabIds) {
    return ref
        .read(tabDatabaseProvider)
        .tabDao
        .deleteClosedTabTombstones(tabIds);
  }

  Future<void> _preservePromotedChildOrderOnClose(List<String> tabIds) {
    return ref
        .read(tabDatabaseProvider)
        .tabDao
        .preservePromotedChildOrderOnClose(tabIds);
  }

  /// Clears Gecko browsing data and removes proxy alias for an isolation
  /// context if no more tabs share it.
  Future<void> _cleanupIsolationContextIfEmpty(String contextId) async {
    final tabDao = ref.read(tabDatabaseProvider).tabDao;

    // Re-verify count after close (handles concurrent close races)
    final remaining = await tabDao.tabsInIsolationGroup(contextId).getSingle();

    if (remaining > 0) return;

    // Guard against debounced DB persistence: a sibling tab can already be
    // active in-memory for this context before isolation_context_id is written.
    final activeTabs = ref.read(tabListProvider).value;
    final activeStates = ref.read(tabStatesProvider);
    final hasActiveSibling = activeTabs.any((tabId) {
      final state = activeStates[tabId];
      if (state == null) return false;

      return state.isolationContextId == contextId ||
          state.contextId == contextId;
    });

    if (hasActiveSibling) {
      logger.i(
        'Skipping isolation cleanup for active context still in memory: $contextId',
      );
      return;
    }

    logger.i('Cleaning up isolation context: $contextId');

    // Clear Gecko browsing data for this context
    try {
      await ref
          .read(browserDataServiceProvider.notifier)
          .clearDataForContext(contextId);
    } catch (e, st) {
      logger.e(
        'Failed to clear data for isolation context $contextId',
        error: e,
        stackTrace: st,
      );
    }

    // The alias derived from the group's container needs no teardown: it is
    // computed from the tabs that reference the context, so dropping those tabs
    // removes it from the next routing snapshot. A route the *user* set on the
    // group is stored, though, and would outlive every tab that could use it.
    if (!ref.mounted) return;

    try {
      await ref
          .read(proxyRoutingSettingsRepositoryProvider.notifier)
          .clearIsolationContextRoute(contextId);
    } catch (e, st) {
      logger.e(
        'Failed to drop the isolation route for $contextId',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Re-attaches restored tabs the database lists under no container although
  /// the engine runs them in one — see
  /// [TabDao.reattachTabsToContextContainers] for how they got that way.
  ///
  /// Checked on every start rather than once, so any later disagreement of the
  /// same kind heals the same way. Failures are logged and left: a tab listed
  /// under the wrong container is a display fault, not a reason to fail a
  /// restore.
  Future<void> _reattachTabsToContextContainers() async {
    final engineContextIds = {
      for (final MapEntry(key: tabId, value: tabState)
          in ref.read(tabStatesProvider).entries)
        if (tabState.hasContentState &&
            tabState.tabMode is RegularTabMode &&
            tabState.contextId != null &&
            tabState.contextId!.isNotEmpty)
          tabId: tabState.contextId!,
    };

    try {
      final reattached = await ref
          .read(tabDatabaseProvider)
          .tabDao
          .reattachTabsToContextContainers(engineContextIds);
      if (reattached.isNotEmpty) {
        logger.w(
          'Re-attached ${reattached.length} tabs to the container they run '
          'in: $reattached',
        );
      }
    } catch (error, stackTrace) {
      logger.e(
        'Could not re-attach tabs to their containers',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _drainPendingIsolationCleanup() async {
    if (_pendingIsolationCleanup.isEmpty) return;

    final pending = Set<String>.of(_pendingIsolationCleanup);
    _pendingIsolationCleanup.clear();

    for (final contextId in pending) {
      if (!ref.mounted) break;
      await _cleanupIsolationContextIfEmpty(contextId);
    }
  }

  /// Reopens the tabs closed last, while the engine can still undo that
  /// close. Returns whether anything was reopened.
  Future<bool> undoClose() async {
    // Suppress the next reclose pass: undo can resurrect a tab whose
    // tombstone is still on disk (from a previous session); without this
    // flag the listener would immediately re-close it.
    //
    // Armed before the call, so the restored list cannot arrive first, and
    // disarmed when nothing is restored. The undo history is short-lived and
    // often empty, and then no tab list change ever comes to consume the flag.
    // Left armed, it would take the next unrelated change for an undo -- at
    // startup, the session restore itself -- skip the reclose pass and delete
    // the tombstones of tabs the user had closed, bringing them back for good.
    _suppressNextReclose = true;
    var restoresTabs = false;
    try {
      restoresTabs = await _tabsService.undo();
    } finally {
      if (!restoresTabs) _suppressNextReclose = false;
    }
    // A replaced tab can be among those it brought back.
    if (restoresTabs) _replacements.undone();
    return restoresTabs;
  }

  /// Reopens [tab] from the recently closed list with its back history, in the
  /// container it was closed in. Returns its id, or null when the engine no
  /// longer has it.
  ///
  /// When that container has been deleted since, the page opens afresh
  /// outside it: the container's cookies and routing went with it.
  Future<String?> restoreClosedTab(
    RecentlyClosedTab tab, {
    required bool selectTab,
  }) async {
    // As for addTab: the startup cleanup would delete the tab's site data.
    await ref.read(startupBrowsingDataCleanupProvider.notifier).waitUntilDone();

    final tabDao = ref.read(tabDatabaseProvider).tabDao;
    final containerId = (await tabDao.closedTabContainers([
      tab.id,
    ]))[tab.id]?.containerId;
    final container = await containerId.mapNotNull(
      (id) =>
          ref.read(containerRepositoryProvider.notifier).getContainerData(id),
    );

    if (containerId != null && container == null) {
      await _recentlyClosedService.remove(tab.id);
      await tabDao.deleteClosedTabContainers([tab.id]);

      return await addTab(
        url: Uri.tryParse(tab.url),
        tabMode: TabMode.regular,
        selectTab: selectTab,
        containerSelection: const TabContainerSelection.unassigned(),
      );
    }

    // Its close left a tombstone, which would have the tab list listener close
    // it again as a stale restore.
    await tabDao.deleteClosedTabTombstones([tab.id]);

    final String restoredId;
    try {
      restoredId = await tabDao.upsertTabTransactional(
        () async =>
            await _recentlyClosedService.restore(
              tab.id,
              contextId: container?.metadata.contextualIdentity,
              selectTab: selectTab,
              excludeFromHistory:
                  container?.metadata.excludeFromHistory ?? false,
            ) ??
            (throw const _NoLongerClosed()),
        parentId: const Value(null),
        containerId: Value(container?.id),
        url: Value(Uri.tryParse(tab.url)),
        title: Value(tab.title),
        tabMode: const Value(TabMode.regular),
        childPlacement: ref
            .read(generalSettingsWithDefaultsProvider)
            .childTabPlacement,
      );
    } on _NoLongerClosed {
      return null;
    }

    await tabDao.deleteClosedTabContainers([restoredId]);

    if (selectTab && ref.mounted) {
      _clearForceBrowserHome();

      await ref
          .read(selectedContainerProvider.notifier)
          .followTab(container?.id);
    }

    return restoredId;
  }

  Future<bool> _recloseRestoredClosedTabs(List<String> tabIds) async {
    if (_reclosing) {
      return false;
    }
    _reclosing = true;
    try {
      final tabDao = ref.read(tabDatabaseProvider).tabDao;

      if (!_didPruneTombstones) {
        await tabDao.pruneExpiredClosedTabTombstones();
        _didPruneTombstones = true;
      }

      final restoredClosedTabIds = await tabDao.getStartupRestoredClosedTabIds(
        tabIds,
        sessionStartedAt: _sessionStartedAt,
      );

      if (restoredClosedTabIds.isEmpty) {
        return false;
      }

      // recordTombstones: false — the tombstone already exists from the
      // original close; rewriting it would bump closed_at into this session
      // and disable the resurrection check on the next emission.
      await _closeTabsInternal(
        restoredClosedTabIds.toList(growable: false),
        recordTombstones: false,
      );

      return true;
    } finally {
      _reclosing = false;
    }
  }

  /// Cleans up isolation contexts from previous crashed sessions.
  /// Called once after tab list stabilizes on startup.
  // Future<void> _cleanupOrphanedIsolationContexts() async {
  //   final tabDao = ref.read(tabDatabaseProvider).tabDao;

  //   try {
  //     await _closeLock.synchronized(() async {
  //       if (!ref.mounted) return;

  //       // Reconcile DB rows against the current engine tab snapshot, including
  //       // valid empty-tab sessions (retainTabIds can be empty here).
  //       final syncTabsResult = await tabDao.syncTabs(
  //         retainTabIds: ref.read(tabListProvider).value,
  //       );
  //       _pendingIsolationCleanup.addAll(
  //         syncTabsResult.deletedIsolationContextIds,
  //       );

  //       if (_pendingIsolationCleanup.isNotEmpty) {
  //         final pending = Set<String>.of(_pendingIsolationCleanup);
  //         _pendingIsolationCleanup.clear();

  //         for (final contextId in pending) {
  //           if (!ref.mounted) return;
  //           logger.i('Cleaning orphaned isolation context: $contextId');
  //           await _cleanupIsolationContextIfEmpty(contextId);
  //         }
  //       }
  //     });
  //   } catch (e, st) {
  //     logger.e(
  //       'Error during orphan isolation context cleanup',
  //       error: e,
  //       stackTrace: st,
  //     );
  //   }
  // }

  /// Shows background tab [sourceTabId]'s cancelled navigation to [uri] in
  /// its page's stand-in ([BackgroundStandIns]), opening one with [open] when
  /// there is none. [selectedTabId] is the native store's selection, asked
  /// for just before.
  Future<void> _showInStandIn(
    String sourceTabId,
    Uri uri,
    String? selectedTabId,
    Future<String> Function([Uri? url]) open,
  ) async {
    // Which tabs are open, from the native store right now; see
    // [BackgroundStandIns.sync].
    final takenAt = _backgroundStandIns.stamp;
    final openTabIds = await _tabsService.getTabIds();
    if (!ref.mounted) return;
    _backgroundStandIns.sync(
      openTabIds: openTabIds,
      selectedTabId: selectedTabId,
      // A split pair shown with the selected tab shows its other page too,
      // never selected. The pair is Dart's own state, so current already.
      visibleTabIds: [
        if (selectedTabId != null)
          ?ref.read(splitPairShownProvider)?.partnerOf(selectedTabId),
      ],
      takenAt: takenAt,
    );

    switch (_backgroundStandIns.request(sourceTabId, uri)) {
      case StandInCurrent():
        return;
      case LoadInStandIn(:final tabId):
        // Nobody has seen either tab: the page's latest navigation replaces
        // the stand-in's, as it would have in the tab itself.
        await GeckoSessionService(tabId: tabId).loadUrl(url: uri);
        return;
      case OpenStandIn():
        break;
    }

    final String standInId;
    try {
      standInId = await open(uri);
    } catch (_) {
      _backgroundStandIns.release(sourceTabId, uri);
      rethrow;
    }

    // A newer navigation to the page came in while the stand-in opened: it
    // loads there, never in another tab ([BackgroundStandIns.opened]). Sent
    // with no await before it, so a load for a navigation reported from now
    // on reaches the tab after this one.
    final newer = _backgroundStandIns.opened(sourceTabId, uri, standInId);
    if (newer != null) {
      await GeckoSessionService(tabId: standInId).loadUrl(url: newer);
    }
  }

  /// Reopens a navigation the container extension cancelled, in the container
  /// the site is assigned to.
  ///
  /// The extension cancels the request natively and reports it here, for a
  /// background tab too. Nothing else retries it, so a report this drops
  /// leaves the tab sitting on a navigation that will never happen.
  Future<void> _handleSiteAssignment(ContainerSiteAssignment event) async {
    // Strict-mode blocks have no destination container to re-open into; the
    // navigation was already cancelled natively and the user is notified via
    // a snackbar (see the strict-block listener in the app shell). Nothing
    // to reconcile here.
    if (event.strict) {
      return;
    }

    final tabId = event.tabId;
    if (tabId == null) {
      logger.w(
        'Site assignment for ${event.url} names no tab; nothing to reopen',
      );
      return;
    }

    _latestAssignmentRequests[tabId] = event.requestId;
    bool isCurrentRequest() =>
        ref.mounted && _latestAssignmentRequests[tabId] == event.requestId;

    try {
      // Not `ref.read(tabStatesProvider)[tabId]`: this event reaches Dart the
      // moment the extension answers, which for a tab opened by the very
      // navigation being cancelled is before the tab itself does.
      final tabState = await ref
          .read(tabStatesProvider.notifier)
          .awaitContentState(tabId);

      if (!isCurrentRequest()) {
        return;
      }

      if (tabState == null) {
        logger.w(
          'Gave up waiting for tab $tabId to reopen ${event.url} in its '
          'assigned container',
        );
        return;
      }

      final uri = Uri.parse(event.url);
      final originUri = event.originUrl.mapNotNull(Uri.parse);

      final targetContainerId = await ref
          .read(containerRepositoryProvider.notifier)
          .siteAssignedContainerId(Uri.parse(uri.origin));

      if (!isCurrentRequest()) {
        return;
      }

      final containerData = await targetContainerId.mapNotNull(
        (id) =>
            ref.read(containerRepositoryProvider.notifier).getContainerData(id),
      );

      if (!isCurrentRequest() || containerData == null) {
        return;
      }

      final currentTabState = ref.read(tabStatesProvider)[tabId];
      if (currentTabState == null) {
        logger.w(
          'Tab $tabId disappeared before ${event.url} could be reopened',
        );
        return;
      }

      // The tab is already in the target container, so there is nothing
      // to reconcile. This notably fires when reassigning a tab into a
      // container that shares the default Gecko context: assignContainer
      // recreates the tab in the target container, and that new tab's
      // load re-triggers this event. Without this guard the transiently
      // empty new tab would be treated as an empty tab and churn yet
      // another tab (re-prompting app-links).
      final currentTabContainerId = await ref
          .read(tabDataRepositoryProvider.notifier)
          .getTabContainerId(currentTabState.id);
      if (!isCurrentRequest() || currentTabContainerId == targetContainerId) {
        return;
      }

      final historyIsEmpty =
          ref
              .read(tabHistoryStatesProvider)[currentTabState.id]
              ?.items
              .isEmpty ??
          true;

      final tabIsEmpty =
          currentTabState.url == TabState.defaultUrl && historyIsEmpty;

      if (event.blocked || tabIsEmpty) {
        final splitView = ref.read(splitViewControllerProvider.notifier);
        // A background tab (a link opened with "Open in new tab", say) or the
        // unfocused page of a split pair, which is never the selected tab,
        // does not take focus by itself: its replacement (or the tab it opens)
        // stays in the background too. Native's selection, not
        // selectedTabProvider (nor isUnfocusedMember, which reads it): the
        // selection events are debounced, so a tab selected a moment ago may
        // not be in it yet.
        final selectedTabId = await _tabsService.getSelectedTabId();
        if (!isCurrentRequest()) return;
        final staysUnfocused = selectedTabId != currentTabState.id;

        Future<String> openInAssignedContainer([Uri? url]) => addTab(
          url: url ?? uri,
          tabMode: currentTabState.tabMode,
          containerSelection: TabContainerSelection.specific(containerData),
          parentId: currentTabState.id,
          selectTab: !staysUnfocused,
        );

        if (historyIsEmpty) {
          // A replacement: the new tab takes the old one's place, in a split
          // pair too.
          await splitView.carryOver(
            currentTabState.id,
            () => replaceTabOpeningFirst(
              oldTabId: currentTabState.id,
              focused: !staysUnfocused,
              open: openInAssignedContainer,
              selectedTabId: _tabsService.getSelectedTabId,
              closeOld: (newTabId) =>
                  _closeReplacedTab(currentTabState.id, newTabId),
              select: selectTab,
              isMounted: () => ref.mounted,
            ),
          );
        } else if (!staysUnfocused) {
          await openInAssignedContainer();
        } else {
          await _showInStandIn(
            currentTabState.id,
            uri,
            selectedTabId,
            openInAssignedContainer,
          );
        }
      } else {
        final latestTabState = ref.read(tabStatesProvider)[tabId];
        if (latestTabState == null) {
          logger.w(
            'Tab $tabId disappeared before ${event.url} could be reassigned',
          );
          return;
        }

        if (originUri == null) {
          await ref
              .read(tabDataRepositoryProvider.notifier)
              .assignContainer(
                latestTabState.id,
                containerData,
                replacementUrl: uri,
              );
        } else if (latestTabState.url == originUri) {
          await ref
              .read(tabDataRepositoryProvider.notifier)
              .assignContainer(
                latestTabState.id,
                containerData,
                closeOldTab: false,
                replacementUrl: uri,
              );
        } else {
          logger.w(
            'Could not match origin url for assignment ${latestTabState.url} to request ${event.originUrl}',
          );
        }
      }
    } catch (error, stackTrace) {
      // The stream's `onError` never sees what an async listener throws.
      logger.e(
        'Failed to reopen ${event.url} in its assigned container',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      if (_latestAssignmentRequests[tabId] == event.requestId) {
        _latestAssignmentRequests.remove(tabId);
      }
    }
  }

  @override
  void build() {
    // Hold an active listener on the rendered navigation order: swipes and
    // gestures read it synchronously, and Riverpod pauses a provider nothing is
    // listening to — a one-off read would neither keep it current nor guarantee
    // it has data when the first swipe arrives. Listened rather than watched
    // because it changes with every tab update, which must not rebuild this
    // repository; the callback is intentionally empty.
    ref.listen(
      sequentialTabNavigationOrderProvider,
      (_, _) {},
      fireImmediately: true,
    );

    final eventSerivce = ref.watch(eventServiceProvider);
    final tabContentService = ref.watch(tabContentServiceProvider);

    final db = ref.watch(tabDatabaseProvider);

    final tabAddedSub = eventSerivce.tabAddedStream.listen(
      (event) async {
        // A tab opened from another tab runs in its opener's context, so
        // `insertTab` files it with the opener rather than with whatever
        // container is selected. A tab without an opener (an extension's
        // `tabs.create`) still lands in the selected container.
        final containerId = event.parentId == null
            ? Value(ref.read(selectedContainerProvider))
            : const Value<String?>.absent();
        await db.tabDao.insertTab(
          event.tabId,
          parentId: const Value.absent(),
          // Link an engine-opened tab to its opener and place it per the child
          // tab placement setting right away, so it never has to move once the
          // parent is seeded from engine state. An app-created tab already has
          // its row (manual source wins the upsert), so this is a no-op for it.
          openerId: Value(event.parentId),
          childPlacement: ref
              .read(generalSettingsWithDefaultsProvider)
              .childTabPlacement,
          source: TabSource.addedEvent,
          containerId: containerId,
        );
      },
      onError: (Object error, StackTrace stackTrace) {
        logger.e(
          'Error in tab added stream',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    final containerSiteAssignementSub = eventSerivce.siteAssignementEvent
        .listen(
          (event) async {
            await _handleSiteAssignment(event);
          },
          onError: (Object error, StackTrace stackTrace) {
            logger.e(
              'Error in container site assignment stream',
              error: error,
              stackTrace: stackTrace,
            );
          },
        );

    final tabContentSub = tabContentService.tabContentStream.listen(
      (content) async {
        await db.tabDao.updateTabContent(
          content.tabId,
          isProbablyReaderable: content.isProbablyReaderable,
          extractedContentMarkdown: content.extractedContentMarkdown,
          extractedContentPlain: content.extractedContentPlain,
          fullContentMarkdown: content.fullContentMarkdown,
          fullContentPlain: content.fullContentPlain,
        );
      },
      onError: (Object error, StackTrace stackTrace) {
        logger.e(
          'Error in tab content stream',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    followVisiblePair();

    ref.listen(
      fireImmediately: true,
      selectedTabProvider,
      (previous, tabId) async {
        _onVisiblePairChange();
        if (tabId != null) {
          // Seen now: what it tries next in the background is new again.
          _backgroundStandIns.forget(tabId);
          await db.tabDao.touchTab(tabId, timestamp: DateTime.now());
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        logger.e(
          'Error listening to selectedTabProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.listen(
      tabListProvider,
      (previous, next) async {
        if (_suppressNextReclose) {
          _suppressNextReclose = false;
          // Drop tombstones for the tabs that just came back via undo so
          // future emissions don't treat them as resurrections.
          await _clearTombstonesForCurrentTabs(next.value);
        } else if (await _recloseRestoredClosedTabs(next.value)) {
          return;
        } else if (await _closeRestoredPrivateCaptureTabs(next.value)) {
          return;
        }

        //Only sync tabs if there has been a previous value or is not empty.
        //Additionally require the native session restore to have completed:
        //a partial pre-restore list (e.g. a share-intent tab arriving first)
        //must not delete the cached rows of tabs that are still being
        //restored.
        final shouldSyncTabs =
            ref.read(browserRestoreCompleteProvider) &&
            (next.value.isNotEmpty || (previous?.value.isNotEmpty ?? false));

        if (shouldSyncTabs) {
          final syncTabsResult = await db.tabDao.syncTabs(
            retainTabIds: next.value,
            childPlacement: ref
                .read(generalSettingsWithDefaultsProvider)
                .childTabPlacement,
          );
          // Capture isolation contexts from rows deleted by syncTabs
          // (orphaned tabs from crashes, or tabs the engine dropped).
          _pendingIsolationCleanup.addAll(
            syncTabsResult.deletedIsolationContextIds,
          );
        }

        // Process pending isolation context cleanups after syncTabs
        // has deleted the rows, so the count check is accurate.
        await _drainPendingIsolationCleanup();

        // One-shot orphan cleanup after tab list stabilizes (5s debounce).
        // Also runs for DB-only contexts whose rows were already deleted
        // by syncTabs above (those are handled via _pendingIsolationCleanup).
        // if (!orphanCleanupDone) {
        //   orphanCleanupTimer?.cancel();
        //   orphanCleanupTimer = Timer(const Duration(seconds: 5), () async {
        //     if (orphanCleanupDone || !ref.mounted) return;
        //     orphanCleanupDone = true;
        //     await _cleanupOrphanedIsolationContexts();
        //   });
        // }
      },
      onError: (Object error, StackTrace stackTrace) {
        logger.e(
          'Error listening to tabListProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    // Catch up on the tab list emissions skipped while the restore-complete
    // gate above was closed: reconcile the DB once against the current list.
    //
    // Fired immediately: this repository is built when the browser view
    // mounts, after the engine was initialized, and restoring an empty session
    // finishes almost at once — the flag is often already true here, and a
    // transition this listener never sees would leave every cached row of a
    // session that came back empty (a Quit that deleted all tabs) in place.
    ref.listen(fireImmediately: true, browserRestoreCompleteProvider, (
      previous,
      restoreComplete,
    ) async {
      if (restoreComplete && !(previous ?? false)) {
        final currentTabs = ref.read(tabListProvider).value;
        final childPlacement = ref
            .read(generalSettingsWithDefaultsProvider)
            .childTabPlacement;

        final SyncTabsResult syncTabsResult;
        try {
          syncTabsResult = currentTabs.isNotEmpty
              ? await db.tabDao.syncTabs(
                  retainTabIds: currentTabs,
                  childPlacement: childPlacement,
                )
              // The tab list event is debounced and can still be on its way
              // with the restored tabs, so an empty list here is not trusted
              // on its own: reconciling against it would delete their rows.
              // The native store decides instead — empty there is real (a
              // Quit that deleted every tab, say) and the cached rows are
              // stale. Read inside the reconciling transaction, so a tab being
              // created right now cannot be missed; see syncTabsToSnapshot.
              : await db.tabDao.syncTabsToSnapshot(
                  GeckoTabService().getTabIds,
                  childPlacement: childPlacement,
                );
        } catch (e, st) {
          logger.e(
            'Could not reconcile the cached tabs after the restore',
            error: e,
            stackTrace: st,
          );
          return;
        }

        _pendingIsolationCleanup.addAll(
          syncTabsResult.deletedIsolationContextIds,
        );
        await _drainPendingIsolationCleanup();

        await _reattachTabsToContextContainers();
      }
    });

    final tabStateDebouncer = Debouncer(const Duration(seconds: 1));
    Map<String, TabState>? debounceStartValue;

    ref.listen(
      tabStatesProvider,
      (previous, next) {
        //Since state changes occure pretty often and our map always contains
        //the latest state, we cache the value before starting debouncing and
        //later diff to that, to avoid frequent database writes
        if (!tabStateDebouncer.isDebouncing) {
          debounceStartValue = previous;
        }

        tabStateDebouncer.eventOccured(() async {
          await db.tabDao.updateTabs(
            debounceStartValue,
            next,
            childPlacement: ref
                .read(generalSettingsWithDefaultsProvider)
                .childTabPlacement,
          );
        });
      },
      onError: (Object error, StackTrace stackTrace) {
        logger.e(
          'Error listening to tabStatesProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.onDispose(() async {
      tabStateDebouncer.dispose();
      await tabAddedSub.cancel();
      await tabContentSub.cancel();
      await containerSiteAssignementSub.cancel();
    });
  }
}

/// The tab to reopen was taken off the recently closed list meanwhile.
class _NoLongerClosed implements Exception {
  const _NoLongerClosed();
}

/// The routing check for the split partner a selection brings on screen,
/// running alongside the selected tab's own.
class _SplitPartnerRoutingCheck {
  _SplitPartnerRoutingCheck({
    required this.pairId,
    required Future<bool> routingReady,
  }) {
    result = routingReady.then((ready) => _ready = ready);
  }

  /// The pair the partner belongs to.
  final String pairId;

  /// Completes with whether the partner's routing is installed.
  late final Future<bool> result;

  bool? _ready;

  /// Whether [result] has already found the partner's routing installed;
  /// false while the check is still running.
  bool get isReadyNow => _ready == true;
}
