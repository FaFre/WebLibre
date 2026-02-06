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
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/repositories/site_permissions.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/sheets/tracking_protection_provider.dart';

part 'site_settings_badge_provider.g.dart';

const _supportedSchemes = {'http', 'https'};

/// Provider that determines whether to show the site settings badge on the tab icon.
/// Returns true if any site-specific setting has been altered from defaults.
@Riverpod()
Future<bool> showSiteSettingsBadge(Ref ref) async {
  final tabState = ref.watch(selectedTabStateProvider);
  if (tabState == null) {
    return false;
  }

  // Check tracking protection exception
  final hasTrackingException = await ref.watch(
    hasTrackingProtectionExceptionProvider(tabState.id).future,
  );

  if (!tabState.url.hasScheme ||
      !_supportedSchemes.contains(tabState.url.scheme)) {
    return false;
  }

  // Watch site permissions
  final permissions = await ref.watch(
    sitePermissionsRepositoryProvider(
      origin: tabState.url.origin,
      isPrivate: tabState.isPrivate,
    ).future,
  );

  if (hasTrackingException) {
    return true;
  }
  // Check for altered permissions
  if (_hasAlteredPermissions(permissions)) {
    return true;
  }
  // Check for altered autoplay settings
  if (_hasAlteredAutoplay(permissions)) {
    return true;
  }

  return false;
}

/// Checks if any permission has been explicitly set to allowed or blocked
bool _hasAlteredPermissions(SitePermissions? permissions) {
  if (permissions == null) {
    return false;
  }

  // Check all permission fields
  final permissionStatuses = [
    permissions.camera,
    permissions.microphone,
    permissions.location,
    permissions.notification,
    permissions.persistentStorage,
    permissions.crossOriginStorageAccess,
    permissions.mediaKeySystemAccess,
    permissions.localDeviceAccess,
    permissions.localNetworkAccess,
  ];

  return permissionStatuses.any(
    (status) =>
        status != null &&
        (status == SitePermissionStatus.allowed ||
            status == SitePermissionStatus.blocked),
  );
}

/// Checks if autoplay settings differ from defaults
/// Default: autoplayAudible = blocked (null), autoplayInaudible = allowed (null)
bool _hasAlteredAutoplay(SitePermissions? permissions) {
  if (permissions == null) {
    return false;
  }

  final audible = permissions.autoplayAudible;
  final inaudible = permissions.autoplayInaudible;

  // Check if audible differs from default (null or blocked)
  final audibleAltered = audible != null && audible != AutoplayStatus.blocked;

  // Check if inaudible differs from default (null or allowed)
  final inaudibleAltered =
      inaudible != null && inaudible != AutoplayStatus.allowed;

  return audibleAltered || inaudibleAltered;
}
