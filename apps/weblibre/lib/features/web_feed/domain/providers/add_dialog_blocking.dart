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
import 'package:nullability/nullability.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';

part 'add_dialog_blocking.g.dart';

@Riverpod(keepAlive: true)
class AddFeedDialogBlocking extends _$AddFeedDialogBlocking {
  DateTime? _lastIgnore;
  final _ignoredUrls = <Uri, DateTime>{};

  void ignore(Uri url) {
    final date = DateTime.now();

    _lastIgnore = date;
    _ignoredUrls[url] = date;
  }

  bool canPush(Uri url) {
    if (_lastIgnore.mapNotNull(
          (last) =>
              DateTime.now().difference(last) <= const Duration(seconds: 30),
        ) ??
        false) {
      logger.i('Blocking add feed default timeout for $url');
      return false;
    }

    if (_ignoredUrls[url].mapNotNull(
          (last) =>
              DateTime.now().difference(last) <= const Duration(minutes: 5),
        ) ??
        false) {
      logger.i('Blocking add feed url specific for $url');
      return false;
    }

    return true;
  }

  @override
  void build() {}
}
