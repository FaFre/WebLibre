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
import 'package:weblibre/features/app_update/domain/entities/update_state.dart';
import 'package:weblibre/features/app_update/presentation/utils/update_failure_l10n.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

extension UpdateStateL10n on UpdateState {
  /// The status card's headline (8.1).
  String headline(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final version = assessment?.appVersion;
    return switch (this) {
      UpdateIdle() => l10n.appUpdate_statusIdle,
      UpdateChecking() => l10n.appUpdate_statusChecking,
      UpdateUpToDate() => l10n.appUpdate_statusUpToDate,
      UpdateAvailable() =>
        version == null
            ? l10n.appUpdate_statusAvailableUnknownVersion
            : l10n.appUpdate_statusAvailable(version),
      UpdateDownloading() =>
        version == null
            ? l10n.appUpdate_statusDownloadingUnknownVersion
            : l10n.appUpdate_statusDownloading(version),
      UpdateVerifying() => l10n.appUpdate_statusVerifying,
      UpdateReadyToInstall() =>
        version == null
            ? l10n.appUpdate_statusReadyUnknownVersion
            : l10n.appUpdate_statusReady(version),
      UpdateAwaitingPermission() => l10n.appUpdate_statusAwaitingPermission,
      UpdateAwaitingUserAction() => l10n.appUpdate_statusAwaitingUserAction,
      UpdateInstalling() => l10n.appUpdate_statusInstalling,
      UpdateFailed(:final failure) => failure.describe(context),
    };
  }
}
