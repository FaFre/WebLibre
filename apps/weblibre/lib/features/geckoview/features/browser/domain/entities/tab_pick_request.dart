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

import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';

/// What the tab tray picks a tab for when it is shown as a picker
/// (`TabPickerSheet`): its title, which tabs it offers, and what a pick or a
/// new tab does.
///
/// The tray then keeps the container and the tab-type filter it shows to
/// itself, so picking never switches the browser's container or changes the
/// tray's saved filter.
class TabPickRequest {
  /// Shown at the top of the tray in place of its actions.
  final String title;

  /// Offers only private tabs when true, and only non-private ones otherwise.
  final bool privateTabs;

  /// Tabs never offered (the tabs the pick is for).
  final Set<String> excludedTabIds;

  /// The container the picker opens in (null for tabs without one).
  final ContainerData? initialContainer;

  /// Called with the tab picked. The picker is closed by then.
  final void Function(String tabId) onPicked;

  /// The tray's new-tab button. The picker is closed by then.
  final void Function() onNewTab;

  const TabPickRequest({
    required this.title,
    required this.privateTabs,
    required this.excludedTabIds,
    required this.initialContainer,
    required this.onPicked,
    required this.onNewTab,
  });
}
