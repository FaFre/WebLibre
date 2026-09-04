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

/// Which surface a computed tab order is meant for.
///
/// The tab tray and the always-on-screen surfaces (quick tab switcher, tab bar,
/// sequential navigation) render the *same* tabs in deliberately different
/// orders, and the difference is exactly the tray's own controls: the tab-type
/// and date filters, the title/URL/date sort, and which groups are collapsed.
/// Those live in the tray, are only adjustable there, and outlive it — the
/// filter options persist for a week and the collapsed set for the app session
/// — so letting them reach a surface the user is looking at while the tray is
/// closed makes that surface disagree with itself (issue #603).
///
/// Splitting the scope is what keeps them apart. It is a presentation
/// distinction only: both scopes group parents with their descendants and both
/// honour pinned-first, because those are structural preferences rather than
/// transient tray state.
enum TabListScope {
  /// The tray's list and grid views: every tray control applies, ordered by
  /// `tabListDirection`.
  tray,

  /// The quick tab switcher, the tab bar and sequential tab navigation: no
  /// filter, no collapse and no tray sort, ordered by `tabBarDirection`.
  ///
  /// Nothing is ever removed from this order, so a tab the user can see is a
  /// tab navigation can reach.
  presentation;

  bool get isTray => this == TabListScope.tray;
}
