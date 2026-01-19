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
