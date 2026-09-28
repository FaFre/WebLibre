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
import 'package:exceptions/exceptions.dart';
import 'package:weblibre/core/http_error_handler.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Display text for an error handed to the UI as a raw object (an
/// `AsyncValue` error, a failed [Result]).
///
/// Structured failures are translated here, at display time, so they follow
/// the UI language even when they were produced long before. Any other
/// [ErrorMessage] shows its own message — the text the failing code chose to
/// report — or a generic sentence when it has none. Objects outside the
/// [Result] world are named by their type rather than their `toString`, which
/// is diagnostic text that may carry response bodies or other internals.
String describeError(AppLocalizations l10n, Object error) => switch (error) {
  final String text => text,
  ResultException(:final errorMessage) => describeError(l10n, errorMessage),
  ErrorMessage(details: final HttpFailure failure) => failure.describe(l10n),
  ErrorMessage(:final message) =>
    message.trim().isEmpty ? l10n.failureWidget_unknownError : message,
  _ => error.runtimeType.toString(),
};

extension HttpFailureL10n on HttpFailure {
  String describe(AppLocalizations l10n) => switch (this) {
    HttpFailure.socket => l10n.httpErrorHandler_socketError,
    HttpFailure.http => l10n.httpErrorHandler_httpError,
    HttpFailure.format => l10n.httpErrorHandler_formatError,
    HttpFailure.client => l10n.httpErrorHandler_clientError,
  };
}
