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

import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Screen reader actions that move a tab one slot at a time, so the order can
/// be changed without dragging, as Fenix offers.
///
/// A list offers up and down; a grid also left and right, mirrored for
/// right-to-left layouts. Each move is the drag that would drop the tab in the
/// neighbouring slot: [onMove] receives the index the tab ends up at, counted
/// after it is taken out, which is what the trays' drop handlers expect.
class TabReorderSemantics extends StatelessWidget {
  /// The tab's position among the reorderable rows.
  final int index;

  /// How many rows can be reordered; the actions never move a tab past them.
  final int count;

  /// Tabs per row: 1 for a list, the column count for a grid.
  final int columns;

  /// Null while the order cannot be changed, which removes the actions.
  final Future<void> Function(int newIndex)? onMove;

  final Widget child;

  const TabReorderSemantics({
    super.key,
    required this.index,
    required this.count,
    required this.columns,
    required this.onMove,
    required this.child,
  });

  /// The index after moving [index] by [offset], or null when that leaves the
  /// rows.
  static int? targetIndex({
    required int index,
    required int count,
    required int offset,
  }) {
    final target = index + offset;
    return (offset == 0 || target < 0 || target >= count) ? null : target;
  }

  @override
  Widget build(BuildContext context) {
    final onMove = this.onMove;
    if (onMove == null) return child;

    final l10n = AppLocalizations.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final moves = <String, int>{
      l10n.browser_moveTabUp: -columns,
      l10n.browser_moveTabDown: columns,
      if (columns > 1) ...{
        l10n.browser_moveTabLeft: isRtl ? 1 : -1,
        l10n.browser_moveTabRight: isRtl ? -1 : 1,
      },
    };

    final actions = <CustomSemanticsAction, VoidCallback>{
      for (final MapEntry(key: label, value: offset) in moves.entries)
        if (targetIndex(index: index, count: count, offset: offset)
            case final target?)
          CustomSemanticsAction(label: label): () => unawaited(onMove(target)),
    };

    return Semantics(customSemanticsActions: actions, child: child);
  }
}
