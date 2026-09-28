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
import 'package:weblibre/core/design/display_features.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/web_push/domain/providers.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/utils/ui_helper.dart';

List<SettingsSectionDefinition> webPushSettingsSections(BuildContext context) {
  final l10n = AppLocalizations.of(context);

  return [
    SettingsSectionDefinition(
      title: l10n.webPush_deliverySectionTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.webPush_distributorTileTitle,
          subtitle: l10n.webPush_indexDistributorSubtitle,
          keywords: settingsKeywords(l10n.webPush_distributorTileKeywords),
          child: const _DistributorTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.webPush_notificationPermissionTitle,
          subtitle: l10n.webPush_indexNotificationPermissionSubtitle,
          keywords: settingsKeywords(
            l10n.webPush_notificationPermissionKeywords,
          ),
          child: const _NotificationPermissionTile(),
        ),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.webPush_subscriptionsSectionTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.webPush_indexSiteSubscriptionsTitle,
          subtitle: l10n.webPush_indexSiteSubscriptionsSubtitle,
          keywords: settingsKeywords(
            l10n.webPush_indexSiteSubscriptionsKeywords,
          ),
          child: const _SubscriptionList(),
        ),
      ],
    ),
  ];
}

class WebPushSettingsScreen extends StatelessWidget {
  const WebPushSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SettingsDetailScaffold(
      title: l10n.webPush_screenTitle,
      subtitle: l10n.webPush_screenSubtitle,
      icon: MdiIcons.bellBadgeOutline,
      sections: webPushSettingsSections(context),
    );
  }
}

extension on PushDistributorStatus {
  String label(AppLocalizations l10n) => switch (this) {
    PushDistributorStatus.noneAvailable => l10n.webPush_statusNoneAvailable,
    PushDistributorStatus.notSelected => l10n.webPush_statusNotSelected,
    PushDistributorStatus.pending => l10n.webPush_statusPending,
    PushDistributorStatus.ready => l10n.webPush_statusReady,
    PushDistributorStatus.unavailable => l10n.webPush_statusUnavailable,
  };

  String description(AppLocalizations l10n) => switch (this) {
    PushDistributorStatus.noneAvailable => l10n.webPush_statusDescNoneAvailable,
    PushDistributorStatus.notSelected => l10n.webPush_statusDescNotSelected,
    PushDistributorStatus.pending => l10n.webPush_statusDescPending,
    PushDistributorStatus.ready => l10n.webPush_statusDescReady,
    PushDistributorStatus.unavailable => l10n.webPush_statusDescUnavailable,
  };

  bool get isProblem =>
      this == PushDistributorStatus.unavailable ||
      this == PushDistributorStatus.noneAvailable;
}

class _DistributorTile extends HookConsumerWidget {
  const _DistributorTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final status = ref.watch(pushStatusProvider);
    final mutation = ref.watch(pushDistributorMutationProvider);
    final isMutating = mutation.isLoading;

