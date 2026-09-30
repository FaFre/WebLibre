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

/// One chip of the tab groups row: a root tab and every tab below it in the
/// tab tree, flattened in the order the tab bar draws them.
///
/// A tab nobody opened anything from is a group of one, and renders as an
/// ordinary tab chip.
class QuickTabSwitcherTabGroup with FastEquatable {
  /// The tree's root, first in [tabIds]. Identifies the group, and supplies
  /// the chip's icon and title, which therefore stay put while the user moves
  /// between the group's tabs.
  final String rootId;

  /// The root followed by its descendants.
  final List<String> tabIds;

  /// The member selected most recently: tapping the group returns to it.
  final String lastUsedTabId;

  QuickTabSwitcherTabGroup({
    required this.rootId,
    required this.tabIds,
    required this.lastUsedTabId,
  });

  bool get isGroup => tabIds.length > 1;

  @override
  List<Object?> get hashParameters => [rootId, tabIds, lastUsedTabId];
}
