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
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_session.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/sheets/site_permissions_provider.dart';

/// Section widget displaying site permissions with toggles
class PermissionsSection extends HookConsumerWidget {
  final String origin;
  final bool isPrivate;

  const PermissionsSection({
    required this.origin,
    required this.isPrivate,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionsAsync = ref.watch(
      sitePermissionsProvider(origin, isPrivate),
    );

    return permissionsAsync.when(
      data: (permissions) => _PermissionsList(
        origin: origin,
        isPrivate: isPrivate,
        permissions: permissions,
      ),
      loading: () => const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Error loading permissions: $error'),
      ),
    );
  }
}

class _PermissionsList extends HookConsumerWidget {
  final String origin;
  final bool isPrivate;
  final SitePermissions? permissions;

  const _PermissionsList({
    required this.origin,
    required this.isPrivate,
    required this.permissions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showAll = useState(false);

    // Build list of permission entries with their current status
    final allPermissions = [
      _PermissionEntry(
        icon: Icons.videocam,
        label: 'Camera',
        status: permissions?.camera,
        onChanged: (status) => _updatePermission(ref, (p) => _copyWithCamera(p, status)),
      ),
      _PermissionEntry(
        icon: Icons.mic,
        label: 'Microphone',
        status: permissions?.microphone,
        onChanged: (status) => _updatePermission(ref, (p) => _copyWithMicrophone(p, status)),
      ),
      _PermissionEntry(
        icon: Icons.location_on,
        label: 'Location',
        status: permissions?.location,
        onChanged: (status) => _updatePermission(ref, (p) => _copyWithLocation(p, status)),
      ),
      _PermissionEntry(
        icon: Icons.notifications,
        label: 'Notifications',
        status: permissions?.notification,
        onChanged: (status) => _updatePermission(ref, (p) => _copyWithNotification(p, status)),
      ),
      _PermissionEntry(
        icon: Icons.storage,
        label: 'Persistent Storage',
        status: permissions?.persistentStorage,
        onChanged: (status) => _updatePermission(ref, (p) => _copyWithPersistentStorage(p, status)),
      ),
      _PermissionEntry(
        icon: Icons.cookie,
        label: 'Cross-Origin Storage',
        status: permissions?.crossOriginStorageAccess,
        onChanged: (status) => _updatePermission(ref, (p) => _copyWithCrossOriginStorage(p, status)),
      ),
      _PermissionEntry(
        icon: Icons.key,
        label: 'Media Key System (DRM)',
        status: permissions?.mediaKeySystemAccess,
        onChanged: (status) => _updatePermission(ref, (p) => _copyWithMediaKeySystem(p, status)),
      ),
    ];

    // Filter to only show permissions that have been explicitly set (not noDecision)
    final setPermissions = allPermissions.where(
      (p) => p.status != null && p.status != SitePermissionStatus.noDecision,
    ).toList();

    final permissionsToShow = showAll.value ? allPermissions : setPermissions;
    final hiddenCount = allPermissions.length - setPermissions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Text(
                'Permissions',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Spacer(),
              if (hiddenCount > 0)
                TextButton(
                  onPressed: () => showAll.value = !showAll.value,
                  child: Text(showAll.value ? 'Show less' : 'Show all'),
                ),
            ],
          ),
        ),
        ...permissionsToShow.map((entry) => _PermissionTile(
          icon: entry.icon,
          label: entry.label,
          status: entry.status,
          onChanged: entry.onChanged,
        )),
        if (permissionsToShow.isEmpty && !showAll.value)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'No permissions set for this site',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        const SizedBox(height: 8.0),
        _AutoplayTile(
          audibleStatus: permissions?.autoplayAudible,
          inaudibleStatus: permissions?.autoplayInaudible,
          onChanged: (audible, inaudible) => _updateAutoplay(ref, audible, inaudible),
        ),
      ],
    );
  }

  Future<void> _updatePermission(
    WidgetRef ref,
    SitePermissions Function(SitePermissions) updater,
  ) async {
    final currentPermissions = permissions ?? SitePermissions(
      origin: origin,
      savedAt: DateTime.now().millisecondsSinceEpoch,
    );

    final updatedPermissions = updater(currentPermissions);

    final api = GeckoSitePermissionsApi();
    await api.setSitePermissions(updatedPermissions, isPrivate);

    // Invalidate the provider to refetch
    ref.invalidate(sitePermissionsProvider(origin, isPrivate));

    // Reload the tab to apply changes
    await ref.read(selectedTabSessionProvider).reload();
  }

  Future<void> _updateAutoplay(
    WidgetRef ref,
    AutoplayStatus? audible,
    AutoplayStatus? inaudible,
  ) async {
    final currentPermissions = permissions ?? SitePermissions(
      origin: origin,
      savedAt: DateTime.now().millisecondsSinceEpoch,
    );

    final updatedPermissions = SitePermissions(
      origin: currentPermissions.origin,
      camera: currentPermissions.camera,
      microphone: currentPermissions.microphone,
      location: currentPermissions.location,
      notification: currentPermissions.notification,
      persistentStorage: currentPermissions.persistentStorage,
      crossOriginStorageAccess: currentPermissions.crossOriginStorageAccess,
      mediaKeySystemAccess: currentPermissions.mediaKeySystemAccess,
      localDeviceAccess: currentPermissions.localDeviceAccess,
      localNetworkAccess: currentPermissions.localNetworkAccess,
      autoplayAudible: audible ?? currentPermissions.autoplayAudible,
      autoplayInaudible: inaudible ?? currentPermissions.autoplayInaudible,
      savedAt: currentPermissions.savedAt,
    );

    final api = GeckoSitePermissionsApi();
    await api.setSitePermissions(updatedPermissions, isPrivate);

    ref.invalidate(sitePermissionsProvider(origin, isPrivate));
    await ref.read(selectedTabSessionProvider).reload();
  }

  // Copy helper methods since Pigeon doesn't generate copyWith
  SitePermissions _copyWithCamera(SitePermissions p, SitePermissionStatus status) {
    return SitePermissions(
      origin: p.origin,
      camera: status,
      microphone: p.microphone,
      location: p.location,
      notification: p.notification,
      persistentStorage: p.persistentStorage,
      crossOriginStorageAccess: p.crossOriginStorageAccess,
      mediaKeySystemAccess: p.mediaKeySystemAccess,
      localDeviceAccess: p.localDeviceAccess,
      localNetworkAccess: p.localNetworkAccess,
      autoplayAudible: p.autoplayAudible,
      autoplayInaudible: p.autoplayInaudible,
      savedAt: p.savedAt,
    );
  }

  SitePermissions _copyWithMicrophone(SitePermissions p, SitePermissionStatus status) {
    return SitePermissions(
      origin: p.origin,
      camera: p.camera,
      microphone: status,
      location: p.location,
      notification: p.notification,
      persistentStorage: p.persistentStorage,
      crossOriginStorageAccess: p.crossOriginStorageAccess,
      mediaKeySystemAccess: p.mediaKeySystemAccess,
      localDeviceAccess: p.localDeviceAccess,
      localNetworkAccess: p.localNetworkAccess,
      autoplayAudible: p.autoplayAudible,
      autoplayInaudible: p.autoplayInaudible,
      savedAt: p.savedAt,
    );
  }

  SitePermissions _copyWithLocation(SitePermissions p, SitePermissionStatus status) {
    return SitePermissions(
      origin: p.origin,
      camera: p.camera,
      microphone: p.microphone,
      location: status,
      notification: p.notification,
      persistentStorage: p.persistentStorage,
      crossOriginStorageAccess: p.crossOriginStorageAccess,
      mediaKeySystemAccess: p.mediaKeySystemAccess,
      localDeviceAccess: p.localDeviceAccess,
      localNetworkAccess: p.localNetworkAccess,
      autoplayAudible: p.autoplayAudible,
      autoplayInaudible: p.autoplayInaudible,
      savedAt: p.savedAt,
    );
  }

  SitePermissions _copyWithNotification(SitePermissions p, SitePermissionStatus status) {
    return SitePermissions(
      origin: p.origin,
      camera: p.camera,
      microphone: p.microphone,
      location: p.location,
      notification: status,
      persistentStorage: p.persistentStorage,
      crossOriginStorageAccess: p.crossOriginStorageAccess,
      mediaKeySystemAccess: p.mediaKeySystemAccess,
      localDeviceAccess: p.localDeviceAccess,
      localNetworkAccess: p.localNetworkAccess,
      autoplayAudible: p.autoplayAudible,
      autoplayInaudible: p.autoplayInaudible,
      savedAt: p.savedAt,
    );
  }

  SitePermissions _copyWithPersistentStorage(SitePermissions p, SitePermissionStatus status) {
    return SitePermissions(
      origin: p.origin,
      camera: p.camera,
      microphone: p.microphone,
      location: p.location,
      notification: p.notification,
      persistentStorage: status,
      crossOriginStorageAccess: p.crossOriginStorageAccess,
      mediaKeySystemAccess: p.mediaKeySystemAccess,
      localDeviceAccess: p.localDeviceAccess,
      localNetworkAccess: p.localNetworkAccess,
      autoplayAudible: p.autoplayAudible,
      autoplayInaudible: p.autoplayInaudible,
      savedAt: p.savedAt,
    );
  }

  SitePermissions _copyWithCrossOriginStorage(SitePermissions p, SitePermissionStatus status) {
    return SitePermissions(
      origin: p.origin,
      camera: p.camera,
      microphone: p.microphone,
      location: p.location,
      notification: p.notification,
      persistentStorage: p.persistentStorage,
      crossOriginStorageAccess: status,
      mediaKeySystemAccess: p.mediaKeySystemAccess,
      localDeviceAccess: p.localDeviceAccess,
      localNetworkAccess: p.localNetworkAccess,
      autoplayAudible: p.autoplayAudible,
      autoplayInaudible: p.autoplayInaudible,
      savedAt: p.savedAt,
    );
  }

  SitePermissions _copyWithMediaKeySystem(SitePermissions p, SitePermissionStatus status) {
    return SitePermissions(
      origin: p.origin,
      camera: p.camera,
      microphone: p.microphone,
      location: p.location,
      notification: p.notification,
      persistentStorage: p.persistentStorage,
      crossOriginStorageAccess: p.crossOriginStorageAccess,
      mediaKeySystemAccess: status,
      localDeviceAccess: p.localDeviceAccess,
      localNetworkAccess: p.localNetworkAccess,
      autoplayAudible: p.autoplayAudible,
      autoplayInaudible: p.autoplayInaudible,
      savedAt: p.savedAt,
    );
  }
}