    return status.when(
      loading: () => ListTile(
        leading: const Icon(MdiIcons.bellBadgeOutline),
        title: Text(l10n.webPush_distributorTileTitle),
        subtitle: Text(l10n.webPush_checking),
      ),
      error: (error, _) => ListTile(
        leading: const Icon(MdiIcons.alertCircleOutline),
        title: Text(l10n.webPush_distributorTileTitle),
        subtitle: Text(l10n.webPush_couldNotReadStatus('$error')),
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
              title: Text(l10n.webPush_distributorTileTitle),
              subtitle: Text(
                isMutating
                    ? l10n.webPush_updatingDistributor
                    : current != null
                    ? '${current.label ?? current.packageName} — ${pushStatus.status.label(l10n)}'
                    : pushStatus.status.label(l10n),
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
                      ? pushStatus.status.description(l10n)
                      : l10n.webPush_registrationRecovering,
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
                    l10n.webPush_lastRegistrationError(failure),
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
                      isMutating
                          ? l10n.webPush_disablingWebPush
                          : l10n.webPush_disableWebPush,
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
    final l10n = AppLocalizations.of(context);

    if (pushStatus.available.isEmpty) {
      showErrorMessage(context, l10n.webPush_noDistributorInstalled);
      return;
    }

    final selected = await showDialog<PushDistributor>(
      context: context,
      anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
      builder: (context) => SimpleDialog(
        title: Text(l10n.webPush_chooseDistributorTitle),
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
        showInfoMessage(context, l10n.webPush_distributorConfigured);
      }
    } catch (error) {
      if (context.mounted) {
        showErrorMessage(
          context,
          l10n.webPush_couldNotConfigureDistributor('$error'),
        );
      }
    }
  }

  Future<void> _removeDistributor(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);

    try {
      await ref
          .read(pushDistributorMutationProvider.notifier)
          .removeDistributor();
      if (context.mounted) {
        showInfoMessage(context, l10n.webPush_webPushDisabled);
      }
    } catch (error) {
      if (context.mounted) {
        showErrorMessage(
          context,
          l10n.webPush_couldNotDisableWebPush('$error'),
        );
      }
    }
  }
}

class _NotificationPermissionTile extends HookConsumerWidget {
  const _NotificationPermissionTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isUpdating = useState(false);
    final granted = ref.watch(notificationPermissionGrantedProvider);
    final theme = Theme.of(context);

    useOnAppLifecycleStateChange((previous, current) {
      if (current == AppLifecycleState.resumed && !isUpdating.value) {
        ref.invalidate(notificationPermissionGrantedProvider);
      }
    });

    return granted.when(
      loading: () => ListTile(
        leading: const Icon(MdiIcons.bellBadgeOutline),
        title: Text(l10n.webPush_notificationPermissionTitle),
        subtitle: Text(l10n.webPush_checking),
      ),
      error: (error, _) => ListTile(
        leading: Icon(
          MdiIcons.alertCircleOutline,
          color: theme.colorScheme.error,
        ),
        title: Text(l10n.webPush_notificationPermissionTitle),
        subtitle: Text(
          l10n.webPush_notificationPermissionCouldNotRead('$error'),
        ),
      ),
      data: (isGranted) {
        if (isGranted) {
          return ListTile(
            leading: const Icon(MdiIcons.bellCheckOutline),
            title: Text(l10n.webPush_notificationPermissionTitle),
            subtitle: Text(l10n.webPush_notificationPermissionGranted),
          );
        }

        return ListTile(
          leading: Icon(
            MdiIcons.bellRemoveOutline,
            color: theme.colorScheme.error,
          ),
          title: Text(l10n.webPush_notificationPermissionTitle),
          subtitle: Text(
            l10n.webPush_notificationPermissionDenied,
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
                          l10n.webPush_couldNotUpdatePermission('$error'),
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
                : Text(l10n.webPush_grantAction),
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
    final l10n = AppLocalizations.of(context);
    final subscriptions = ref.watch(pushSubscriptionsProvider);
    final distributorReady =
        ref.watch(pushStatusProvider).value?.status ==
        PushDistributorStatus.ready;

    return subscriptions.when(
      loading: () => ListTile(
        leading: const SizedBox.square(
          dimension: 24,
          child: CircularProgressIndicator.adaptive(strokeWidth: 2),
        ),
        title: Text(l10n.webPush_loadingSubscriptions),
      ),
      error: (error, _) => ListTile(
        leading: const Icon(MdiIcons.alertCircleOutline),
        title: Text(l10n.webPush_couldNotReadSubscriptions),
        subtitle: Text('$error'),
      ),
      data: (items) {
        if (items.isEmpty) {
          return ListTile(
            leading: const Icon(MdiIcons.webOff),
            title: Text(l10n.webPush_noSiteSubscriptions),
            subtitle: Text(l10n.webPush_noSiteSubscriptionsDescription),
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
                            ? l10n.webPush_subscriptionActive
                            : l10n.webPush_subscriptionDelayedDelivery
                      : l10n.webPush_subscriptionWaitingForEndpoint,
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(l10n.webPush_revokeSubscriptionHint),
              ),
            ),
          ],
        );
      },
    );
  }
}
