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
import 'dart:io';

import 'package:exceptions/exceptions.dart';
import 'package:http/http.dart';

/// Why an HTTP call failed.
///
/// Travels in [ErrorMessage.details] so the UI can translate it when it shows
/// the error (`describeError`); [message] is the English diagnostic text that
/// lands in [ErrorMessage.message] and the logs.
enum HttpFailure {
  socket('Could not contact remote service'),
  http('Web request returned error'),
  format('Bad response format'),
  client('Could not contact remote service');

  const HttpFailure(this.message);

  final String message;
}

/// `ExceptionHandler` for HTTP-backed [Result]s. Deliberately free of
/// localization: it runs deep in data services with no `BuildContext` or
/// `Ref`, and the error may be shown long after, in whatever language the UI
/// is in by then.
ErrorMessage handleHttpError(Exception exception, StackTrace stackTrace) {
  final failure = switch (exception) {
    SocketException() => HttpFailure.socket,
    HttpException() => HttpFailure.http,
    FormatException() => HttpFailure.format,
    ClientException() => HttpFailure.client,
    _ => null,
  };

  if (failure == null) {
    return ErrorMessage.fromException(exception, stackTrace);
  }

  return ErrorMessage(
    source: 'http',
    message: failure.message,
    details: failure,
    stackTrace: stackTrace,
  );
}
