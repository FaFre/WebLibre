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
import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:flutter_tor/flutter_tor.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
Future<PackageInfo> packageInfo(Ref ref) async {
  return await PackageInfo.fromPlatform();
}

// The component versions are fixed for the life of the process, so each is
// read from native once and kept.

/// The versions are compiled into the app: a read that failed once fails every
/// time, and retrying would only keep the About dialog blank while it tries.
Duration? _noRetry(int retryCount, Object error) => null;

@Riverpod(keepAlive: true, retry: _noRetry)
Future<GeckoComponentVersions> geckoComponentVersions(Ref ref) async {
  return await GeckoBrowserService().getComponentVersions();
}

@Riverpod(keepAlive: true, retry: _noRetry)
Future<TorComponentVersions> torComponentVersions(Ref ref) async {
  return await FlutterTor().getComponentVersions();
}

/// Null when the bundled runtime carries no version stamp.
@Riverpod(keepAlive: true, retry: _noRetry)
Future<String?> singboxVersion(Ref ref) async {
  return await FlutterSingboxProxy().getVersion();
}
