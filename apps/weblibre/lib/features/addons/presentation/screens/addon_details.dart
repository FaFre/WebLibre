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
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/addons/domain/providers.dart';
import 'package:weblibre/features/addons/extensions/addon_info.dart';
import 'package:weblibre/features/addons/presentation/screens/addon_internal_settings.dart';
import 'package:weblibre/features/addons/presentation/widgets/addon_ui.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/browser_addon.dart';
import 'package:weblibre/utils/number_format.dart';
import 'package:weblibre/utils/ui_helper.dart';

class AddonDetailsScreen extends ConsumerWidget {
  final String addonId;

  const AddonDetailsScreen({required this.addonId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addonAsync = ref.watch(addonDetailsProvider(addonId));
    final addon = addonAsync.value;

    if (addonAsync.isLoading && addon == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (addon == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Extension')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              addonAsync.error?.toString() ??
                  'This extension could not be found.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(addon.displayName),
        actions: [
          IconButton(
            onPressed: addonAsync.isLoading
                ? null
                : ref.read(addonDetailsProvider(addonId).notifier).refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: ref.read(addonDetailsProvider(addonId).notifier).refresh,
        child: _AddonDetailsBody(addonId: addonId),
      ),
    );
  }
}

class _AddonDetailsBody extends ConsumerWidget {
  final String addonId;

  const _AddonDetailsBody({required this.addonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final addon = ref.watch(
      addonDetailsProvider(addonId).select((value) => value.value),
    );
    if (addon == null) return const SizedBox.shrink();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _AddonHeader(addon: addon),
        const SizedBox(height: 16),
        if (addon.isInstalled) ...[
          _ManagementSection(addonId: addonId),
          const SizedBox(height: 16),
          _UpdatesSection(addonId: addonId),
        ] else ...[
          _InstallButton(addonId: addonId),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () =>
                AddonPermissionsRoute(addonId: addon.id).push<void>(context),
            icon: const Icon(Icons.privacy_tip_outlined),
            label: const Text('View Permissions'),
          ),
        ],
        const SizedBox(height: 16),
        Text('Details', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        _DetailsCard(addon: addon),
        const SizedBox(height: 16),
        Text('Description', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        _DescriptionCard(addon: addon),
      ],
    );
  }
}

class _InstallButton extends ConsumerWidget {
  final String addonId;

  const _InstallButton({required this.addonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addonAsync = ref.watch(addonDetailsProvider(addonId));
    final addon = addonAsync.value;

    return FilledButton.icon(
      onPressed: (addonAsync.isLoading || addon == null)
          ? null
          : () async {
              final displayName = addon.displayName;

              await ref.read(addonDetailsProvider(addonId).notifier).install();

              if (!context.mounted) return;

              showInfoMessage(context, '$displayName installed');
            },
      icon: const Icon(Icons.download),
      label: const Text('Install Extension'),
    );
  }
}

class _AddonHeader extends StatelessWidget {
  final AddonInfo addon;

  const _AddonHeader({required this.addon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AddonIconView(addon: addon, size: 56),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        addon.displayName,
                        style: theme.textTheme.headlineSmall,
                      ),
                      if ((addon.summary ?? '').isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(addon.summary!),
                      ],
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
                          Chip(
                            label: Text(
                              addon.isInstalled
                                  ? (addon.isEnabled ? 'Installed' : 'Disabled')
                                  : 'Available',
                            ),
                          ),
                          if (addon.isAllowedInPrivateBrowsing)
                            const Chip(label: Text('Private Browsing')),
                          if (addon.ratingAverage != null)
                            Chip(
                              avatar: const Icon(Icons.star, size: 18),
                              label: Text(
                                '${addon.ratingAverage!.toStringAsFixed(1)}'
                                ' (${formatCompactNumber(addon.ratingReviews ?? 0)})',
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AddonStatusBanner(addon: addon),
          ],
        ),
      ),
    );
  }
}

class _ManagementSection extends ConsumerWidget {
  final String addonId;

  const _ManagementSection({required this.addonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final addonAsync = ref.watch(addonDetailsProvider(addonId));
    final addon = addonAsync.value;

    if (addon == null) return const SizedBox.shrink();

    final globalAutoUpdate = ref.watch(addonAutoUpdateProvider);
    final isLocalFileInstalled = addon.isLocalFileInstalled;

    final isPinned = ref.watch(pinnedAddonIdsProvider).contains(addonId);

    final (
      globalAutoUpdateEnabled,
      canChangePerAddonAutoUpdate,
    ) = globalAutoUpdate.when(
      data: (enabled) =>
          (enabled, !addonAsync.isLoading && enabled && !isLocalFileInstalled),
      loading: () => (true, false),
      error: (_, _) => (true, false),
    );

    final autoUpdateSubtitle = switch ((
      isLocalFileInstalled,
      addon.isAutoUpdateEnabled,
      globalAutoUpdateEnabled,
    )) {
      (_, _, false) => 'Global automatic updates are disabled.',
      (true, _, true) =>
        'Run a manual update once and restart the app before automatic updates can be enabled.',
      (false, true, true) =>
        'Allow this extension to receive background updates.',
      (false, false, true) =>
        'Background updates are disabled for this extension.',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Management', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          child: Column(
            children: [
              if (addon.isSupported)
                SwitchListTile.adaptive(
                  title: const Text('Enabled'),
                  subtitle: Text(
                    addon.canUserToggleEnabled
                        ? 'Allow this extension to run in WebLibre.'
                        : 'This extension cannot be safely enabled.',
                  ),
                  value: addon.isEnabled,
                  onChanged: addonAsync.isLoading || !addon.canUserToggleEnabled
                      ? null
                      : (enabled) => ref
                            .read(addonDetailsProvider(addonId).notifier)
                            .setEnabled(enabled: enabled),
                ),
              SwitchListTile.adaptive(
                title: const Text('Allow in Private Browsing'),
                subtitle: const Text(
                  'Let this extension run in private browsing tabs.',
                ),
                value: addon.isAllowedInPrivateBrowsing,
                onChanged: addonAsync.isLoading
                    ? null
                    : (allowed) => ref
                          .read(addonDetailsProvider(addonId).notifier)
                          .setAllowedInPrivateBrowsing(allowed: allowed),
              ),
              SwitchListTile.adaptive(
                title: const Text('Automatic updates'),
                subtitle: Text(autoUpdateSubtitle),
                value: addon.isAutoUpdateEnabled,
                onChanged: canChangePerAddonAutoUpdate
                    ? (enabled) => ref
                          .read(addonDetailsProvider(addonId).notifier)
                          .setAutoUpdateEnabled(enabled: enabled)
                    : null,
              ),
              SwitchListTile.adaptive(
                title: const Text('Pin to toolbar'),
                subtitle: const Text(
                  'Show this extension as an icon in the main tab bar.',
                ),
                value: isPinned,
                onChanged: (pinned) {
                  ref
                      .read(pinnedAddonIdsProvider.notifier)
                      .setPinned(addonId, pinned: pinned);
                },
              ),
              if (addon.hasOptionsPage)
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Extension Settings'),
                  subtitle: Text(
                    addon.openOptionsPageInTab
                        ? 'Open the extension options page in a browser tab'
                        : 'Open the extension options page',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => openAddonSettingsFlow(context, ref, addon),
                ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Permissions'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => AddonPermissionsRoute(
                  addonId: addon.id,
                ).push<void>(context),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Remove Extension'),
                textColor: theme.colorScheme.error,
                iconColor: theme.colorScheme.error,
                onTap: addonAsync.isLoading
                    ? null
                    : () async {
                        final confirmed = await _showConfirmUninstallDialog(
                          context,
                          addon,
                        );
                        if (confirmed != true || !context.mounted) return;

                        final displayName = addon.displayName;
                        await ref
                            .read(addonDetailsProvider(addonId).notifier)
                            .uninstall();
                        if (!context.mounted) return;

                        showInfoMessage(context, '$displayName removed');
                        Navigator.of(context).pop();
                      },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<bool?> _showConfirmUninstallDialog(
  BuildContext context,
  AddonInfo addon,
) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Remove extension?'),
      content: Text('Remove ${addon.displayName} from WebLibre?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Remove'),
        ),
      ],
    ),
  );
}

class _UpdatesSection extends ConsumerWidget {
  final String addonId;

  const _UpdatesSection({required this.addonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final addon = ref.watch(addonDetailsProvider(addonId)).value;
    if (addon == null) return const SizedBox.shrink();

    final storeInfo = ref.watch(addonStoreInfoProvider(addonId)).value;
    final updateAttempt = ref
        .watch(lastAddonUpdateAttemptProvider(addonId))
        .value;
    final checking = ref.watch(addonUpdateCheckProvider(addonId)).isLoading;

    final availableVersion = _displayAvailableVersion(addon, storeInfo);
    final hasAvailableUpdate =
        addon.installedVersion != null &&
        availableVersion.isNotEmpty &&
        addon.installedVersion != availableVersion;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Updates', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formatUpdateAttemptStatus(updateAttempt)),
                const SizedBox(height: 8),
                if (hasAvailableUpdate) ...[
                  Text(
                    'Update available: ${addon.installedVersion} \u2192 $availableVersion',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  updateAttempt == null
                      ? 'No recent update attempt information is available yet.'
                      : 'Last checked: ${formatUpdateAttemptDate(updateAttempt)}',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: checking
                      ? null
                      : () => _runUpdateCheck(context, ref, addonId),
                  icon: checking
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.system_update_alt),
                  label: Text(
                    checking ? 'Checking for Updates' : 'Check for Updates',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

String _displayAvailableVersion(AddonInfo addon, AddonStoreInfo? storeInfo) {
  final latest = storeInfo?.latestVersion.trim();
  return (latest != null && latest.isNotEmpty) ? latest : addon.version;
}

Future<void> _runUpdateCheck(
  BuildContext context,
  WidgetRef ref,
  String addonId,
) async {
  final outcome = await ref
      .read(addonUpdateCheckProvider(addonId).notifier)
      .resolveAvailableUpdate();

  if (!context.mounted) return;

  switch (outcome) {
    case AddonUpdateOutcomeMissing():
      return;
    case AddonUpdateOutcomeUpToDate():
      final result = await ref
          .read(addonUpdateCheckProvider(addonId).notifier)
          .triggerAndAwait();
      if (!context.mounted) return;
      _reportUpdateResult(context, result, fallback: 'No update available');
    case AddonUpdateOutcomeAvailable(
      addon: final fresh,
      :final availableVersion,
    ):
      final confirmed = await _confirmUpdateDialog(
        context,
        fresh,
        availableVersion,
      );
      if (confirmed != true || !context.mounted) return;

      final result = await ref
          .read(addonUpdateCheckProvider(addonId).notifier)
          .triggerAndAwait();
      if (!context.mounted) return;
      _reportUpdateResult(context, result);
  }
}

Future<bool?> _confirmUpdateDialog(
  BuildContext context,
  AddonInfo addon,
  String availableVersion,
) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Update available'),
      content: Text(
        'Update ${addon.displayName} from '
        '${addon.installedVersion} to $availableVersion?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Not now'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Update'),
        ),
      ],
    ),
  );
}

void _reportUpdateResult(
  BuildContext context,
  AddonUpdateRunResult result, {
  String? fallback,
}) {
  switch (result) {
    case AddonUpdateRunDone(:final message):
      final text = (message != null && message.isNotEmpty) ? message : fallback;
      if (text != null) showInfoMessage(context, text);
    case AddonUpdateRunNoRemoteSource():
      showErrorMessage(
        context,
        'This locally installed extension has no remote update source.',
      );
    case AddonUpdateRunFailed():
      showErrorMessage(context, 'Failed to start update check.');
  }
}

class _DescriptionCard extends ConsumerWidget {
  final AddonInfo addon;

  const _DescriptionCard({required this.addon});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final markdownAsync = ref.watch(addonDescriptionMarkdownProvider(addon.id));

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: markdownAsync.when(
          skipLoadingOnReload: true,
          data: (markdown) => markdown.isEmpty
              ? const Text('No description provided.')
              : MarkdownBody(
                  data: markdown,
                  selectable: true,
                  onTapLink: (text, href, title) {
                    if (href != null && href.isNotEmpty) {
                      launchUrl(Uri.parse(href));
                    }
                  },
                ),
          loading: () => Text(
            addon.description.isNotEmpty
                ? addon.description
                : 'Loading description…',
          ),
          error: (_, _) => Text(
            addon.description.isNotEmpty
                ? addon.description
                : 'No description provided.',
          ),
        ),
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final AddonInfo addon;

  const _DetailsCard({required this.addon});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Column(
        children: [
          if ((addon.authorName ?? '').isNotEmpty)
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Author'),
              subtitle: Text(addon.authorName!),
              onTap: (addon.authorUrl ?? '').isEmpty
                  ? null
                  : () => launchUrl(Uri.parse(addon.authorUrl!)),
            ),
          ListTile(
            leading: const Icon(Icons.tag_outlined),
            title: const Text('Version'),
            subtitle: Text(addon.installedVersion ?? addon.version),
          ),
          ListTile(
            leading: const Icon(Icons.update_outlined),
            title: const Text('Last Updated'),
            subtitle: Text(formatAddonDate(addon.updatedAt)),
          ),
          if (addon.homepageUrl.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.public),
              title: const Text('Homepage'),
              subtitle: Text(addon.homepageUrl),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => launchUrl(Uri.parse(addon.homepageUrl)),
            ),
          if (addon.detailUrl.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.storefront_outlined),
              title: const Text('Addon Listing'),
              subtitle: Text(addon.detailUrl),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => launchUrl(Uri.parse(addon.detailUrl)),
            ),
        ],
      ),
    );
  }
}
