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

import 'package:flutter/material.dart';
import 'package:weblibre/core/design/display_features.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/definitions.drift.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Dialog to select between extracted or full content for sharing.
/// Shows options for extracted (reader-optimized) vs full (complete) content.
Future<void> showContentSelectionDialog(
  BuildContext context, {
  required Widget title,
  required TabData tabData,
  required Future<void> Function(String content, String? fileName)
  shareMarkdownAction,
}) async {
  await showDialog(
    context: context,
    anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
    builder: (context) {
      final l10n = AppLocalizations.of(context);

      return SimpleDialog(
        title: title,
        children: [
          ListTile(
            title: Text(l10n.browser_contentSelectionExtractedTitle),
            subtitle: Text(l10n.browser_contentSelectionExtractedSubtitle),
            onTap: () async {
              Navigator.of(context).pop();
              await shareMarkdownAction(
                tabData.extractedContentMarkdown!,
                tabData.title ?? tabData.url?.authority,
              );
            },
          ),
          ListTile(
            title: Text(l10n.browser_contentSelectionFullTitle),
            subtitle: Text(l10n.browser_contentSelectionFullSubtitle),
            onTap: () async {
              Navigator.of(context).pop();
              await shareMarkdownAction(
                tabData.fullContentMarkdown!,
                tabData.title ?? tabData.url?.authority,
              );
            },
          ),
        ],
      );
    },
  );
}
