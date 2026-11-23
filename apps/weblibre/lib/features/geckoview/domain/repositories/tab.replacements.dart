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
part of 'tab.dart';

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
///
/// [closeOld] answers whether [oldTabId] went. It stays when it is locked,
/// which may have happened only after the caller decided to replace it: then
/// both tabs stay open, the new one beside the original ([OriginalKept]).
@visibleForTesting
Future<ReplacementResult> replaceTabOpeningFirst({
  required String oldTabId,
  required bool focused,
  required Future<String> Function() open,
  required Future<String?> Function() selectedTabId,
  required Future<bool> Function(String newTabId) closeOld,
  required Future<void> Function(String tabId) select,
  required bool Function() isMounted,
}) async {
  final newTabId = await open();
  if (!isMounted()) return TabReplaced(newTabId);

  final selectedMeanwhile =
      !focused && await selectedTabId() == oldTabId && isMounted();
  if (selectedMeanwhile) await select(newTabId);
  if (!isMounted()) return TabReplaced(newTabId);

  if (!await closeOld(newTabId)) return OriginalKept();
  if ((focused || selectedMeanwhile) && isMounted()) await select(newTabId);
  return TabReplaced(newTabId);
}