class _PermissionEntry {
  final IconData icon;
  final String label;
  final SitePermissionStatus? status;
  final ValueChanged<SitePermissionStatus> onChanged;

  _PermissionEntry({
    required this.icon,
    required this.label,
    required this.status,
    required this.onChanged,
  });
}

class _PermissionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final SitePermissionStatus? status;
  final ValueChanged<SitePermissionStatus> onChanged;

  const _PermissionTile({
    required this.icon,
    required this.label,
    required this.status,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final currentStatus = status ?? SitePermissionStatus.noDecision;

    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: DropdownButton<SitePermissionStatus>(
        value: currentStatus,
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(
            value: SitePermissionStatus.noDecision,
            child: Text('Ask'),
          ),
          DropdownMenuItem(
            value: SitePermissionStatus.allowed,
            child: Text('Allow'),
          ),
          DropdownMenuItem(
            value: SitePermissionStatus.blocked,
            child: Text('Block'),
          ),
        ],
        onChanged: (value) {
          if (value != null) {
            onChanged(value);
          }
        },
      ),
    );
  }
}

class _AutoplayTile extends StatelessWidget {
  final AutoplayStatus? audibleStatus;
  final AutoplayStatus? inaudibleStatus;
  final void Function(AutoplayStatus?, AutoplayStatus?) onChanged;

