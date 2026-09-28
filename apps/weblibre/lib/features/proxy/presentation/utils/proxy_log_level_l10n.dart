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
import 'package:weblibre/features/user/data/models/proxy_diagnostics_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Display label/description for [ProxyLogLevel] (sing-box's own log
/// verbosity). Not [ProxyLogSeverity]'s filter labels in
/// `proxy_log_severity_l10n.dart` — that is the log *viewer*'s filter over
/// already-emitted lines; this is the setting that controls how much sing-box
/// emits in the first place.
extension ProxyLogLevelL10n on ProxyLogLevel {
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return switch (this) {
      ProxyLogLevel.warn => l10n.proxy_logVerbosityWarnLabel,
      ProxyLogLevel.info => l10n.proxy_logVerbosityInfoLabel,
      ProxyLogLevel.debug => l10n.proxy_logVerbosityDebugLabel,
      ProxyLogLevel.trace => l10n.proxy_logVerbosityTraceLabel,
    };
  }

  String description(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return switch (this) {
      ProxyLogLevel.warn => l10n.proxy_logVerbosityWarnDescription,
      ProxyLogLevel.info => l10n.proxy_logVerbosityInfoDescription,
      ProxyLogLevel.debug => l10n.proxy_logVerbosityDebugDescription,
      ProxyLogLevel.trace => l10n.proxy_logVerbosityTraceDescription,
    };
  }

  /// Whole-sentence status of what the log is recording, warning when the
  /// level slows browsing ([ProxyLogLevelX.isVerbose]).
  String recordingSummary(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return switch (this) {
      ProxyLogLevel.warn => l10n.proxy_recordingLevelWarn,
      ProxyLogLevel.info => l10n.proxy_recordingLevelInfo,
      ProxyLogLevel.debug => l10n.proxy_recordingLevelDebug,
      ProxyLogLevel.trace => l10n.proxy_recordingLevelTrace,
    };
  }
}
