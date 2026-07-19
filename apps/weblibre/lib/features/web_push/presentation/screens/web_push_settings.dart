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
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/web_push/domain/providers.dart';
import 'package:weblibre/utils/ui_helper.dart';

const List<SettingsSectionDefinition> webPushSettingsSections = [
  SettingsSectionDefinition(
    title: 'Delivery',
    entries: [
      SettingsEntryDefinition(
        title: 'UnifiedPush Distributor',
        subtitle: 'The app that delivers website push notifications',
        keywords: ['notifications', 'push', 'unifiedpush', 'ntfy'],
        child: _DistributorTile(),
      ),
      SettingsEntryDefinition(
        title: 'Notification Permission',
        subtitle: 'Required to display website notifications',
        keywords: ['notifications', 'permission'],
        child: _NotificationPermissionTile(),
      ),
    ],
  ),
  SettingsSectionDefinition(
    title: 'Subscriptions',
    entries: [
      SettingsEntryDefinition(
        title: 'Site Subscriptions',
        subtitle: 'Websites subscribed to push notifications',
        keywords: ['sites', 'subscriptions'],
        child: _SubscriptionList(),
      ),
    ],
  ),
];

class WebPushSettingsScreen extends StatelessWidget {
  const WebPushSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsDetailScaffold(
      title: 'Notifications',
      subtitle: 'Web push delivery, distributor, and site subscriptions.',
      icon: MdiIcons.bellBadgeOutline,
      sections: webPushSettingsSections,
    );
  }
}

extension on PushDistributorStatus {
  String get label => switch (this) {
    PushDistributorStatus.noneAvailable => 'No distributor installed',
    PushDistributorStatus.notSelected => 'No distributor selected',
    PushDistributorStatus.pending => 'Waiting for distributor',
    PushDistributorStatus.ready => 'Active',
    PushDistributorStatus.unavailable => 'Distributor uninstalled',
  };

  String get description => switch (this) {
    PushDistributorStatus.noneAvailable =>
      'Install a UnifiedPush distributor such as ntfy to receive website push notifications.',
    PushDistributorStatus.notSelected =>
      'Choose which app should deliver website push notifications to WebLibre.',
    PushDistributorStatus.pending =>
      'The selected app has not confirmed registration yet. This usually resolves on its own.',
    PushDistributorStatus.ready =>
      'Website push notifications are delivered through this app.',
    PushDistributorStatus.unavailable =>
      'The app that delivered push notifications was uninstalled. Website notifications will not arrive until you choose another.',
  };

  bool get isProblem =>
      this == PushDistributorStatus.unavailable ||
      this == PushDistributorStatus.noneAvailable;
}

class _DistributorTile extends HookConsumerWidget {
  const _DistributorTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(pushStatusProvider);
    final mutation = ref.watch(pushDistributorMutationProvider);
    final isMutating = mutation.isLoading;

    return status.when(
      loading: () => const ListTile(
        leading: Icon(MdiIcons.bellBadgeOutline),
        title: Text('UnifiedPush Distributor'),
        subtitle: Text('Checking…'),
      ),
      error: (error, _) => ListTile(
        leading: const Icon(MdiIcons.alertCircleOutline),
        title: const Text('UnifiedPush Distributor'),
        subtitle: Text('Could not read push status: $error'),
      ),
      data: (pushStatus) {
        final theme = Theme.of(context);
        final current = pushStatus.current;
        final failure = pushStatus.lastError;
        final isProblem = pushStatus.status.isProblem || failure != null;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                isProblem
                    ? MdiIcons.bellRemoveOutline
                    : MdiIcons.bellBadgeOutline,
                color: isProblem ? theme.colorScheme.error : null,
              ),
              title: const Text('UnifiedPush Distributor'),
              subtitle: Text(
                isMutating
                    ? 'Updating distributor...'
                    : current != null
                    ? '${current.label ?? current.packageName} — ${pushStatus.status.label}'
                    : pushStatus.status.label,
                style: isProblem
                    ? TextStyle(color: theme.colorScheme.error)
                    : null,
              ),
              trailing: isMutating
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right),
              onTap: isMutating
                  ? null
                  : () => _pickDistributor(context, ref, pushStatus),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  failure == null
                      ? pushStatus.status.description
                      : 'Push delivery may be temporarily unavailable while the distributor registration recovers.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ),
            if (failure != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Last registration error: $failure',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ),
            if (current != null)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 8),
                  child: TextButton.icon(
                    icon: const Icon(MdiIcons.bellOffOutline),
                    label: Text(
                      isMutating ? 'Disabling web push...' : 'Disable web push',
                    ),
                    onPressed: isMutating
                        ? null
                        : () => _removeDistributor(context, ref),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Picks a distributor from [pushStatus]'s available list.
  ///
  /// Deliberately a Dart dialog rather than the connector's own picker: that one
  /// saves the selection against a context that is not the profile context, so
  /// the choice would be invisible to the rest of the push stack.
  Future<void> _pickDistributor(
    BuildContext context,
    WidgetRef ref,
    PushStatus pushStatus,
  ) async {
    if (pushStatus.available.isEmpty) {
      showErrorMessage(
        context,
        'No UnifiedPush distributor installed. Install one, such as ntfy, and try again.',
      );
      return;
    }

    final selected = await showDialog<PushDistributor>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Choose distributor'),
        children: [
          for (final distributor in pushStatus.available)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, distributor),
              child: ListTile(
                leading: Icon(
                  distributor.packageName == pushStatus.current?.packageName
                      ? MdiIcons.checkCircle
                      : MdiIcons.circleOutline,
                ),
                title: Text(distributor.label ?? distributor.packageName),
                subtitle: Text(distributor.packageName),
              ),
            ),
        ],
      ),
    );

    if (selected == null || !context.mounted) {
      return;
    }

    try {
      await ref
          .read(pushDistributorMutationProvider.notifier)
          .setDistributor(selected.packageName);
      if (context.mounted) {
        showInfoMessage(context, 'UnifiedPush distributor configured.');
      }
    } catch (error) {
      if (context.mounted) {
        showErrorMessage(context, 'Could not configure distributor: $error');
      }
    }
  }

  Future<void> _removeDistributor(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(pushDistributorMutationProvider.notifier)
          .removeDistributor();
      if (context.mounted) {
        showInfoMessage(context, 'Web push disabled.');
      }
    } catch (error) {
      if (context.mounted) {
        showErrorMessage(context, 'Could not disable web push: $error');
      }
    }
  }
}

