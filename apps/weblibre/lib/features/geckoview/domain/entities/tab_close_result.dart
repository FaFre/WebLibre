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
import 'package:fast_equatable/fast_equatable.dart';

/// What a close did to the tabs it was asked to close.
///
/// A tab in none of the lists is still open although nothing protected it:
/// the engine refused its removal for another reason. Callers that must know
/// every tab is gone (deleting a container) count it as a survivor.
class CloseResult with FastEquatable {
  /// Open before the close, gone after it.
  final List<String> removedTabIds;

  /// Kept because they are locked, in the database or natively.
  final List<String> skippedLockedTabIds;

  /// Not open when the close began.
  final List<String> missingTabIds;

  /// Nothing was done because native's tab locks could not be read: without
  /// them nothing says which of the tabs may close.
  final bool locksUnavailable;

  CloseResult({
    this.removedTabIds = const [],
    this.skippedLockedTabIds = const [],
    this.missingTabIds = const [],
    this.locksUnavailable = false,
  });

  /// A close of nothing.
  static final none = CloseResult();

  /// Whether anything was closed, which is what an Undo would bring back.
  bool get closedAny => removedTabIds.isNotEmpty;

  /// Whether [tabId] is gone: closed by this call, or not open to begin with.
  bool isGone(String tabId) =>
      removedTabIds.contains(tabId) || missingTabIds.contains(tabId);

  @override
  List<Object?> get hashParameters => [
    removedTabIds,
    skippedLockedTabIds,
    missingTabIds,
    locksUnavailable,
  ];
}

/// What an undo of the last close did.
enum UndoCloseOutcome {
  /// The tabs it closed are back.
  reopened,

  /// The engine had nothing left to undo.
  nothingToUndo,

  /// Not undone, though there may be something to undo: a container is
  /// being deleted, a tab would come back into a frozen container in
  /// storage its freeze does not hold or into storage whose data waits to
  /// be deleted (the user is told so), or tabs kept closing while the undo
  /// was checked.
  refused,
}
