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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'site_permissions_provider.g.dart';

/// Provider to fetch site permissions for a given origin
@Riverpod()
Future<SitePermissions?> sitePermissions(
  Ref ref,
  String origin,
  bool isPrivate,
) {
  final api = GeckoSitePermissionsApi();
  return api.getSitePermissions(origin, isPrivate);
}

/// Provider to get the public suffix plus one (eTLD+1) for a host
@Riverpod()
Future<String> publicSuffixPlusOne(Ref ref, String host) {
  final api = GeckoPublicSuffixListApi();
  return api.getPublicSuffixPlusOne(host);
}

/// Notifier for managing selected clear data types
@Riverpod()
class SelectedClearDataTypes extends _$SelectedClearDataTypes {
  @override
  Set<ClearDataType> build() {
    // Default to clearing all site data and auth sessions (most common use case)
    return {ClearDataType.allSiteData, ClearDataType.authSessions};
  }

  void toggle(ClearDataType type) {
    if (state.contains(type)) {
      state = Set.from(state)..remove(type);
    } else {
      state = Set.from(state)..add(type);
    }
  }

  void selectAll() {
    state = Set.from(ClearDataType.values);
  }

  void clearAll() {
    state = {};
  }
}
