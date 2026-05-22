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
import 'package:logger/logger.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:search_client/search_client.dart';
import 'package:weblibre/features/search_credits/data/search_backend_config.dart';
import 'package:weblibre/features/search_credits/domain/providers/proxy_client.dart';
import 'package:weblibre/features/search_credits/domain/repositories/web_search_settings.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
BackendEndpoints searchBackendEndpoints(Ref ref) {
  final routeThroughTor = ref.watch(
    webSearchSettingsControllerProvider.select((s) => s.routeThroughTor),
  );
  return BackendEndpoints.fromOrigin(
    routeThroughTor ? searchBackendTorOriginUri : searchBackendOriginUri,
  );
}

@Riverpod(keepAlive: true)
Logger searchClientLogger(Ref ref) => Logger();

@Riverpod(keepAlive: true)
IssuanceClient issuanceClient(Ref ref) {
  return IssuanceClient(
    endpoints: ref.watch(searchBackendEndpointsProvider),
    logger: ref.watch(searchClientLoggerProvider),
    httpClient: ref.watch(searchProxyHttpClientProvider),
  );
}
