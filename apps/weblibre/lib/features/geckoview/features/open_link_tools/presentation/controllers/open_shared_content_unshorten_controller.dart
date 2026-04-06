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
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/domain/entities/unshorten_result.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/domain/services/url_unshortener_service.dart';

part 'open_shared_content_unshorten_controller.g.dart';

@Riverpod()
class OpenSharedContentUnshortenController
    extends _$OpenSharedContentUnshortenController {
  @override
  AsyncValue<UnshortenResult>? build() {
    return null;
  }

  Future<UnshortenResult?> unshorten({
    required String url,
    required String token,
  }) async {
    state = const AsyncLoading();

    try {
      final result = await ref
          .read(urlUnshortenerServiceProvider.notifier)
          .unshortenUrl(url, token: token);

      state = AsyncData(result);
      return result;
    } catch (e, s) {
      state = AsyncError(e, s);
      return null;
    }
  }
}
