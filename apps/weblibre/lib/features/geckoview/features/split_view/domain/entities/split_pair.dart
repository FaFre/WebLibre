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
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';

part 'split_pair.g.dart';

/// How the user wants a pair arranged. The resolved mode can differ when the
/// window is too small for it (see `resolveSplitPresentation`); this never
/// changes because of that.
enum SplitLayoutPreference {
  /// Side by side in a landscape content area, stacked in a portrait one.
  automatic,
  sideBySide,
  stacked,
}

/// Whether tabs of modes [a] and [b] can be shown together: both private or
/// neither. An unknown mode counts as not private.
bool canShareSplit(TabMode? a, TabMode? b) =>
    (a is PrivateTabMode) == (b is PrivateTabMode);

/// The axis a divider ratio belongs to. Each axis keeps its own ratio.
enum SplitRatioAxis { sideBySide, stacked }

/// Two ordinary tabs shown together. Presentation only: pairing changes no
/// container, context, route, privacy mode, parent, pin or tab order.
///
/// There is at most one pair, held in memory for the app session.
@CopyWith()
class SplitPair with FastEquatable {
  /// New for every pair that is formed, so stale native events (a divider
  /// released after the pair was replaced) can be recognized.
  @CopyWithField(immutable: true)
  final String pairId;

  /// The tab in the left or top slot.
  final String firstTabId;

  /// The tab in the right or bottom slot.
  final String secondTabId;

  final SplitLayoutPreference layout;

  /// The first pane's share of the width when side by side.
  final double sideBySideRatio;

  /// The first pane's share of the height when stacked.
  final double stackedRatio;

  /// "Show only this page": the focused page fills the browser and the other
  /// stays loaded behind it.
  final bool focusedOnly;

  SplitPair({
    required this.pairId,
    required this.firstTabId,
    required this.secondTabId,
    this.layout = SplitLayoutPreference.automatic,
    this.sideBySideRatio = 0.5,
    this.stackedRatio = 0.5,
    this.focusedOnly = false,
  });

  bool contains(String tabId) => tabId == firstTabId || tabId == secondTabId;

  /// The other member, or null when [tabId] is not in this pair.
  String? partnerOf(String tabId) {
    if (tabId == firstTabId) return secondTabId;
    if (tabId == secondTabId) return firstTabId;
    return null;
  }

  double ratioFor(SplitRatioAxis axis) => switch (axis) {
    SplitRatioAxis.sideBySide => sideBySideRatio,
    SplitRatioAxis.stacked => stackedRatio,
  };

  @override
  List<Object?> get hashParameters => [
    pairId,
    firstTabId,
    secondTabId,
    layout,
    sideBySideRatio,
    stackedRatio,
    focusedOnly,
  ];
}

/// Why a pair could not be formed.
enum SplitViewErrorKind {
  /// Both sides are the same tab.
  sameTab,

  /// One of the tabs does not exist (any more).
  missingTab,

  /// A private tab next to a non-private one. The secure-window flag is
  /// window-wide, so it could not be right for both.
  mixedPrivacy,

  /// A proxied container's routing is not installed yet.
  routingNotReady,

  /// Native did not take the pair (the push to it failed).
  notApplied,

  /// A newer pairing request, or ending the split, came first while this one
  /// waited. Not an error to show: the newer request decides.
  superseded,
}

class SplitViewError implements Exception {
  final SplitViewErrorKind kind;

  const SplitViewError(this.kind);

  @override
  String toString() => 'SplitViewError(${kind.name})';
}
