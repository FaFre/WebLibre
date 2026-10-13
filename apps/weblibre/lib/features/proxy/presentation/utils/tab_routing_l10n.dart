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
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/features/proxy/domain/services/tab_routing.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// How a tab's routing reads, shared by the browser menu's connection group
/// and the site information sheet so the two never describe the same tab
/// differently.
extension TabRoutingL10n on TabRouting {
  /// One-line answer to "where is this tab's traffic going".
  String describe(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (isContextMismatch) {
      return switch (containerName) {
        final container? => l10n.proxy_tabNotRoutedByContainer(container),
        null => l10n.proxy_tabNotRoutedByTabContainer,
      };
    }

    return switch (status) {
      TabRoutingStatus.unknown => l10n.proxy_tabRoutingChecking,
      TabRoutingStatus.pending => l10n.proxy_tabRoutingStarting,
      TabRoutingStatus.blocked => l10n.proxy_tabRoutingBlockedNotRunning(
        proxyTitle!,
      ),
      TabRoutingStatus.active => l10n.proxy_tabRoutingVia(proxyTitle!),
      TabRoutingStatus.direct => l10n.proxy_tabRoutingDirect,
    };
  }

  /// Whether [describe] reports a problem: traffic blocked, or a container
  /// route that does not reach the tab.
  bool get isRoutingProblem =>
      status == TabRoutingStatus.blocked || isContextMismatch;

  /// The icon for this routing state, and its color when it is not the
  /// default one.
  (IconData, Color?) statusIcon(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return switch (status) {
      // A container that names a proxy while its own tab connects directly is
      // a misconfiguration nothing else in the browser reports.
      _ when isContextMismatch => (
        MdiIcons.shieldAlertOutline,
        colorScheme.error,
      ),
      TabRoutingStatus.active => (
        MdiIcons.shieldCheck,
        AppColors.of(context).torActiveGreen,
      ),
      TabRoutingStatus.blocked => (MdiIcons.shieldOff, colorScheme.error),
      TabRoutingStatus.pending => (MdiIcons.shieldSync, null),
      TabRoutingStatus.unknown => (MdiIcons.shieldOutline, null),
      // Keeps the header clear of glyphs that read as arrows next to the text.
      TabRoutingStatus.direct => (Icons.public, null),
    };
  }
}
