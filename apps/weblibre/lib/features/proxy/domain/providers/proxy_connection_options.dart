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
import 'package:fast_equatable/fast_equatable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/proxy/data/models/singbox_proxy_profile.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/extensions/singbox_proxy_profile_type_x.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_profiles.dart';

part 'proxy_connection_options.g.dart';

const loadingProxyTitle = 'Loading proxy...';
const unknownProxyTitle = 'Unknown proxy';

class ProxyConnectionOption with FastEquatable {
  final ProxyConnectionId id;
  final String title;
  final String subtitle;

  ProxyConnectionOption({
    required this.id,
    required this.title,
    required this.subtitle,
  });

  @override
  List<Object?> get hashParameters => [id, title, subtitle];
}

@Riverpod(keepAlive: true)
List<ProxyConnectionOption> proxyConnectionOptions(Ref ref) {
  final profilesAsync = ref.watch(singboxProxyProfilesRepositoryProvider);
  profilesAsync.whenOrNull(
    error: (error, stackTrace) => logger.e(
      'Failed to load sing-box proxy profiles for connection picker',
      error: error,
      stackTrace: stackTrace,
    ),
  );

  final singboxProfiles = profilesAsync.value ?? const [];

  return [
    ProxyConnectionOption(
      id: const TorProxyConnectionId(),
      title: 'Tor',
      subtitle: 'Route through the Tor network',
    ),
    for (final profile in singboxProfiles)
      ProxyConnectionOption(
        id: profile.proxyConnection,
        title: profile.name,
        subtitle: profile.type.label,
      ),
  ];
}

String proxyConnectionTitle(
  List<ProxyConnectionOption> options,
  ProxyConnectionId proxyConnectionId, {
  bool isLoading = false,
}) {
  for (final option in options) {
    if (option.id == proxyConnectionId) {
      return option.title;
    }
  }

  return isLoading ? loadingProxyTitle : unknownProxyTitle;
}

bool proxyConnectionOptionExists(
  List<ProxyConnectionOption> options,
  ProxyConnectionId proxyConnectionId,
) {
  return options.any((option) => option.id == proxyConnectionId);
}
