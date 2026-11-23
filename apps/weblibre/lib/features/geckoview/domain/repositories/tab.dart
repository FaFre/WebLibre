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
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:nullability/nullability.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:synchronized/synchronized.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/providers/pending_writes.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/extensions/uri.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_close_result.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_container_selection.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_lock.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_wake.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/providers/pending_tab_selection.dart';
import 'package:weblibre/features/geckoview/domain/providers/restore_complete.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_detail_state.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_list.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab/background_stand_ins.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab/isolation_context_cleanup.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab/tab_close_lock.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab/tab_locks.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/controllers/home_target_controller.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
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
import 'package:weblibre/features/geckoview/features/tabs/domain/entities/container_freeze.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/container_freeze.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/services/container_freeze.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/services/container_membership_gate.dart';
import 'package:weblibre/features/proxy/domain/repositories/container_proxy.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/proxy_routing_settings.dart';
import 'package:weblibre/utils/debouncer.dart';

part 'tab.g.dart';
part 'tab.replacements.dart';

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

  /// Each undo close still waiting for the rows of the tabs it brought back,
  /// with the completer that says they are written; see [undoClose].
  final _undoRows = <({Set<String> tabIds, Completer<void> landed})>[];

  final _tabBackBehavior = <String, TabBackBehavior>{};

  /// Held by every close and every lock change; see [tabCloseLockProvider].
  Lock get _closeLock => ref.read(tabCloseLockProvider);

  /// Isolation contexts whose tabs are gone, cleaned up after each tab list
  /// sync; see [IsolationContextCleanup].
  IsolationContextCleanup get _isolationCleanup =>
      ref.read(isolationContextCleanupProvider.notifier);

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

  /// Runs [_showInStandIn] one report at a time.
  final _standInLock = Lock();

  /// Tabs closed because another took their place; see [TabReplacements].
  final _replacements = TabReplacements();

  /// The tab lock protocol; every use is under [_closeLock].
  TabLocks get _locks => ref.read(tabLocksProvider.notifier);

  GeckoTabLifecycleService get _tabLifecycle =>
      ref.read(geckoTabLifecycleServiceProvider);

  /// Closes [oldTabId], then opens the tab that takes its place with
  /// [openReplacement] and records the replacement ([TabReplacements]). A
  /// selection of [oldTabId] from then on selects the new tab while
  /// [oldTabId] stays closed: the "tab opened" prompt of a link opened in the
  /// background still holds the tab that a container change replaced.
  ///
  /// The close decides, not a check before it: a lock can arrive after any
  /// such check, and the close is where locks are read under the close lock.
  /// When [oldTabId] survives it, locked or with the locks unreadable,
  /// nothing is opened or recorded ([OriginalKept]).
  Future<ReplacementResult> replaceTabClosingFirst(
    String oldTabId,
    Future<String> Function() openReplacement,
  ) async {
    // The replacement stands in for it, so it was never closed.
    final closed = await closeTab(oldTabId, keepOffRecentlyClosed: true);
    if (!closed.isGone(oldTabId)) {
      return OriginalKept(locksUnavailable: closed.locksUnavailable);
    }
    // Read now: an undo while the replacement opens may restore it.
    final closedAt = _replacements.undoGeneration;
    final newTabId = await openReplacement();
    if (ref.mounted) {
      _replacements.record(oldTabId, newTabId, closedAt: closedAt);
    }
    return TabReplaced(newTabId);
  }

  /// Closes [oldTabId], which [newTabId] took the place of, and records the
  /// replacement before the close: a selection while it is under way (a
  /// close waits for any other in progress) already reaches [newTabId].
  ///
  /// Returns whether [oldTabId] went. A locked one stays, as does one whose
  /// lock could not be read, and the record is dropped: the new tab is then
  /// just a tab beside it.
  Future<bool> _closeReplacedTab(String oldTabId, String newTabId) async {
    _replacements.recordClosing(oldTabId, newTabId);
    final CloseResult closed;
    try {
      // The replacement stands in for it, so it was never closed.
      closed = await closeTab(oldTabId, keepOffRecentlyClosed: true);
    } catch (_) {
      _replacements.drop(oldTabId);
      rethrow;
    }
    if (!closed.isGone(oldTabId)) {
      _replacements.drop(oldTabId);
      return false;
    }
    _replacements.closed(oldTabId);
    return true;
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

    // Held until the row is written: a container being deleted takes no new
    // tab, and a deletion does not start while one joins (see
    // [ContainerMembershipGate]). Not redirected elsewhere, which would
    // change how the page is routed. An isolated tab would bring a context of
    // its own into the container, which a freeze does not cover (D19).
    final gate = ref.read(containerMembershipGateProvider.notifier);
    return await gate.whileChanging(
      [assignedContainer?.id],
      kind: await _changeKind(
        assignedContainer?.id,
        [if (tabMode is IsolatedTabMode) tabMode.isolationContextId],
        carriesRequestState:
            (additionalHeaders?.isNotEmpty ?? false) ||
            flags != LoadUrlFlags.NONE,
      ),
      () async {
        final container = await _stillExisting(assignedContainer);
        final validatedParentId = await _resolveParentId(parentId);

        final effectiveIsolationContextId = tabMode.isolationContextId;

        final effectiveContextId = tabMode is IsolatedTabMode
            ? effectiveIsolationContextId
            : container?.metadata.contextualIdentity;

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
              // Carried into the engine so the exclusion is in place before the
              // tab loads; the replicated snapshot only follows once its row is
              // written.
              excludeFromHistory:
                  container?.metadata.excludeFromHistory ?? false,
              parentIsReferrer: parentIsReferrer,
            );
            onCreated?.call(tabId);
            return tabId;
          },
          parentId: Value(validatedParentId),
          containerId: Value(container?.id),
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
              .followTab(container?.id);
        }

        return newTabId;
      },
    );
  }

  /// What adding tabs to [containerId] does to its membership, with
  /// [isolationContextIds] the contexts of the isolated ones among them. An
  /// isolated tab brings a context of its own into the container, which a
  /// freeze does not cover (D19), unless native already restricts that
  /// context for the container: a group whose last tab closed while it was
  /// frozen, reopened by an undo or a recreation.
  ///
  /// A request whose meaning depends on extra headers or load flags
  /// ([carriesRequestState]) is refused by a frozen container too: it takes
  /// a new tab held, with only its plain URL waiting for Resume (5.2.1).
  Future<ContainerChange> _changeKind(
    String? containerId,
    List<String> isolationContextIds, {
    bool carriesRequestState = false,
  }) async {
    if (containerId == null) return ContainerChange.addition;
    if (carriesRequestState) return ContainerChange.membership;
    if (isolationContextIds.isEmpty) return ContainerChange.addition;
    final gate = ref.read(containerMembershipGateProvider.notifier);
    await gate.seed();
    final owned = gate.contextsHolding(containerId).toSet();
    return owned.containsAll(isolationContextIds)
        ? ContainerChange.addition
        : ContainerChange.membership;
  }

  /// Whether isolated tabs in [isolationContextIds] may be added to
  /// [containerId] now ([_changeKind]): for a check before something that
  /// cannot be undone, such as closing the tabs a recreation reopens.
  Future<bool> mayAddIsolatedTabs(
    String containerId,
    List<String> isolationContextIds,
  ) async {
    if (await _changeKind(containerId, isolationContextIds) ==
        ContainerChange.addition) {
      return true;
    }
    return !ref
        .read(containerMembershipGateProvider.notifier)
        .isRestricted(containerId);
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

  /// [container] read again once the change reservation on it is held. A
  /// deletion that finished between the caller's lookup and the reservation
  /// leaves no row, and a tab must not land in it (nor take its identity as it
  /// was before an edit). Throws [ContainerBeingDeletedException] then, as for
  /// a deletion still running.
  Future<ContainerData?> _stillExisting(ContainerData? container) async {
    if (container == null) return null;
    return await ref
            .read(containerRepositoryProvider.notifier)
            .getContainerData(container.id) ??
        (throw ContainerBeingDeletedException(container.id));
  }

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
    // As for addTab.
    return await ref.read(containerMembershipGateProvider.notifier).whileChanging(
      [assignedContainer?.id],
      kind: await _changeKind(assignedContainer?.id, [
        for (final tab in tabs)
          if (isIsolatedContextId(tab.contextId)) tab.contextId!,
      ]),
      () async {
        final container = await _stillExisting(assignedContainer);
        // Read once for the whole batch rather than per tab: the setting cannot
        // change while these rows are being written.
        final childPlacement = ref
            .read(generalSettingsWithDefaultsProvider)
            .childTabPlacement;

        final createdTabIds = await db.transaction(() async {
          final createdTabIds = await _tabsService.addMultipleTabs(
            tabs: tabs,
            selectTabId: selectTabId,
            // Carried into the engine so the exclusion is in place before these
            // tabs load; the replicated snapshot only follows once their rows
            // are written. One value for the batch — they all land in this
            // container.
            excludeFromHistory: container?.metadata.excludeFromHistory ?? false,
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

            // Validate parent exists in either the batch being created or
            // database
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
              containerId: Value(container?.id),
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
      },
    );
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

    // As for addTab: a duplicate of an isolated tab brings a new isolation
    // context into the container.
    return await ref.read(containerMembershipGateProvider.notifier).whileChanging(
      [containerData?.id],
      kind: sourceTabMode is IsolatedTabMode
          ? ContainerChange.membership
          : ContainerChange.addition,
      () async {
        final container = await _stillExisting(containerData);

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
            : container?.metadata.contextualIdentity;

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
                  containerId: container?.id,
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
                  container?.metadata.excludeFromHistory ?? false,
            );
          },
          parentId: Value(sourceParentId),
          afterTabId: Value(anchorTabId),
          containerId: Value(container?.id),
          tabMode: Value(duplicateTabMode),
        );

        // The duplicate is a new isolation group, so it starts with no route of
        // its own — carry the source's over, or the copy silently falls back to
        // its container's routing.
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
      },
    );
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

    // A frozen container's tab shows its placeholder and loads nothing, so
    // its routing is not waited for (5.5).
    final frozen = ref
        .read(containerMembershipGateProvider.notifier)
        .isFrozen(containerData?.id);
    if (!ref.mounted ||
        (!frozen && !await _routingReadyFor(tabId, containerData)) ||
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

  /// Whether every one of [contextIds] may run, as far as proxy routing is
  /// concerned (D34): for a Resume, which has no single tab to check. As for
  /// a Wake, routing has to be installed whatever the contexts route through,
  /// and then the installed routing's verdict for each context decides, as a
  /// pane's does before it wakes a tab. That verdict resolves a context the
  /// way the extension does, so a container without a proxy of its own that
  /// inherits the global one, and an isolation group that follows its
  /// container or the global route, are checked by the route they actually
  /// take. Unavailable routing never falls back to direct: a proxy without an
  /// endpoint keeps them frozen.
  Future<bool> ensureRoutingReadyForContexts(
    Iterable<String> contextIds,
  ) async {
    final contexts = contextIds.toSet().toList();
    final routing = ref.read(containerProxyRepositoryProvider.notifier);
    final ready =
        await routing.waitUntilRoutingReady() &&
        await routing.routingCovers(contexts);
    if (!ready) {
      logger.w(
        'Contexts $contexts not resumed: routing is not installed or has no '
        'route out for one of them',
      );
    }
    return ready;
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
    //
    // Not while the container is being deleted: there is nothing to stay in,
    // and a custom-URL target would open a tab in it, which the membership
    // gate refuses with an exception that aborts the deletion half way.
    if (ref
            .read(generalSettingsWithDefaultsProvider)
            .homeTargetOnLastTabClosed &&
        !ref
            .read(containerMembershipGateProvider.notifier)
            .isBeingDeleted(currentContainerId)) {
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

  /// With [discardUndo], the removal cannot be undone: native's pending undo
  /// close is dropped before the close lock is released, so no undo can
  /// slip in between.
  Future<CloseResult> _closeTabsInternal(
    List<String> tabIds, {
    required bool recordTombstones,
    bool keepOffRecentlyClosed = false,
    bool discardUndo = false,
  }) {
    return _closeLock.synchronized(() async {
      CloseResult result;
      try {
        result = await closeTabsLocked(
          tabIds,
          recordTombstones: recordTombstones,
          keepOffRecentlyClosed: keepOffRecentlyClosed,
        );
        if (discardUndo && result.removedTabIds.isNotEmpty) {
          await _tabsService.discardUndoOf(
            tabIds: result.removedTabIds,
            contextIds: const [],
          );
        }
      } on TabLocksUnavailableException catch (error) {
        logger.e(
          'Did not close $tabIds: the tab locks could not be read',
          error: error.cause,
          stackTrace: error.causeStackTrace,
        );
        result = CloseResult(locksUnavailable: true);
      }
      await _locks.reconcileIfDue();
      return result;
    });
  }

  /// The close itself, for callers that already hold the close lock
  /// ([tabCloseLockProvider], not reentrant): [_closeTabsInternal] and
  /// `ContainerDeletion`.
  ///
  /// Locked tabs are taken out before any side effect
  /// ([TabLocks.lockedAmong]).
  /// Every lock change runs under [_closeLock] too, so native's removal below
  /// cannot disagree with this preflight. Throws
  /// [TabLocksUnavailableException], having done nothing, when the locks
  /// could not be read: a close that turns out refused must not have left a
  /// tombstone, a selection change or a hierarchy change behind.
  Future<CloseResult> closeTabsLocked(
    List<String> requestedTabIds, {
    required bool recordTombstones,
    bool keepOffRecentlyClosed = false,
  }) async {
    assert(_closeLock.locked, 'Runs under the close lock');
    final requested = requestedTabIds.toSet().toList();
    if (requested.isEmpty) {
      return CloseResult.none;
    }

    final (:locked, :nativeOnly) = await _locks.lockedAmong(requested);
    if (nativeOnly) {
      // Refused this time; the reconciliation completes the unlock.
      _locks.markReconcileDue();
    }
    final skippedLocked = [
      for (final id in requested)
        if (locked.contains(id)) id,
    ];
    final tabIds = [
      for (final id in requested)
        if (!locked.contains(id)) id,
    ];

    if (tabIds.isEmpty) {
      return CloseResult(skippedLockedTabIds: skippedLocked);
    }

    if (keepOffRecentlyClosed) {
      await _recentlyClosedService.keepOff(tabIds);
    }

    if (recordTombstones) {
      await ref.read(tabDatabaseProvider).tabDao.addClosedTabTombstones(tabIds);
    }

    for (final tabId in tabIds) {
      _tabBackBehavior.remove(tabId);
      final isolationContextId = ref
          .read(tabStatesProvider)[tabId]
          ?.isolationContextId;
      if (isolationContextId != null) {
        _isolationCleanup.add(isolationContextId);
      }
    }

    // Native's selection, not selectedTabProvider: its events are
    // debounced, so a tab selected a moment ago (a replacement taking over
    // a closing tab's selection, say) may not be in it yet, and the old
    // selection would pick a next tab over it.
    final selectedTab = await _tabsService.getSelectedTabId();
    if (!ref.mounted) return CloseResult(skippedLockedTabIds: skippedLocked);
    if (selectedTab.mapNotNull(tabIds.contains) ?? false) {
      await _selectNextTab(selectedTab!, excludedTabIds: tabIds.toSet());
    }

    await _preservePromotedChildOrderOnClose(tabIds);

    final removal = tabIds.length == 1
        ? await _tabsService.removeTab(tabId: tabIds.single)
        : await _tabsService.removeTabs(ids: tabIds);

    // Every lock change runs under the close lock, so native cannot have
    // locked one of these since the preflight read its locks.
    assert(
      removal.lockedTabIds.isEmpty,
      'Native kept locked tabs the preflight let through: '
      '${removal.lockedTabIds}',
    );
    if (removal.lockedTabIds.isNotEmpty) {
      logger.e(
        'Native kept locked tabs the preflight let through: '
        '${removal.lockedTabIds}',
      );
    }

    return CloseResult(
      removedTabIds: removal.removedTabIds,
      skippedLockedTabIds: [...skippedLocked, ...removal.lockedTabIds],
      missingTabIds: removal.missingTabIds,
    );
  }

  /// Closes [tabId] unless it is locked, and reports what happened.
  ///
  /// With [keepOffRecentlyClosed], for a close the user did not ask for (the
  /// tab is recreated elsewhere, its container is deleted), the tab never goes
  /// on the recently closed list.
  Future<CloseResult> closeTab(
    String tabId, {
    bool keepOffRecentlyClosed = false,
  }) {
    return _closeTabsInternal(
      [tabId],
      recordTombstones: true,
      keepOffRecentlyClosed: keepOffRecentlyClosed,
    );
  }

  /// Closes [tabIds], keeping locked tabs, and reports what happened.
  /// [keepOffRecentlyClosed] as for [closeTab].
  Future<CloseResult> closeTabs(
    List<String> tabIds, {
    bool keepOffRecentlyClosed = false,
  }) {
    return _closeTabsInternal(
      tabIds,
      recordTombstones: true,
      keepOffRecentlyClosed: keepOffRecentlyClosed,
    );
  }

  /// Puts [tabIds] to sleep (5.2 of `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`):
  /// each is held, checked for activity a sleep would cut off (D13), saved and
  /// unloaded, and stays unloaded until it is woken. Playing media and a POST
  /// result refuse unless confirmed with [stopMedia] and [discardPostResult],
  /// form input unless its tab is in [discardFormDataTabIds]. Nothing is
  /// closed, so no tombstone, undo or recently-closed entry results.
  Future<List<TabSleepResult>> sleepTabs(
    List<String> tabIds, {
    bool stopMedia = false,
    bool discardPostResult = false,
    List<String> discardFormDataTabIds = const [],
  }) {
    return _tabLifecycle.sleepTabs(
      tabIds,
      stopMedia: stopMedia,
      discardPostResult: discardPostResult,
      discardFormDataTabIds: discardFormDataTabIds,
    );
  }

  /// Wakes [tabId] once routing is installed, and only while it covers the
  /// tab's own context, which native checks (D34): an isolated tab's own
  /// route counts, not just its container's. Without routing it stays
  /// asleep, so nothing of it goes out another way. Native also leaves a
  /// frozen container's tab asleep, with its hold.
  Future<TabWakeOutcome> wakeTab(String tabId) async {
    final ready = await ref
        .read(containerProxyRepositoryProvider.notifier)
        .waitUntilRoutingReady();
    if (!ref.mounted) return TabWakeOutcome.routingNotReady;
    if (!ready) {
      logger.w('Tab $tabId not woken: routing is not installed');
      return TabWakeOutcome.routingNotReady;
    }
    if (await _tabLifecycle.wakeTab(tabId)) return TabWakeOutcome.woken;
    final state = await _tabLifecycle.tabLifecycleState(tabId);
    if (state?.contextFrozen ?? false) {
      logger.w('Tab $tabId not woken: its container is frozen');
      return TabWakeOutcome.containerFrozen;
    }
    logger.w('Tab $tabId not woken: its routing has no route out');
    return TabWakeOutcome.routingNotReady;
  }

  /// Before a navigation the user asked for in [tabId] (5.2.1), whose sleep
  /// [hold] native reported just now: a sleeping tab is woken first, so the
  /// navigation runs once rather than being dropped with the tab still
  /// asleep. False when it stays asleep; the caller must not navigate then,
  /// and the user is told why when it was its routing.
  Future<bool> wakeForNavigation(String tabId, TabSleepHold? hold) async {
    if (hold == null || hold == TabSleepHold.none) return true;
    final outcome = await wakeTab(tabId);
    if (outcome == TabWakeOutcome.woken) return true;
    logger.w('Not navigating sleeping tab $tabId: $outcome');
    // A frozen container's tab is asked about before ("Resume and open?"):
    // frozen only since then, it says nothing more.
    if (outcome == TabWakeOutcome.routingNotReady && ref.mounted) {
      ref
          .read(containerFreezeNoticesProvider.notifier)
          .add(const NavigationWaitsForRouting());
    }
    return false;
  }

  /// Locks or unlocks [tabId]: a locked tab refuses to close and is skipped
  /// by every bulk close until it is unlocked ([TabLocks]). Under
  /// [_closeLock], like every close, so no close can fall between the lock's
  /// two writes.
  Future<TabLockOutcome> setTabLocked(String tabId, {required bool locked}) =>
      _closeLock.synchronized(() => _locks.setLocked(tabId, locked: locked));

  /// Locks [tabId], or unlocks it when it counts as locked ([isTabLocked]),
  /// which includes a tab whose unlock did not finish, so this is also its
  /// retry. The state is read under [_closeLock] with the change, from the
  /// database rather than a lock stream that may not have loaded yet.
  /// [wasLocked] is what was read.
  Future<({TabLockOutcome outcome, bool wasLocked})> toggleTabLocked(
    String tabId,
  ) => _closeLock.synchronized(() async {
    final wasLocked = await _locks.isLocked(tabId);
    final outcome = await _locks.setLocked(tabId, locked: !wasLocked);
    return (outcome: outcome, wasLocked: wasLocked);
  });

  /// Whether [tabId] counts as locked: in the database, or after an unlock
  /// that did not finish. For choosing what to offer; the close decides.
  Future<bool> isTabLocked(String tabId) => _locks.isLocked(tabId);

  /// Retries a reconciliation after an unlock that did not finish.
  Future<bool> retryLockReconciliation() =>
      _closeLock.synchronized(_locks.reconcile);

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

  /// Reopens the tabs closed last, while the engine can still undo that
  /// close.
  ///
  /// Which containers the undone tabs come back into is only known once they
  /// are back, so no container may be deleted meanwhile: nothing is reopened
  /// while one is being deleted, and no deletion starts until the reopened
  /// tabs have their rows. Both ends are confirmed rather than assumed: the
  /// engine answers once its restore is in its store (it runs after the undo
  /// was dispatched, and clearing the undo history does not stop it), and the
  /// rows are checked after every tab list sync.
  ///
  /// Held the same way, no freeze starts meanwhile, and a frozen container
  /// takes back only tabs whose storage its freeze holds
  /// ([_undoRefusal]).
  Future<UndoCloseOutcome> undoClose() async {
    final outcome = await ref
        .read(containerMembershipGateProvider.notifier)
        .whileChangingAnywhere(_undoCloseHeld);
    if (outcome == null) {
      logger.w(
        'Undo skipped while a container is being deleted or a Resume '
        'releases isolation groups',
      );
      return UndoCloseOutcome.refused;
    }
    return outcome;
  }

  /// Why one of [pending] may not come back, as the notice that says so;
  /// null when all of them may. Not into storage whose release has begun
  /// (`releasing`), whatever its container's state: its data is being
  /// deleted, and a release that did not finish is retried and would wipe
  /// the tab's page, though the container may have resumed since. Nor into a
  /// frozen container while its freeze does not hold the storage the tab ran
  /// in. The tab's row comes back as it was closed, with its container, and
  /// its page in that storage. An isolation group whose last tab it was left
  /// the container's rows with it, so a freeze since did not cover it: back,
  /// it would run in a container shown as frozen. A tab whose storage the
  /// freeze holds comes back frozen with it, and one of a container that is
  /// not restricted comes back as ever.
  Future<ContainerFreezeNotice?> _undoRefusal(
    List<PendingUndoTab> pending,
  ) async {
    final gate = ref.read(containerMembershipGateProvider.notifier);
    final tabDao = ref.read(tabDatabaseProvider).tabDao;
    await gate.seed();
    for (final tab in pending) {
      final contextId = tab.contextId;
      if (contextId != null &&
          gate.contextRecord(contextId)?.phase ==
              ContextFreezePhase.releasing) {
        logger.w(
          'Undo refused: storage $contextId waits for its data deletion',
        );
        return const UndoWaitsForSiteDataDeletion();
      }
      final containerId = tabDao.undoRowOf(tab.tabId)?.containerId;
      if (containerId == null || !gate.isRestricted(containerId)) continue;
      if (contextId != null && gate.isContextRestricted(contextId)) continue;
      logger.w(
        'Undo refused: a tab would run in frozen container $containerId',
      );
      return PageNotOpened(ContainerFrozenException(containerId));
    }
    return null;
  }

  /// How long an undo waits for the rows of the tabs the engine confirmed it
  /// restored, so that a sync that never comes cannot hold off container
  /// deletion for good. Not a completion signal: reaching it is an error.
  static const _undoRowsBackstop = Duration(seconds: 30);

  /// How often an undo checks the tabs to undo again when a close came
  /// between its check and the engine's undo ([_undoCloseHeld]).
  static const _undoAttempts = 3;

  Future<UndoCloseOutcome> _undoCloseHeld() async {
    // A close between the check and the undo replaces what there is to undo,
    // and the engine refuses the request for the tabs that were checked: the
    // new ones are checked in turn. Taken for nothing to undo, the refusal
    // would reopen an older tab from Recently Closed instead.
    for (var attempt = 0; attempt < _undoAttempts; attempt++) {
      final pending = await _tabsService.pendingUndoTabs();
      if (pending.isEmpty) return UndoCloseOutcome.nothingToUndo;
      if (await _undoRefusal(pending) case final refusal?) {
        if (ref.mounted) {
          ref.read(containerFreezeNoticesProvider.notifier).add(refusal);
        }
        return UndoCloseOutcome.refused;
      }
      final restored = await _undoChecked(pending);
      if (restored.isNotEmpty) return await _awaitUndoRows(restored);
    }
    logger.w('Undo skipped: tabs kept closing while it was checked');
    return UndoCloseOutcome.refused;
  }

  /// Has the engine undo the close of [pending], and only that: empty when
  /// a close since replaced it, or nothing could be restored.
  Future<List<String>> _undoChecked(List<PendingUndoTab> pending) async {
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
    var restored = const <String>[];
    try {
      // Only what was checked: a close since replaced the pending undo.
      restored = await _tabsService.undo([
        for (final tab in pending) tab.tabId,
      ]);
    } finally {
      if (restored.isEmpty) _suppressNextReclose = false;
    }
    return restored;
  }

  /// Waits, after an undo that brought back [restored], until their rows
  /// are there, so no container deletion starts before.
  Future<UndoCloseOutcome> _awaitUndoRows(List<String> restored) async {
    // A replaced tab can be among those it brought back.
    _replacements.undone();

    final rows = (tabIds: restored.toSet(), landed: Completer<void>());
    _undoRows.add(rows);
    // Their tab list change may have been synced before the engine answered.
    await _checkUndoRows(await _tabsService.getTabIds());
    await rows.landed.future.timeout(
      _undoRowsBackstop,
      onTimeout: () {
        logger.e(
          'Undone tabs ${rows.tabIds} have no rows after '
          '${_undoRowsBackstop.inSeconds}s; container deletion is allowed again',
        );
        _undoRows.remove(rows);
      },
    );
    return UndoCloseOutcome.reopened;
  }

  /// Completes each pending undo once every tab it restored that is still
  /// open ([openTabIds]) has its row. A restored tab closed again needs none.
  Future<void> _checkUndoRows(Iterable<String> openTabIds) async {
    if (_undoRows.isEmpty) return;
    final pending = [..._undoRows];
    final open = openTabIds.toSet();
    final waiting = {
      for (final rows in pending)
        for (final id in rows.tabIds)
          if (open.contains(id)) id,
    };
    final withRows = waiting.isEmpty
        ? const <String>{}
        : (await ref
                  .read(tabDatabaseProvider)
                  .tabDao
                  .getExistingTabIds(waiting)
                  .get())
              .toSet();
    for (final rows in pending) {
      // Timed out meanwhile.
      if (!_undoRows.contains(rows)) continue;
      if (rows.tabIds.where(open.contains).every(withRows.contains)) {
        _undoRows.remove(rows);
        rows.landed.complete();
      }
    }
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

    // As for addTab: the tab is restored into its container.
    return await ref
        .read(containerMembershipGateProvider.notifier)
        .whileChanging([container?.id], () async {
          // Read again under the reservation: a deletion that finished since
          // the lookup sends the tab back unassigned, as one that finished
          // before it.
          final current = await container.mapNotNull(
            (container) => ref
                .read(containerRepositoryProvider.notifier)
                .getContainerData(container.id),
          );
          if (containerId != null && current == null) {
            await _recentlyClosedService.remove(tab.id);
            await tabDao.deleteClosedTabContainers([tab.id]);

            return await addTab(
              url: Uri.tryParse(tab.url),
              tabMode: TabMode.regular,
              selectTab: selectTab,
              containerSelection: const TabContainerSelection.unassigned(),
            );
          }

          // Its close left a tombstone, which would have the tab list listener
          // close it again as a stale restore.
          await tabDao.deleteClosedTabTombstones([tab.id]);

          final String restoredId;
          try {
            restoredId = await tabDao.upsertTabTransactional(
              () async =>
                  await _recentlyClosedService.restore(
                    tab.id,
                    contextId: current?.metadata.contextualIdentity,
                    selectTab: selectTab,
                    excludeFromHistory:
                        current?.metadata.excludeFromHistory ?? false,
                  ) ??
                  (throw const _NoLongerClosed()),
              parentId: const Value(null),
              containerId: Value(current?.id),
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
                .followTab(current?.id);
          }

          return restoredId;
        });
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
      final result = await _closeTabsInternal(
        restoredClosedTabIds.toList(growable: false),
        recordTombstones: false,
      );

      // A locked tab is never closed again as a stale restore. Its tombstone
      // would only keep asking.
      if (result.skippedLockedTabIds.isNotEmpty) {
        await tabDao.deleteClosedTabTombstones(result.skippedLockedTabIds);
      }

      // Without a removal no tab list change follows, and the caller has to
      // go on with this one.
      return result.closedAny;
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
  //       _isolationCleanup.addAll(
  //         syncTabsResult.deletedIsolationContextIds,
  //       );
  //       await _isolationCleanup.drain();
  //     });
  //   } catch (e, st) {
  //     logger.e(
  //       'Error during orphan isolation context cleanup',
  //       error: e,
  //       stackTrace: st,
  //     );
  //   }
  // }

  /// Shows [report]'s cancelled navigation in its page's stand-in
  /// ([BackgroundStandIns]), opening one with [open] when there is none.
  ///
  /// One report at a time. A report that comes in while its page's stand-in
  /// opens is loaded there by the open, and then has nothing left to do
  /// ([BackgroundStandIns.opened]).
  Future<void> _showInStandIn(
    StandInReport report,
    Future<String> Function([Uri? url]) open,
  ) {
    // Before waiting for its turn: an open in progress picks it up.
    _backgroundStandIns.arrived(report);
    return _standInLock.synchronized(() async {
      try {
        await _standInTurn(report, open);
      } finally {
        _backgroundStandIns.done(report);
      }
    });
  }

  /// [report]'s turn under [_standInLock]; see [_showInStandIn].
  Future<void> _standInTurn(
    StandInReport report,
    Future<String> Function([Uri? url]) open,
  ) async {
    // Superseded or loaded already while it waited: nothing to ask native
    // for, and the latest report is not kept waiting behind this one.
    if (!_backgroundStandIns.isWaiting(report)) return;

    // Which tabs are open and selected, from the native store at its turn;
    // see [BackgroundStandIns.sync].
    final (openTabIds, selectedTabId) = await (
      _tabsService.getTabIds(),
      _tabsService.getSelectedTabId(),
    ).wait;
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
    );
    if (!_backgroundStandIns.take(report)) return;

    final StandInReport(:sourceTabId, :uri) = report;
    switch (_backgroundStandIns.request(sourceTabId, uri)) {
      case StandInCurrent():
        return;
      case LoadInStandIn(:final tabId):
        // Nobody has seen either tab: the page's latest navigation replaces
        // the stand-in's, as it would have in the tab itself.
        await GeckoSessionService(tabId: tabId).loadUrl(url: uri);
      case OpenStandIn():
        final String standInId;
        try {
          standInId = await open(uri);
        } catch (_) {
          _backgroundStandIns.openFailed();
          rethrow;
        }
        // A report that came in meanwhile is loaded only while its source
        // and the stand-in are still open. Unknown when the tabs cannot be
        // listed: the stand-in is recorded unchecked, and that report waits
        // for its turn ([BackgroundStandIns.opened]).
        List<String>? stillOpen;
        try {
          stillOpen = await _tabsService.getTabIds();
        } catch (error, stackTrace) {
          logger.w(
            'Could not list the open tabs after opening stand-in $standInId',
            error: error,
            stackTrace: stackTrace,
          );
        }
        if (!ref.mounted) return;
        final newer = _backgroundStandIns.opened(
          sourceTabId,
          uri,
          standInId,
          openTabIds: stillOpen,
        );
        if (newer != null) {
          await GeckoSessionService(tabId: standInId).loadUrl(url: newer);
        }
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

      // A locked tab is never replaced: the site opens beside it. Only a hint
      // for which branch to take; if a lock arrives after it, the replacement
      // helpers keep the original all the same.
      final locked = await isTabLocked(currentTabState.id);
      if (!isCurrentRequest()) return;

      // The container refuses what follows while it is being deleted (D35),
      // and while it is frozen, a tab that moves into it or an isolated tab
      // opened in it (D19): the user is asked to resume it first (5.2.1).
      // A regular tab opened in a frozen container is held there, and needs
      // neither.
      final gate = ref.read(containerMembershipGateProvider.notifier);
      if (gate.isBeingDeleted(containerData.id)) {
        _reportPageNotOpened(ContainerBeingDeletedException(containerData.id));
        return;
      }
      if (!(event.blocked || tabIsEmpty) ||
          currentTabState.tabMode is IsolatedTabMode) {
        await gate.seed();
        if (!isCurrentRequest()) return;
        if (gate.isRestricted(containerData.id) &&
            (!await ref
                    .read(containerFreezeServiceProvider.notifier)
                    .resumeToOpen(containerData.id) ||
                !isCurrentRequest())) {
          return;
        }
      }

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

        if (historyIsEmpty && !locked) {
          // A replacement: the new tab takes the old one's place, in a split
          // pair too — unless the original turned out to be locked, when the
          // slot stays with it.
          await splitView.carryOver(
            currentTabState.id,
            () async => (await replaceTabOpeningFirst(
              oldTabId: currentTabState.id,
              focused: !staysUnfocused,
              open: openInAssignedContainer,
              selectedTabId: _tabsService.getSelectedTabId,
              closeOld: (newTabId) =>
                  _closeReplacedTab(currentTabState.id, newTabId),
              select: selectTab,
              isMounted: () => ref.mounted,
            )).replacementTabId,
          );
        } else if (!staysUnfocused) {
          await openInAssignedContainer();
        } else {
          await _showInStandIn(
            StandInReport(
              sourceTabId: currentTabState.id,
              uri: uri,
              selectedTabId: selectedTabId,
              isCurrent: isCurrentRequest,
            ),
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
          final tabData = ref.read(tabDataRepositoryProvider.notifier);
          var moved = await tabData.assignContainer(
            latestTabState.id,
            containerData,
            closeOldTab: !locked,
            replacementUrl: uri,
          );
          // Locked after the hint above, or its lock could not be read: the
          // original stayed and nothing was opened, so the site opens beside
          // it as for any locked tab.
          if ((moved == ContainerMoveResult.lockedNeedsSameContext ||
                  moved == ContainerMoveResult.locksUnavailable) &&
              isCurrentRequest()) {
            moved = await tabData.assignContainer(
              latestTabState.id,
              containerData,
              closeOldTab: false,
              replacementUrl: uri,
            );
          }
          _reportMoveRefusal(containerData.id, moved);
        } else if (latestTabState.url == originUri) {
          _reportMoveRefusal(
            containerData.id,
            await ref
                .read(tabDataRepositoryProvider.notifier)
                .assignContainer(
                  latestTabState.id,
                  containerData,
                  closeOldTab: false,
                  replacementUrl: uri,
                ),
          );
        } else {
          logger.w(
            'Could not match origin url for assignment ${latestTabState.url} to request ${event.originUrl}',
          );
        }
      }
    } on ContainerRefusedTabException catch (refusal) {
      // Frozen or being deleted after the checks above.
      _reportPageNotOpened(refusal);
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

  /// Tells the user that a site assigned to a container did not open there,
  /// because the container refused it; the browser shows it.
  void _reportPageNotOpened(ContainerRefusedTabException refusal) {
    logger.w('Site not opened: $refusal');
    if (!ref.mounted) return;
    ref
        .read(containerFreezeNoticesProvider.notifier)
        .add(PageNotOpened(refusal));
  }

  /// [_reportPageNotOpened] for a move into [containerId] that its container
  /// refused (a lock stays silent: the site opened beside the tab).
  void _reportMoveRefusal(String containerId, ContainerMoveResult result) {
    switch (result) {
      case ContainerMoveResult.containerFrozen:
        _reportPageNotOpened(ContainerFrozenException(containerId));
      case ContainerMoveResult.containerBeingDeleted:
        _reportPageNotOpened(ContainerBeingDeletedException(containerId));
      case ContainerMoveResult.moved ||
          ContainerMoveResult.lockedNeedsSameContext ||
          ContainerMoveResult.locksUnavailable:
        break;
    }
  }

  /// Gives tab [tabId], which the engine opened (from tab [openerId], when it
  /// names one), its row. The tab added listener in [build]; a method so that
  /// tests can call it.
  @visibleForTesting
  Future<void> handleTabAdded(String tabId, {String? openerId}) async {
    final db = ref.read(tabDatabaseProvider);
    final gate = ref.read(containerMembershipGateProvider.notifier);

    Future<void> insert(Value<String?> containerId) => db.tabDao.insertTab(
      tabId,
      parentId: const Value.absent(),
      // Link an engine-opened tab to its opener and place it per the child
      // tab placement setting right away, so it never has to move once the
      // parent is seeded from engine state. An app-created tab already has
      // its row (manual source wins the upsert), so this is a no-op for it.
      openerId: Value(openerId),
      childPlacement: ref
          .read(generalSettingsWithDefaultsProvider)
          .childTabPlacement,
      source: TabSource.addedEvent,
      containerId: containerId,
    );

    // A tab opened from another tab runs in its opener's context, so
    // `insertTab` files it with the opener rather than with whatever
    // container is selected. A tab without an opener (an extension's
    // `tabs.create`) still lands in the selected container, unless that one
    // is frozen: it runs in the default storage, which no freeze holds, and
    // would be a running page in a container shown as frozen (native refuses
    // to freeze one that has such a tab).
    final String? targetContainerId;
    String? inheritedContainerId;
    if (openerId == null) {
      final selected = ref.read(selectedContainerProvider);
      targetContainerId = await _runsOutsideFreezeOf(tabId, selected)
          ? null
          : selected;
    } else {
      final openerHasRow = (await db.tabDao.getExistingTabIds({
        openerId,
      }).get()).isNotEmpty;
      targetContainerId = openerHasRow
          ? await db.tabDao.getTabContainerId(openerId).getSingleOrNull()
          : null;
      if (targetContainerId == null) {
        inheritedContainerId = await _containerOfRowlessOpener(
          openerId,
          openerHasRow: openerHasRow,
        );
      }
    }

    if (inheritedContainerId != null) {
      // The opener belonged to a container its row does not name (any more):
      // the tab gets a row under no container first, then goes where that
      // container's tabs go: into it, or closed with it.
      await insert(const Value(null));
      gate.recordOpenedFrom(inheritedContainerId, tabId);
      await _settleTabOfContainer(tabId, inheritedContainerId);
      return;
    }

    try {
      // Joining a container, the row holds its reservation like any other
      // addition ([ContainerMembershipGate]).
      await gate.whileChanging(
        [targetContainerId],
        () => insert(
          openerId == null
              ? Value(targetContainerId)
              : const Value<String?>.absent(),
        ),
        openedTabId: openerId == null ? null : tabId,
      );
    } on ContainerBeingDeletedException catch (refusal) {
      // The tab exists already, so it gets a row all the same, under no
      // container: its row cannot join a container that is going away.
      await insert(const Value(null));
      // A window one of the container's pages opened belongs to it: the
      // deletion closes it with the container's own tabs, as it was told
      // by the refusal. An extension's tab only would have been filed under
      // the selected container, and runs wherever the extension put it.
      if (openerId != null) {
        await _settleTabOfContainer(tabId, refusal.containerId);
      }
    }
  }

  /// Whether [containerId] is restricted ([ContainerMembershipGate.isRestricted])
  /// and tab [tabId] runs in storage its freeze does not hold: its context,
  /// as far as it is known yet, has no restriction. False for no container.
  Future<bool> _runsOutsideFreezeOf(String tabId, String? containerId) async {
    if (containerId == null) return false;
    final gate = ref.read(containerMembershipGateProvider.notifier);
    await gate.seed();
    if (!gate.isRestricted(containerId)) return false;
    final contextId = ref.read(tabStatesProvider)[tabId]?.contextId;
    return contextId == null || !gate.isContextRestricted(contextId);
  }

  /// The container the tab [openerId] belonged to although its row names
  /// none, or null when it belonged to none:
  ///
  /// - a tab a deletion took, refused while it ran, or that such a tab
  ///   opened ([ContainerMembershipGate.deletionLineageOf]), while that
  ///   container is being deleted or is gone. A deletion that was refused
  ///   left its tabs' rows in place, so they decide then;
  /// - a tab closed before this event arrived: the container its row had
  ///   when it went ([TabDao.closedTabContainers]).
  Future<String?> _containerOfRowlessOpener(
    String openerId, {
    required bool openerHasRow,
  }) async {
    final db = ref.read(tabDatabaseProvider);
    final gate = ref.read(containerMembershipGateProvider.notifier);

    final lineage = gate.deletionLineageOf(openerId);
    if (lineage != null &&
        (gate.isBeingDeleted(lineage) ||
            await db.containerDao.getContainerData(lineage).getSingleOrNull() ==
                null)) {
      return lineage;
    }
    // A row under no container is an unassigned tab's.
    if (openerHasRow) return null;
    return (await db.tabDao.closedTabContainers([
      openerId,
    ]))[openerId]?.containerId;
  }

  /// Settles tab [tabId], which belongs to container [containerId] though its
  /// row names none (a window opened from the container's page while it was
  /// being deleted, or after its opener's row went), once no deletion of the
  /// container is in flight: closed when the container went, unless the
  /// deletion closed it already, and filed into the container otherwise.
  Future<void> _settleTabOfContainer(String tabId, String containerId) async {
    final gate = ref.read(containerMembershipGateProvider.notifier);
    await gate.deletionFinished(containerId);
    if (!ref.mounted) return;

    final db = ref.read(tabDatabaseProvider);
    try {
      final containerKept =
          await db.containerDao
              .getContainerData(containerId)
              .getSingleOrNull() !=
          null;
      if (!containerKept) {
        // Missing, when the deletion closed it: nothing happens then. Not
        // undoable: the deletion dropped the undo of its own tabs already,
        // and an undo of this one would bring it back into the deleted
        // container's storage, with no container left to route it.
        await _closeTabsInternal(
          [tabId],
          recordTombstones: true,
          keepOffRecentlyClosed: true,
          discardUndo: true,
        );
        return;
      }

      await gate.whileChanging(
        [containerId],
        () => db.tabDao.assignContainer(tabId, containerId: containerId),
        openedTabId: tabId,
      );
    } on ContainerBeingDeletedException {
      // Another deletion of it started meanwhile, and was told of the tab.
      await _settleTabOfContainer(tabId, containerId);
    } catch (error, stackTrace) {
      // The stream's `onError` never sees what an async listener throws.
      logger.e(
        'Could not settle tab $tabId, opened while container $containerId '
        'was being deleted',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Brings the rows in line with the engine's tab list after it changed.
  /// The tab list listener in [build]; a method so that tests can call it.
  @visibleForTesting
  Future<void> handleTabListChange(
    EquatableValue<List<String>>? previous,
    EquatableValue<List<String>> next,
  ) async {
    try {
      await _syncTabList(previous, next);
    } finally {
      // An undo close waits for its tabs' rows, which this sync may have
      // written.
      if (_undoRows.isNotEmpty && ref.mounted) {
        await _checkUndoRows(next.value);
      }
    }
  }

  Future<void> _syncTabList(
    EquatableValue<List<String>>? previous,
    EquatableValue<List<String>> next,
  ) async {
    final db = ref.read(tabDatabaseProvider);
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
      _isolationCleanup.addAll(syncTabsResult.deletedIsolationContextIds);
    }

    // Process pending isolation context cleanups after syncTabs
    // has deleted the rows, so the count check is accurate.
    await _isolationCleanup.drain();

    // One-shot orphan cleanup after tab list stabilizes (5s debounce).
    // Also runs for DB-only contexts whose rows were already deleted
    // by syncTabs above (those are handled via _isolationCleanup).
    // if (!orphanCleanupDone) {
    //   orphanCleanupTimer?.cancel();
    //   orphanCleanupTimer = Timer(const Duration(seconds: 5), () async {
    //     if (orphanCleanupDone || !ref.mounted) return;
    //     orphanCleanupDone = true;
    //     await _cleanupOrphanedIsolationContexts();
    //   });
    // }
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
      (event) async =>
          await handleTabAdded(event.tabId, openerId: event.parentId),
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

    // Wake on a sleeping tab's placeholder: native only asks, because the
    // routing has to be checked first (D34).
    final wakeRequestSub = eventSerivce.wakeRequestEvents.listen(
      (tabId) async {
        try {
          await wakeTab(tabId);
        } catch (error, stackTrace) {
          // The stream's `onError` never sees what an async listener throws.
          logger.e(
            'Could not wake $tabId from its placeholder',
            error: error,
            stackTrace: stackTrace,
          );
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        logger.e(
          'Error in wake request stream',
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
      (previous, next) async => await handleTabListChange(previous, next),
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

        _isolationCleanup.addAll(syncTabsResult.deletedIsolationContextIds);
        await _isolationCleanup.drain();

        await _reattachTabsToContextContainers();

        // Now that the restored tabs are open and the database has caught up
        // with them, native's locks become the database's: a lock native took
        // but the database never acknowledged is dropped, and an unlock native
        // missed is completed.
        if (ref.mounted) await _closeLock.synchronized(_locks.reconcile);
      }
    });

    final tabStateDebouncer = Debouncer(const Duration(seconds: 1));
    Map<String, TabState>? debounceStartValue;
    // A self-update ends the process without warning; the installer flushes
    // this first so the last second of tab changes is not lost.
    final unregisterFlush = ref
        .read(pendingWritesProvider)
        .register(tabStateDebouncer.flush);

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
      unregisterFlush();
      tabStateDebouncer.dispose();
      await tabAddedSub.cancel();
      await tabContentSub.cancel();
      await containerSiteAssignementSub.cancel();
      await wakeRequestSub.cancel();
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
