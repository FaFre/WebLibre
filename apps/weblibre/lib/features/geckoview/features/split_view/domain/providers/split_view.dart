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

import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_list.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/entities/split_pair.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/services/split_view_native_sync.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

part 'split_view.g.dart';

/// How long to wait for a just-opened tab to reach Dart. The native tab list
/// is debounced and content state follows it, so a new tab shows up late.
const _newTabArrival = Duration(seconds: 5);

/// The one split pair, held in memory for the life of the Flutter engine.
///
/// Keep-alive so the pair outlives every widget, route and sheet. Rotation
/// and resizing keep it (handled in place); an engine recreation or process
/// death loses it. Nothing is persisted.
@Riverpod(keepAlive: true)
class SplitViewController extends _$SplitViewController {
  /// Members being recreated under a new id (container move, site
  /// assignment), mapped to the id of the pair they belong to. Their removal
  /// does not end the pair: the replacement takes their slot.
  final _pendingReplacements = <String, String>{};

  /// Each tab's latest pair, kept after the pair ends and dropped when the
  /// tab closes. The Split toggle uses it to bring back the tab's partner,
  /// sides, layout and ratios.
  final _lastPairs = <String, SplitPair>{};

  /// Bumped by every [pair] request and by [end]. A request commits only if
  /// the generation is unchanged after each of its waits, so an older request
  /// never overrides a newer choice or revives an ended split.
  int _pairingGeneration = 0;

  // Pure state. The tab list is followed by [splitViewReconciliation], so a
  // widget that only shows membership (a badge) never starts the engine.
  @override
  SplitPair? build() {
    listenSelf((_, pair) {
      if (pair == null) return;
      _lastPairs[pair.firstTabId] = pair;
      _lastPairs[pair.secondTabId] = pair;
    });
    return null;
  }

  // ---------------------------------------------------------------------------
  // Queries
  // ---------------------------------------------------------------------------

  /// The latest pair [tabId] was in, current or ended; null if it never was.
  /// The partner may have closed since, so callers check.
  SplitPair? lastPairOf(String tabId) => _lastPairs[tabId];

  /// Whether [tabId] is in the shown pair but is not the selected tab.
  /// A pair kept while split view is hidden counts as no pair (H1).
  bool isUnfocusedMember(String tabId) {
    // Read through the container: [splitPairShownProvider] watches this
    // notifier, so reading it through [ref] would be a dependency cycle.
    final pair = ref.container.read(splitPairShownProvider);
    return pair != null &&
        pair.contains(tabId) &&
        ref.read(selectedTabProvider) != tabId;
  }

  // ---------------------------------------------------------------------------
  // Forming and ending the pair
  // ---------------------------------------------------------------------------

  /// Shows [first] and [second] together and returns once native applied it.
  /// Callers select a tab only afterwards, so the selection reaches native
  /// after the pair does.
  ///
  /// - If [first] is already in the pair, only its partner changes; layout
  ///   and ratios carry over.
  /// - With [arrangement] (a remembered pair of the same two tabs), a new
  ///   pair is formed with its layout and ratios.
  /// - Otherwise a new pair is formed with the defaults.
  ///
  /// Both pages are always shown: "Show only this page" is cleared, or the
  /// page just asked for would stay hidden.
  ///
  /// Throws [SplitViewError]:
  /// - [SplitViewErrorKind.superseded] when a newer request or [end] came in
  ///   during one of the waits. This wins over any other outcome.
  /// - [SplitViewErrorKind.notApplied] when native rejected the pair; the
  ///   previous pair, which native still shows, is put back.
  /// - Otherwise the kind of validation that failed.
  Future<void> pair(
    String first,
    String second, {
    SplitPair? arrangement,
  }) async {
    // Rejected before bumping the generation, so an invalid request does not
    // cancel a valid one still waiting.
    if (first == second) {
      throw const SplitViewError(SplitViewErrorKind.sameTab);
    }
    final generation = ++_pairingGeneration;

    // 1. Both tabs exist and share a privacy mode.
    final [firstState, secondState] = await _awaitContentStates(first, second);
    if (!_isCurrent(generation)) return;
    if (firstState == null || secondState == null) {
      throw const SplitViewError(SplitViewErrorKind.missingTab);
    }
    if (!canShareSplit(firstState.tabMode, secondState.tabMode)) {
      throw const SplitViewError(SplitViewErrorKind.mixedPrivacy);
    }

    // 2. Both tabs' routing is installed.
    final routingReady = await _ensureRoutingReady(first, second);
    if (!_isCurrent(generation)) return;
    if (!routingReady) {
      throw const SplitViewError(SplitViewErrorKind.routingNotReady);
    }

    // 3. Both tabs are still open. Content state outlives a closed tab for a
    //    while, and that tab's removal has already passed the reconciliation,
    //    which would then never end a pair formed with it. So this comes last,
    //    after every wait.
    final tabStates = ref.read(tabStatesProvider.notifier);
    if (tabStates.isClosed(first) || tabStates.isClosed(second)) {
      throw const SplitViewError(SplitViewErrorKind.missingTab);
    }

    // 4. Commit and push to native.
    final previous = state;
    final next = _nextPair(first, second, arrangement);
    state = next;

    final applied = await flushSplitViewState(ref.container);
    // A newer request or [end] during the push decides what is shown and
    // pushes it itself; this one must not select over it.
    if (!_isCurrent(generation)) return;
    if (!applied) {
      // Native still shows the previous pair. Put it back, unless something
      // else changed the pair meanwhile (that change is pushed on its own).
      if (identical(state, next)) state = previous;
      throw const SplitViewError(SplitViewErrorKind.notApplied);
    }
  }