  const _AutoplayTile({
    required this.audibleStatus,
    required this.inaudibleStatus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the combined autoplay setting
    final combinedStatus = _getCombinedStatus();

    return ListTile(
      leading: const Icon(Icons.play_circle),
      title: const Text('Autoplay'),
      trailing: DropdownButton<_AutoplayCombined>(
        value: combinedStatus,
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(
            value: _AutoplayCombined.allowAll,
            child: Text('Allow All'),
          ),
          DropdownMenuItem(
            value: _AutoplayCombined.blockAudible,
            child: Text('Block Audible'),
          ),
          DropdownMenuItem(
            value: _AutoplayCombined.blockAll,
            child: Text('Block All'),
          ),
        ],
        onChanged: (value) {
          if (value == null) return;
          switch (value) {
            case _AutoplayCombined.allowAll:
              onChanged(AutoplayStatus.allowed, AutoplayStatus.allowed);
            case _AutoplayCombined.blockAudible:
              onChanged(AutoplayStatus.blocked, AutoplayStatus.allowed);
            case _AutoplayCombined.blockAll:
              onChanged(AutoplayStatus.blocked, AutoplayStatus.blocked);
          }
        },
      ),
    );
  }

  _AutoplayCombined _getCombinedStatus() {
    final audible = audibleStatus ?? AutoplayStatus.blocked;
    final inaudible = inaudibleStatus ?? AutoplayStatus.allowed;

    if (audible == AutoplayStatus.allowed && inaudible == AutoplayStatus.allowed) {
      return _AutoplayCombined.allowAll;
    } else if (audible == AutoplayStatus.blocked && inaudible == AutoplayStatus.allowed) {
      return _AutoplayCombined.blockAudible;
    } else {
      return _AutoplayCombined.blockAll;
    }
  }
}

enum _AutoplayCombined {
  allowAll,
  blockAudible,
  blockAll,
}
