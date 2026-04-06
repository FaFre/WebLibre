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
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';

part 'site_permissions.g.dart';

@CopyWith()
class SitePermissionsWrapper extends SitePermissions {
  SitePermissionsWrapper({
    required super.origin,
    super.camera,
    super.microphone,
    super.location,
    super.notification,
    super.persistentStorage,
    super.crossOriginStorageAccess,
    super.mediaKeySystemAccess,
    super.localDeviceAccess,
    super.localNetworkAccess,
    super.autoplayAudible,
    super.autoplayInaudible,
    required super.savedAt,
  });

  factory SitePermissionsWrapper.fromPermission(SitePermissions permissions) {
    return SitePermissionsWrapper(
      origin: permissions.origin,
      camera: permissions.camera,
      microphone: permissions.microphone,
      location: permissions.location,
      notification: permissions.notification,
      persistentStorage: permissions.persistentStorage,
      crossOriginStorageAccess: permissions.crossOriginStorageAccess,
      mediaKeySystemAccess: permissions.mediaKeySystemAccess,
      localDeviceAccess: permissions.localDeviceAccess,
      localNetworkAccess: permissions.localNetworkAccess,
      autoplayAudible: permissions.autoplayAudible,
      autoplayInaudible: permissions.autoplayInaudible,
      savedAt: permissions.savedAt,
    );
  }
}
