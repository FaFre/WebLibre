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
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/utils/close_tab_helper.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/controllers/website_title.dart';
import 'package:weblibre/utils/ui_helper.dart';

/// Looks for the feeds page [tabId] links to and lets the user pick which to
/// follow — the menu's "Fetch feeds on page" in one step, for callers without
/// a menu row to show progress in.
///
/// The page is fetched along [tabId]'s own route, so a tab in a proxied
/// container never has its page requested through another tab's connection.
Future<void> subscribeToPageFeedsUsing(
  BuildContext context,
  ProviderRead read, {
  required String tabId,
}) async {
  final l10n = AppLocalizations.of(context);
  final tabState = read(tabStateProvider(tabId));
  if (tabState == null) return;

  showInfoMessage(context, l10n.menu_fetchFeedsLoading);

  Set<Uri> feeds;
  try {
    final pageInfo = await read(
      pageInfoProvider(
        tabState.url,
        isImageRequest: false,
        tabId: tabId,
      ).future,
    );
    feeds = pageInfo.feeds ?? const {};
  } catch (error, stackTrace) {
    logger.w(
      'Could not fetch the page to look for feeds',
      error: error,
      stackTrace: stackTrace,
    );
    feeds = const {};
  }

  if (!context.mounted) return;

  if (feeds.isEmpty) {
    showInfoMessage(context, l10n.menu_fetchFeedsNone);
    return;
  }

  await SelectFeedDialogRoute(
    feedsJson: jsonEncode([for (final feed in feeds) feed.toString()]),
  ).push(context);
}
