/*
 * Copyright (c) 2024-2025 Fabian Freund.
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

ErrorMessage handleHttpError(Exception exception, StackTrace stackTrace) {
  return switch (exception) {
    SocketException() => const ErrorMessage(
      source: 'http',
      message: 'Could not contact remote service',
    ),
    HttpException() => const ErrorMessage(
      source: 'http',
      message: 'Web request returned error',
    ),
    FormatException() => const ErrorMessage(
      source: 'http',
      message: 'Bad response format',
    ),
    ClientException() => const ErrorMessage(
      source: 'http',
      message: 'Could not contact remote service',
    ),
    _ => ErrorMessage.fromException(exception, stackTrace),
  };
}
