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
import 'package:flutter/material.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/site_permissions.dart';

/// Permission types with their display configuration
enum PermissionType {
  camera(Icons.videocam, 'Camera'),
  microphone(Icons.mic, 'Microphone'),
  location(Icons.location_on, 'Location'),
  notification(Icons.notifications, 'Notifications'),
  persistentStorage(Icons.storage, 'Persistent Storage'),
  crossOriginStorage(Icons.cookie, 'Cross-Origin Storage'),
  mediaKeySystem(Icons.key, 'Media Key System (DRM)');

  const PermissionType(this.icon, this.label);
  final IconData icon;
  final String label;
}

extension SitePermissionsGetter on SitePermissions? {
  SitePermissionStatus? getStatus(PermissionType type) => switch (type) {
    PermissionType.camera => this?.camera,
    PermissionType.microphone => this?.microphone,
    PermissionType.location => this?.location,
    PermissionType.notification => this?.notification,
    PermissionType.persistentStorage => this?.persistentStorage,
    PermissionType.crossOriginStorage => this?.crossOriginStorageAccess,
    PermissionType.mediaKeySystem => this?.mediaKeySystemAccess,
  };
}

extension SitePermissionsUpdater on SitePermissionsWrapper {
  SitePermissions withStatus(
    PermissionType type,
    SitePermissionStatus status,
  ) => switch (type) {
    PermissionType.camera => copyWith.camera(status),
    PermissionType.microphone => copyWith.microphone(status),
    PermissionType.location => copyWith.location(status),
    PermissionType.notification => copyWith.notification(status),
    PermissionType.persistentStorage => copyWith.persistentStorage(status),
    PermissionType.crossOriginStorage => copyWith.crossOriginStorageAccess(
      status,
    ),
    PermissionType.mediaKeySystem => copyWith.mediaKeySystemAccess(status),
  };
}