class _NotificationPermissionTile extends HookConsumerWidget {
  const _NotificationPermissionTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUpdating = useState(false);
    final granted = ref.watch(notificationPermissionGrantedProvider);
    final theme = Theme.of(context);

    useOnAppLifecycleStateChange((previous, current) {
      if (current == AppLifecycleState.resumed && !isUpdating.value) {
        ref.invalidate(notificationPermissionGrantedProvider);
      }
    });

    return granted.when(
      loading: () => const ListTile(
        leading: Icon(MdiIcons.bellBadgeOutline),
        title: Text('Notification Permission'),
        subtitle: Text('Checking…'),
      ),
      error: (error, _) => ListTile(
        leading: Icon(
          MdiIcons.alertCircleOutline,
          color: theme.colorScheme.error,
        ),
        title: const Text('Notification Permission'),
        subtitle: Text('Could not read permission state: $error'),
      ),
      data: (isGranted) {
        if (isGranted) {
          return const ListTile(
            leading: Icon(MdiIcons.bellCheckOutline),
            title: Text('Notification Permission'),
            subtitle: Text('Granted'),
          );
        }

        return ListTile(
          leading: Icon(
            MdiIcons.bellRemoveOutline,
            color: theme.colorScheme.error,
          ),
          title: const Text('Notification Permission'),
          subtitle: Text(
            'Denied. Push messages arrive but no notification can be shown.',
            style: TextStyle(color: theme.colorScheme.error),
          ),
          trailing: TextButton(
            onPressed: isUpdating.value
                ? null
                : () async {
                    isUpdating.value = true;
                    try {
                      final service = ref.read(
                        notificationPermissionServiceProvider,
                      );
                      final status = await service.request();
                      if (status.isPermanentlyDenied &&
                          !await service.openSettings()) {
                        throw StateError('Could not open app settings');
                      }
                    } catch (error) {
                      if (context.mounted) {
                        showErrorMessage(
                          context,
                          'Could not update notification permission: $error',
                        );
                      }
                    } finally {
                      if (context.mounted) {
                        ref.invalidate(notificationPermissionGrantedProvider);
                        isUpdating.value = false;
                      }
                    }
                  },
            child: isUpdating.value
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                  )
                : const Text('Grant'),
          ),
        );
      },
    );
  }
}

class _SubscriptionList extends HookConsumerWidget {
  const _SubscriptionList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptions = ref.watch(pushSubscriptionsProvider);
    final distributorReady =
        ref.watch(pushStatusProvider).value?.status ==
        PushDistributorStatus.ready;

    return subscriptions.when(
      loading: () => const ListTile(
        leading: SizedBox.square(
          dimension: 24,
          child: CircularProgressIndicator.adaptive(strokeWidth: 2),
        ),
        title: Text('Loading subscriptions…'),
      ),
      error: (error, _) => ListTile(
        leading: const Icon(MdiIcons.alertCircleOutline),
        title: const Text('Could not read subscriptions'),
        subtitle: Text('$error'),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const ListTile(
            leading: Icon(MdiIcons.webOff),
            title: Text('No site subscriptions'),
            subtitle: Text(
              'Websites you allow to send notifications will appear here.',
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final subscription in items)
              ListTile(
                leading: Icon(
                  subscription.hasEndpoint ? MdiIcons.web : MdiIcons.webClock,
                ),
                title: Text(subscription.scope),
                subtitle: Text(
                  subscription.hasEndpoint
                      ? distributorReady
                            ? 'Active'
                            : 'Endpoint saved; delivery is paused until the distributor is ready'
                      : 'Waiting for the distributor to assign an endpoint',
                ),
              ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'To stop a site from sending notifications, revoke its '
                  'notification permission in the site settings.',
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
