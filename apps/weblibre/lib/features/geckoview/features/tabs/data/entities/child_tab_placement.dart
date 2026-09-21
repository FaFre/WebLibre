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

/// Where a tab opened from another tab is inserted in its container's order.
///
/// Only the position is chosen here; the parent relation is recorded either
/// way, so hierarchical views keep drawing the tab under its opener whichever
/// value is set — the choice is visible in the flat orders (the tab bar, the
/// non-hierarchical list).
enum ChildTabPlacement {
  /// Right behind the opener and the children it already has. The default,
  /// and what other browsers do by default too (Chrome groups opener-children
  /// after the opener, Firefox ships `browser.tabs.insertRelatedAfterCurrent`).
  afterParent,

  /// At the end of the container, like a tab opened from nowhere.
  endOfList,
}