  /// Ends the split. Both tabs stay open.
  void end() {
    _pairingGeneration++;
    state = null;
  }

  // ---------------------------------------------------------------------------
  // Editing the pair
  // ---------------------------------------------------------------------------

  void swap() => _updatePair((pair) => pair.swapped());

  void setLayout(SplitLayoutPreference layout) =>
      _updatePair((pair) => pair.copyWith(layout: layout));

  void setFocusedOnly(bool focusedOnly) =>
      _updatePair((pair) => pair.copyWith(focusedOnly: focusedOnly));

  /// Equal sizes on both axes.
  void equalize() => _updatePair(
    (pair) => pair.copyWith(sideBySideRatio: 0.5, stackedRatio: 0.5),
  );

  /// A divider release. Ignored when [pairId] is stale (the pair it was
  /// dragged on has been replaced).
  void setRatio(String pairId, SplitRatioAxis axis, double ratio) {
    final pair = _pairWithId(pairId);
    if (pair == null) return;

    final clamped = ratio.clamp(0.0, 1.0);
    state = switch (axis) {
      SplitRatioAxis.sideBySide => pair.copyWith(sideBySideRatio: clamped),
      SplitRatioAxis.stacked => pair.copyWith(stackedRatio: clamped),
    };
  }

  /// The divider was released at the edge: only [keptTabId]'s page is shown
  /// (native has already selected it). The ratios stay, so showing both pages
  /// again restores the last arrangement.
  ///
  /// Returns false, changing nothing, when [pairId] is stale.
  bool collapseTo(String pairId, String keptTabId) {
    final pair = _pairWithId(pairId);
    if (pair == null || !pair.contains(keptTabId)) return false;

    state = pair.copyWith(focusedOnly: true);
    return true;
  }

  /// Undoes [collapseTo]. Ignored once the pair was replaced or ended.
  void showBothPages(String pairId) {
    final pair = _pairWithId(pairId);
    if (pair == null || !pair.focusedOnly) return;

    state = pair.copyWith(focusedOnly: false);
  }

  // ---------------------------------------------------------------------------
  // Following the tab list
  // ---------------------------------------------------------------------------

  /// Ends the pair once a member is removed for good (closed, closed with all
  /// others, quit cleanup, a native removal, a failed restore).
  ///
  /// A removal is a tab that was in the list and is not any more. Mere
  /// absence is not: a just-created tab reaches the debounced tab list after
  /// `addTab` returned, and may be paired before that.
  void onTabListChanged(Set<String> before, Set<String> after) {
    bool wasRemoved(String tabId) =>
        before.contains(tabId) && !after.contains(tabId);

    _lastPairs.removeWhere((tabId, _) => wasRemoved(tabId));

    final pair = state;
    if (pair == null) return;

    bool endsPair(String tabId) =>
        wasRemoved(tabId) && _pendingReplacements[tabId] != pair.pairId;

    if (endsPair(pair.firstTabId) || endsPair(pair.secondTabId)) {
      state = null;
    }
  }

  /// Runs [replace], which recreates [oldTabId] under a new id (close + add)
  /// and returns that id, then moves [oldTabId]'s slot in the pair to it.
  ///
  /// The old tab's removal reaches Dart some time after its close returns
  /// (the native tab list is debounced), so [oldTabId] is marked as a pending
  /// replacement until the move is settled, whichever order things arrive in.
  /// A re-pair or [end] in the meantime wins over the move.
  Future<String?> carryOver(
    String oldTabId,
    Future<String?> Function() replace,
  ) async {
    final pair = state;
    if (pair == null || !pair.contains(oldTabId)) {
      return await replace();
    }

    // Held until the move is settled, not just until [replace] returns:
    // settling can wait for the new tab's content state, and the old tab's
    // removal arriving meanwhile must not end the pair.
    _pendingReplacements[oldTabId] = pair.pairId;
    String? newTabId;
    try {
      return newTabId = await replace();
    } finally {
      // Runs whether or not [replace] threw; without a new tab the pair ends
      // once the old one is gone.
      try {
        if (ref.mounted) {
          await _settleReplacement(pair.pairId, oldTabId, newTabId);
        }
      } finally {
        _pendingReplacements.remove(oldTabId);
      }
    }
  }

