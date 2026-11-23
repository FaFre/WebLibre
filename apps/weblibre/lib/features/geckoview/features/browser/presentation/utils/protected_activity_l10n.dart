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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

extension ProtectedActivityL10n on ProtectedActivity {
  /// Why this activity kept a tab awake. Asked-about activity only refuses
  /// when it started again before the confirmed retry.
  String describeSleepRefusal(AppLocalizations l10n) => switch (this) {
    ProtectedActivity.recording => l10n.browser_sleepRefusedRecording,
    ProtectedActivity.formData => l10n.browser_sleepRefusedFormData,
    ProtectedActivity.upload => l10n.browser_sleepRefusedUpload,
    ProtectedActivity.printOrPdf => l10n.browser_sleepRefusedPrintOrPdf,
    // A tab's sleep never reports an unattributed download; only a container
    // freeze does.
    ProtectedActivity.download ||
    ProtectedActivity.unattributedDownload => l10n.browser_sleepRefusedDownload,
    ProtectedActivity.media ||
    ProtectedActivity.postResult => l10n.browser_sleepTabFailed,
  };

  /// Why this activity kept a container from freezing, in its blocker list.
  /// Asked-about activity is never listed there.
  String describeFreezeBlocker(AppLocalizations l10n) => switch (this) {
    ProtectedActivity.recording => l10n.browser_freezeBlockedRecording,
    ProtectedActivity.formData => l10n.browser_freezeBlockedFormData,
    ProtectedActivity.upload => l10n.browser_freezeBlockedUpload,
    ProtectedActivity.printOrPdf => l10n.browser_freezeBlockedPrintOrPdf,
    ProtectedActivity.download => l10n.browser_freezeBlockedDownload,
    ProtectedActivity.unattributedDownload =>
      l10n.browser_freezeBlockedUnattributedDownload,
    ProtectedActivity.media ||
    ProtectedActivity.postResult => l10n.browser_freezeFailedGeneric,
  };
}
