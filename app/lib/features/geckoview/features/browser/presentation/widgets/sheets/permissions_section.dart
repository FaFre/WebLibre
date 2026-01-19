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
import 'package:weblibre/features/geckoview/features/browser/domain/entities/permission_type.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/site_permissions.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/repositories/site_permissions.dart';

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
      sitePermissionsRepositoryProvider(origin: origin, isPrivate: isPrivate),
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

    // Memoize the update callback to avoid recreating closures
    final updatePermission = useCallback((
      SitePermissions Function(SitePermissionsWrapper) updater,
    ) async {
      await ref
          .read(
            sitePermissionsRepositoryProvider(
              origin: origin,
              isPrivate: isPrivate,
            ).notifier,
          )
          .updatePermission(updater);
      await ref.read(selectedTabSessionProvider).reload();
    }, [origin, isPrivate]);

    // Build permission entries - only recalculates when permissions change
    final allPermissions = useMemoized(
      () => PermissionType.values
          .map(
            (type) => _PermissionEntry(
              icon: type.icon,
              label: type.label,
              status: permissions.getStatus(type),
              onChanged: (status) =>
                  updatePermission((w) => w.withStatus(type, status)),
            ),
          )
          .toList(),
      [permissions, updatePermission],
    );

    // Filter to only show permissions that have been explicitly set (not noDecision)
    // Only recalculates when allPermissions changes
    final setPermissions = useMemoized(
      () => allPermissions
          .where(
            (p) =>
                p.status != null && p.status != SitePermissionStatus.noDecision,
          )
          .toList(),
      [allPermissions],
    );

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
        ...permissionsToShow.map(
          (entry) => _PermissionTile(
            icon: entry.icon,
            label: entry.label,
            status: entry.status,
            onChanged: entry.onChanged,
          ),
        ),
        if (permissionsToShow.isEmpty && !showAll.value)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
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
          onChanged: (audible, inaudible) => updatePermission(
            (p) => p.copyWith(
              autoplayAudible: audible,
              autoplayInaudible: inaudible,
            ),
          ),
        ),
      ],
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

    if (audible == AutoplayStatus.allowed &&
        inaudible == AutoplayStatus.allowed) {
      return _AutoplayCombined.allowAll;
    } else if (audible == AutoplayStatus.blocked &&
        inaudible == AutoplayStatus.allowed) {
      return _AutoplayCombined.blockAudible;
    } else {
      return _AutoplayCombined.blockAll;
    }
  }
}

enum _AutoplayCombined { allowAll, blockAudible, blockAll }
