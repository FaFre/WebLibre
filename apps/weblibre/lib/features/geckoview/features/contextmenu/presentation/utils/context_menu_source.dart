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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_container_selection.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/split_view/presentation/utils/split_view_actions.dart';

/// The tab a context menu belongs to: the page it was opened in
/// ([sourceTabId], from the engine event). In split view this can be the
/// unfocused pane, so candidates read it instead of the selected tab.
///
/// Null when that tab is gone; never another tab in its place, whose page,
/// privacy or referrer would be wrong.
TabState? readContextMenuSourceTab(WidgetRef ref, String sourceTabId) =>
    ref.read(tabStateProvider(sourceTabId));

/// Where a tab opened from the context menu goes. The selected container, as
/// always, when the menu belongs to the selected tab; otherwise the source
/// tab's container (site assignment still wins), so a link from the other
/// split pane opens in that pane's container.
Future<TabContainerSelection> contextMenuContainerSelection(
  WidgetRef ref,
  String sourceTabId,
) async {
  if (sourceTabId == ref.read(selectedTabProvider)) {
    return const TabContainerSelection.useSelected();
  }
  return await splitPartnerContainerSelection(ref.read, sourceTabId);
}
