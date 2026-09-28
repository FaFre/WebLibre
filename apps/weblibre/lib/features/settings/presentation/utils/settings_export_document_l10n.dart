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
import 'package:weblibre/features/settings/domain/entities/settings_export_document.dart';
import 'package:weblibre/features/settings/domain/services/settings_transfer_service.dart';
import 'package:weblibre/features/settings/presentation/utils/settings_transfer_service_l10n.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

extension SettingsExportFormatExceptionL10n on SettingsExportFormatException {
  String describe(AppLocalizations l10n) {
    final section = _sectionLabel(l10n);

    return switch (kind) {
      SettingsExportFormatErrorKind.notJson => l10n.settings_importErrorNotJson,
      SettingsExportFormatErrorKind.notSettingsExport =>
        l10n.settings_importErrorNotSettingsExport,
      SettingsExportFormatErrorKind.missingFormatVersion =>
        l10n.settings_importErrorMissingFormatVersion,
      SettingsExportFormatErrorKind.newerFormatVersion =>
        l10n.settings_importErrorNewerFormatVersion(
          version ?? 0,
          supportedVersion ?? 0,
        ),
      SettingsExportFormatErrorKind.noSettings =>
        l10n.settings_importErrorNoSettings,
      SettingsExportFormatErrorKind.malformedSection =>
        l10n.settings_importErrorMalformedSection(section),
      SettingsExportFormatErrorKind.malformedField =>
        l10n.settings_importErrorMalformedField(field ?? ''),
      SettingsExportFormatErrorKind.unreadablePrefsLine =>
        l10n.settings_importErrorUnreadablePrefsLine(section, line ?? ''),
      SettingsExportFormatErrorKind.notPrefsSnapshot =>
        l10n.settings_importErrorNotPrefsSnapshot(section),
      SettingsExportFormatErrorKind.missingSchemaVersion =>
        l10n.settings_importErrorMissingSchemaVersion(section),
      SettingsExportFormatErrorKind.unreadablePref =>
        l10n.settings_importErrorUnreadablePref(section, pref ?? ''),
      SettingsExportFormatErrorKind.newerSectionSchema =>
        l10n.settings_importErrorNewerSectionSchema(
          section,
          version ?? 0,
          supportedVersion ?? 0,
        ),
    };
  }

  /// A known section by its display name; a key this version does not know is
  /// shown as the file wrote it, since there is no name to translate. A null
  /// key comes from the Gecko preferences checks, which only that section runs.
  String _sectionLabel(AppLocalizations l10n) {
    final key = sectionKey;
    if (key == null) return SettingsTransferSection.geckoPrefs.label(l10n);

    return SettingsTransferSection.forKindValue(key)?.label(l10n) ?? key;
  }
}
