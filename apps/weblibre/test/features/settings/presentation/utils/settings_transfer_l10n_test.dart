import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/settings/domain/entities/settings_export_document.dart';
import 'package:weblibre/features/settings/domain/services/settings_transfer_service.dart';
import 'package:weblibre/features/settings/presentation/utils/settings_export_document_l10n.dart';
import 'package:weblibre/features/settings/presentation/utils/settings_transfer_service_l10n.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('de'));

  group('SettingsExportFormatException.describe', () {
    test('translates a parse failure instead of its diagnostic text', () {
      final error = decodeFailure('not json at all');

      expect(error.describe(l10n), l10n.settings_importErrorNotJson);
      expect(error.message, 'This is not a JSON file.');
    });

    test('names a known section by its translated label', () {
      const error = SettingsExportFormatException(
        SettingsExportFormatErrorKind.malformedSection,
        sectionKey: 'weblibre_settings',
      );

      expect(
        error.describe(l10n),
        l10n.settings_importErrorMalformedSection(
          l10n.settings_transferSectionAppSettingsTitle,
        ),
      );
    });

    test('shows a key this version does not know as the file wrote it', () {
      const error = SettingsExportFormatException(
        SettingsExportFormatErrorKind.malformedSection,
        sectionKey: 'future_section',
      );

      expect(
        error.describe(l10n),
        l10n.settings_importErrorMalformedSection('future_section'),
      );
    });

    test('names the Gecko preferences section when no key is given', () {
      expect(
        () => requireGeckoPrefsDocument('garbage'),
        throwsA(
          isA<SettingsExportFormatException>().having(
            (error) => error.describe(l10n),
            'describe',
            contains(l10n.settings_transferSectionGeckoPrefsTitle),
          ),
        ),
      );
    });

    test('carries both versions into the newer-format sentence', () {
      const error = SettingsExportFormatException(
        SettingsExportFormatErrorKind.newerFormatVersion,
        version: 9,
        supportedVersion: 2,
      );

      expect(
        error.describe(l10n),
        l10n.settings_importErrorNewerFormatVersion(9, 2),
      );
    });
  });

  group('SettingsImportPartialFailure.describe', () {
    test('names only the failed section when nothing was applied', () {
      const failure = SettingsImportPartialFailure(
        applied: [],
        failed: SettingsTransferSection.settings,
        cause: 'disk full',
      );

      expect(
        failure.describe(l10n),
        l10n.settings_importPartialFailure(
          l10n.settings_transferSectionAppSettingsTitle,
          'disk full',
        ),
      );
    });

    test('lists the applied sections before the failed one', () {
      const failure = SettingsImportPartialFailure(
        applied: [SettingsTransferSection.settings],
        failed: SettingsTransferSection.geckoPrefs,
        cause: 'disk full',
      );

      expect(
        failure.describe(l10n),
        l10n.settings_importPartialFailureAfterApplied(
          l10n.settings_transferSectionAppSettingsTitle,
          l10n.settings_transferSectionGeckoPrefsTitle,
          'disk full',
        ),
      );
    });
  });
}

SettingsExportFormatException decodeFailure(String text) {
  try {
    decodeSettingsExport(text);
  } on SettingsExportFormatException catch (error) {
    return error;
  }
  throw StateError('decodeSettingsExport accepted "$text"');
}
