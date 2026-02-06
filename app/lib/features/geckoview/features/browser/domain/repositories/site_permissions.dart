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
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/site_permissions.dart';

part 'site_permissions.g.dart';

typedef PermissionUpdater = SitePermissions Function(SitePermissionsWrapper);

@Riverpod(keepAlive: true)
class SitePermissionsRepository extends _$SitePermissionsRepository {
  final _api = GeckoSitePermissionsApi();

  Future<SitePermissions?> getPermissions() async {
    final permissions = await _api.getSitePermissions(origin, isPrivate);
    state = AsyncValue.data(permissions);

    return permissions;
  }

  Future<void> updatePermission(PermissionUpdater updater) async {
    final currentPermissions =
        await getPermissions() ??
        SitePermissions(
          origin: origin,
          savedAt: DateTime.now().millisecondsSinceEpoch,
        );

    await setPermissions(
      updater(SitePermissionsWrapper.fromPermission(currentPermissions)),
    );
  }

  Future<void> setPermissions(SitePermissions permissions) async {
    if (permissions.origin != origin) {
      throw Exception('Origin does not match');
    }

    await _api.setSitePermissions(permissions, isPrivate);
    ref.invalidateSelf();
  }

  Future<void> deletePermissions() async {
    await _api.deleteSitePermissions(origin, isPrivate);
    ref.invalidateSelf();
  }

  @override
  Future<SitePermissions?> build({
    required String origin,
    required bool isPrivate,
  }) async {
    final permissions = await _api.getSitePermissions(origin, isPrivate);
    return permissions;
  }
}
