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
import 'package:weblibre/features/geckoview/domain/providers/tab_detail_state.dart';
import 'package:weblibre/features/geckoview/features/find_in_page/domain/entities/find_in_page_state.dart';
import 'package:weblibre/features/geckoview/features/find_in_page/presentation/controllers/find_in_page.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

/// Offers to locate [query] within [tabId]'s page instead of opening Find in
/// Page unprompted (#421), for a tab opened from a search result: only for a
/// non-empty query while the tab's find bar is hidden, and not for an asleep
/// tab, which selecting does not wake (D10), so there is no page to search.
void offerFindInPage(
  BuildContext context,
  ProviderRead read, {
  required String tabId,
  required String? query,
}) {
  if (query == null || query.isEmpty) return;
  if (read(isTabAsleepProvider(tabId))) return;
  if (read(findInPageControllerProvider(tabId)) != FindInPageState.hidden()) {
    return;
  }

  final findController = read(findInPageControllerProvider(tabId).notifier);
  ui_helper.showFindInPageSuggestion(
    context,
    query: query,
    onFind: () => findController.findAll(text: query),
  );
}
