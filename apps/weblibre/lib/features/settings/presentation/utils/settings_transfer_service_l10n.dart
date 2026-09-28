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
import 'package:weblibre/core/branding/proxy_brands.dart';
import 'package:weblibre/features/settings/domain/services/settings_transfer_service.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/utils/error_l10n.dart';

/// Display names for [SettingsTransferSection]. Take [AppLocalizations]
/// rather than a context because error sentences embed them too.
extension SettingsTransferSectionL10n on SettingsTransferSection {
  String label(AppLocalizations l10n) => switch (this) {
    SettingsTransferSection.settings =>
      l10n.settings_transferSectionAppSettingsTitle,
    SettingsTransferSection.geckoPrefs =>
      l10n.settings_transferSectionGeckoPrefsTitle,
  };

  String description(AppLocalizations l10n) => switch (this) {
    SettingsTransferSection.settings =>
      l10n.settings_transferSectionAppSettingsDescription(torBrand),
    SettingsTransferSection.geckoPrefs =>
      l10n.settings_transferSectionGeckoPrefsDescription,
  };
}

extension SettingsImportPartialFailureL10n on SettingsImportPartialFailure {
  String describe(AppLocalizations l10n) {
    final error = describeError(l10n, cause);
    final failedLabel = failed.label(l10n);

    if (applied.isEmpty) {
      return l10n.settings_importPartialFailure(failedLabel, error);
    }

    return l10n.settings_importPartialFailureAfterApplied(
      applied.map((section) => section.label(l10n)).join(', '),
      failedLabel,
      error,
    );
  }
}
