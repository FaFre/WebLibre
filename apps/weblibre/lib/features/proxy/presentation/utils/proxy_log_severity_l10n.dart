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
import 'package:weblibre/features/proxy/data/models/proxy_log_message.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Filter-chip labels for [ProxyLogSeverity].
extension ProxyLogSeverityL10n on ProxyLogSeverity {
  /// Label for the viewer's filter. Plural because it selects a range: picking
  /// [ProxyLogSeverity.warn] shows warnings *and* everything worse.
  String filterLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return switch (this) {
      ProxyLogSeverity.trace => l10n.proxy_logLevelTrace,
      ProxyLogSeverity.debug => l10n.proxy_logLevelDebug,
      ProxyLogSeverity.info => l10n.proxy_logLevelInfo,
      ProxyLogSeverity.warn => l10n.proxy_logLevelWarnings,
      ProxyLogSeverity.error => l10n.proxy_logLevelErrors,
    };
  }

  /// Screen-reader label for the filter chip, spelling out the range.
  String filterSemanticsLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return switch (this) {
      ProxyLogSeverity.trace => l10n.proxy_logsShowTraceAndAbove,
      ProxyLogSeverity.debug => l10n.proxy_logsShowDebugAndAbove,
      ProxyLogSeverity.info => l10n.proxy_logsShowInfoAndAbove,
      ProxyLogSeverity.warn => l10n.proxy_logsShowWarningsAndAbove,
      ProxyLogSeverity.error => l10n.proxy_logsShowErrorsOnly,
    };
  }
}