  /// Puts [newTabId] into [oldTabId]'s slot if the pair with [pairId] still
  /// holds [oldTabId] and the new tab fits next to the partner.
  ///
  /// Otherwise the pair ends once [oldTabId] is gone: right away if its
  /// removal already arrived (and was ignored as pending), else when it does.
  Future<void> _settleReplacement(
    String pairId,
    String oldTabId,
    String? newTabId,
  ) async {
    // A re-pair or end in the meantime wins.
    final pair = _pairHolding(pairId, oldTabId);
    if (pair == null) return;

    if (newTabId != null) {
      final partner = pair.partnerOf(oldTabId)!;
      final samePrivacy =
          newTabId != partner && await _samePrivacy(newTabId, partner);
      if (!ref.mounted) return;

      final latest = _pairHolding(pairId, oldTabId);
      if (latest == null) return;
      if (latest.partnerOf(oldTabId) != partner) {
        // The partner changed during the wait (that keeps the pair): check
        // the new tab against the new partner instead.
        return await _settleReplacement(pairId, oldTabId, newTabId);
      }

      // A replacement that closed during the wait still answers the privacy
      // check from its retained state, but its removal has already passed the
      // reconciliation: moving it in would leave a pair native no longer
      // shows.
      if (samePrivacy && _isLive(newTabId)) {
        state = latest.withMemberReplaced(oldTabId, newTabId);
        return;
      }
    }

    logger.w('Split view member $oldTabId was not replaced');
    if (!ref.read(tabListProvider).value.contains(oldTabId)) {
      state = null;
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// After a wait in [pair]: false when the controller was disposed (the
  /// request is dropped silently); throws [SplitViewErrorKind.superseded]
  /// when a newer request or [end] came in.
  bool _isCurrent(int generation) {
    if (!ref.mounted) return false;
    if (generation != _pairingGeneration) {
      throw const SplitViewError(SplitViewErrorKind.superseded);
    }
    return true;
  }

  /// The pair [pair] forms for [first] and [second]. See [pair].
  SplitPair _nextPair(String first, String second, SplitPair? arrangement) {
    final current = state;

    if (arrangement != null) {
      return _newPair(
        first,
        second,
        layout: arrangement.layout,
        sideBySideRatio: arrangement.sideBySideRatio,
        stackedRatio: arrangement.stackedRatio,
      );
    }
    if (current != null && current.contains(first)) {
      return current.withPartner(first, second).withBothPagesShown();
    }
    return _newPair(first, second);
  }

  /// Applies [change] to the pair; does nothing while there is none.
  void _updatePair(SplitPair Function(SplitPair pair) change) {
    final pair = state;
    if (pair != null) state = change(pair);
  }

  /// The pair, if it is still the one with [pairId].
  SplitPair? _pairWithId(String pairId) {
    final pair = state;
    return pair?.pairId == pairId ? pair : null;
  }

  /// The pair, if it is still the one with [pairId] and still holds [tabId].
  ///
  /// Only identity and membership count: a layout or ratio change during a
  /// wait is no reason to drop a replacement (that would leave a closed tab
  /// in the pair, its removal having been ignored as pending).
  SplitPair? _pairHolding(String pairId, String tabId) {
    final pair = _pairWithId(pairId);
    return pair != null && pair.contains(tabId) ? pair : null;
  }

  /// Whether [tabId] is open: it has state, and not state retained for a
  /// while after the tab closed.
  bool _isLive(String tabId) =>
      ref.read(tabStatesProvider).containsKey(tabId) &&
      !ref.read(tabStatesProvider.notifier).isClosed(tabId);

  /// Whether [a] and [b] both have content state and share a privacy mode.
  Future<bool> _samePrivacy(String a, String b) async {
    final [stateA, stateB] = await _awaitContentStates(a, b);
    return stateA != null &&
        stateB != null &&
        canShareSplit(stateA.tabMode, stateB.tabMode);
  }

  /// The content states of [a] and [b]; null for a tab that did not arrive
  /// in time.
  Future<List<TabState?>> _awaitContentStates(String a, String b) {
    final tabStates = ref.read(tabStatesProvider.notifier);
    return Future.wait([
      tabStates.awaitContentState(a, timeout: _newTabArrival),
      tabStates.awaitContentState(b, timeout: _newTabArrival),
    ]);
  }

  /// Whether the routing of both [a] and [b] is installed.
  Future<bool> _ensureRoutingReady(String a, String b) async {
    final tabs = ref.read(tabRepositoryProvider.notifier);
    final ready = await Future.wait([
      tabs.ensureRoutingReady(a),
      tabs.ensureRoutingReady(b),
    ]);
    return !ready.contains(false);
  }
}

SplitPair _newPair(
  String first,
  String second, {
  SplitLayoutPreference layout = SplitLayoutPreference.automatic,
  double sideBySideRatio = 0.5,
  double stackedRatio = 0.5,
}) => SplitPair(
  pairId: const Uuid().v4(),
  firstTabId: first,
  secondTabId: second,
  layout: layout,
  sideBySideRatio: sideBySideRatio,
  stackedRatio: stackedRatio,
);

extension on SplitPair {
  /// The members trade slots; each keeps its size.
  SplitPair swapped() => copyWith(
    firstTabId: secondTabId,
    secondTabId: firstTabId,
    sideBySideRatio: 1 - sideBySideRatio,
    stackedRatio: 1 - stackedRatio,
  );

  /// This pair with [partner] next to [member], which keeps its slot.
  /// Unchanged when [partner] is in the pair already.
  SplitPair withPartner(String member, String partner) {
    if (contains(partner)) return this;
    return firstTabId == member
        ? copyWith(secondTabId: partner)
        : copyWith(firstTabId: partner);
  }

  /// This pair with [newTabId] in [oldTabId]'s slot.
  SplitPair withMemberReplaced(String oldTabId, String newTabId) =>
      firstTabId == oldTabId
      ? copyWith(firstTabId: newTabId)
      : copyWith(secondTabId: newTabId);

  /// This pair with "Show only this page" off; the same instance when it
  /// already is.
  SplitPair withBothPagesShown() =>
      focusedOnly ? copyWith(focusedOnly: false) : this;
}

// -----------------------------------------------------------------------------
// Providers
// -----------------------------------------------------------------------------

/// Ends the pair when one of its tabs is closed. Started with the browser
/// (`SplitViewHost`), the only place a pair can be formed.
@Riverpod(keepAlive: true)
void splitViewReconciliation(Ref ref) {
  ref.listen(tabListProvider, (previous, next) {
    ref
        .read(splitViewControllerProvider.notifier)
        .onTabListChanged(
          previous?.value.toSet() ?? const {},
          next.value.toSet(),
        );
  });
}

/// The pair while split view is shown, whatever is selected; else null.
@Riverpod(keepAlive: true)
SplitPair? splitPairShown(Ref ref) {
  final pair = ref.watch(splitViewControllerProvider);
  // Settings are only read once there is a pair, so a tab tile or badge
  // without one depends on nothing else.
  if (pair == null) return null;

  final shown = ref.watch(
    generalSettingsWithDefaultsProvider.select(
      (settings) => settings.isFeatureShown(FeatureId.tabsSplitView),
    ),
  );
  return shown ? pair : null;
}

/// The shown pair while it contains the selected tab; else null, and the
/// browser shows one page as usual.
@Riverpod()
SplitPair? activeSplitPair(Ref ref) {
  final pair = ref.watch(splitPairShownProvider);
  // The selection is only read once there is a pair, so a widget that only
  // shows membership (the tab button's badge, also drawn in the layout
  // preview) reads nothing that starts the engine.
  if (pair == null) return null;

  final selected = ref.watch(selectedTabProvider);
  return selected != null && pair.contains(selected) ? pair : null;
}

/// Whether [tabId] belongs to the shown pair, for badges.
@Riverpod()
bool isSplitMember(Ref ref, String tabId) => ref.watch(
  splitPairShownProvider.select((pair) => pair?.contains(tabId) ?? false),
);

/// The containers of both members of the shown pair (null: unassigned).
///
/// Depends on the members only, not on which one is selected, so it does not
/// reload when focus moves between the panes: the home predicate reads it in
/// exactly that moment.
@Riverpod()
Future<Set<String?>> splitPairContainerIds(Ref ref) async {
  // Only the members: a layout or ratio change changes nothing here.
  final members = ref.watch(
    splitPairShownProvider.select(
      (pair) => pair == null
          ? null
          : (first: pair.firstTabId, second: pair.secondTabId),
    ),
  );
  if (members == null) return const {};

  final first = ref.watch(watchContainerTabIdProvider(members.first).future);
  final second = ref.watch(watchContainerTabIdProvider(members.second).future);
  return {await first, await second};
}
