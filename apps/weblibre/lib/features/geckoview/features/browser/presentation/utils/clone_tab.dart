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
import 'package:flutter/widgets.dart';
import 'package:weblibre/core/providers/provider_read.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_container_selection.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart'
    as tab_data;
import 'package:weblibre/features/geckoview/features/tabs/presentation/utils/container_actions.dart';
import 'package:weblibre/features/web_search/domain/controllers/sandbox_capture_controller.dart';

/// Opens a copy of [tabId] as a [mode] tab, in the background and in the
/// container a copy goes to: a duplicate when the tab has that mode already,
/// otherwise its page in a new tab. A sandbox-captured tab's page is its
/// source URL, so the copy re-captures or loads the real site, never the
/// loopback loader. Returns the new tab, or null when the container refused
/// it, which it says ([openUnlessContainerRefuses]).
Future<String?> cloneTabAs(
  BuildContext context,
  ProviderRead read,
  String tabId,
  TabMode mode,
) async {
  final tabState = read(tabStateProvider(tabId));
  if (tabState == null) return null;
  final cloneUrl =
      read(sandboxSourceUriForTabProvider(tabId: tabId)) ?? tabState.url;
  final duplicate = switch (mode) {
    RegularTabMode() => tabState.tabMode is RegularTabMode,
    PrivateTabMode() => tabState.tabMode is PrivateTabMode,
    IsolatedTabMode() => false,
  };

  return await openUnlessContainerRefuses(context, () async {
    final containerData = await read(
      tab_data.tabDataRepositoryProvider.notifier,
    ).getContainerForCopy(tabId);
    final repository = read(tabRepositoryProvider.notifier);
    return duplicate
        ? await repository.duplicateTab(
            selectTabId: tabId,
            containerData: containerData,
            selectTab: false,
          )
        : await repository.addTab(
            url: cloneUrl,
            tabMode: mode,
            containerSelection: containerData == null
                ? const TabContainerSelection.unassigned()
                : TabContainerSelection.specific(containerData),
            selectTab: false,
          );
  });
}
