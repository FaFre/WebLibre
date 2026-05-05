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
import 'package:weblibre/extensions/uri.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/repositories/site_permissions.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/sheets/tracking_protection_provider.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';

part 'site_settings_badge_provider.g.dart';

/// Indicates whether the site settings badge should be shown on the tab icon
/// and, if so, which direction settings have been changed.
enum SiteSettingsBadgeState {
  /// No per-site settings differ from defaults.
  hidden,

  /// At least one per-site setting is stricter than the default.
  improved,

  /// At least one per-site setting is looser than the default.
  /// Tracking-protection exceptions also count as weakened.
  weakened,
}

/// Provider that determines the site settings badge state on the tab icon.
@Riverpod()
Future<SiteSettingsBadgeState> showSiteSettingsBadge(Ref ref) async {
  final tabState = ref.watch(selectedTabStateProvider);
  if (tabState == null) {
    return SiteSettingsBadgeState.hidden;
  }

  // Check tracking protection exception
  final hasTrackingException = await ref.watch(
    hasTrackingProtectionExceptionProvider(tabState.id).future,
  );

  if (!tabState.url.hasScheme || !tabState.url.isHttpOrHttps) {
    return SiteSettingsBadgeState.hidden;
  }

  // Watch site permissions
  final permissions = await ref.watch(
    sitePermissionsRepositoryProvider(
      origin: tabState.url.origin,
      isPrivate: tabState.tabMode is PrivateTabMode,
    ).future,
  );

  if (hasTrackingException) {
    return SiteSettingsBadgeState.weakened;
  }

  final badgeState = _evaluateBadgeState(permissions);
  return badgeState;
}

/// Evaluates whether site permissions are default, improved, or weakened.
/// Weakened takes precedence over improved.
SiteSettingsBadgeState _evaluateBadgeState(SitePermissions? permissions) {
  if (permissions == null) {
    return SiteSettingsBadgeState.hidden;
  }

  var hasImproved = false;
  var hasWeakened = false;

  // Evaluate permission-type fields
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

  for (final status in permissionStatuses) {
    if (status == null) {
      continue;
    }
    if (status == SitePermissionStatus.blocked) {
      hasImproved = true;
    } else if (status == SitePermissionStatus.allowed) {
      hasWeakened = true;
    }
    // noDecision is the default -> no effect
  }

  // Evaluate autoplay audible
  final audible = permissions.autoplayAudible;
  if (audible != null && audible != AutoplayStatus.blocked) {
    hasWeakened = true;
  }

  // Evaluate autoplay inaudible
  final inaudible = permissions.autoplayInaudible;
  if (inaudible != null) {
    if (inaudible == AutoplayStatus.blocked) {
      hasImproved = true;
    } else if (inaudible != AutoplayStatus.allowed) {
      hasWeakened = true;
    }
  }

  if (hasWeakened) {
    return SiteSettingsBadgeState.weakened;
  }
  if (hasImproved) {
    return SiteSettingsBadgeState.improved;
  }

  return SiteSettingsBadgeState.hidden;
}
