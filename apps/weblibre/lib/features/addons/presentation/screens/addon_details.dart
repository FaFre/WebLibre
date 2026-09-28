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
import 'package:weblibre/core/design/display_features.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/addons/domain/providers.dart';
import 'package:weblibre/features/addons/extensions/addon_info.dart';
import 'package:weblibre/features/addons/presentation/screens/addon_internal_settings.dart';
import 'package:weblibre/features/addons/presentation/widgets/addon_ui.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/browser_addon.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/utils/number_format.dart';
import 'package:weblibre/utils/ui_helper.dart';

class AddonDetailsScreen extends ConsumerWidget {
  final String addonId;

  const AddonDetailsScreen({required this.addonId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final addonAsync = ref.watch(addonDetailsProvider(addonId));
    final addon = addonAsync.value;

    if (addonAsync.isLoading && addon == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (addon == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.addons_genericTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              addonAsync.error?.toString() ?? l10n.addons_notFound,
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
    final l10n = AppLocalizations.of(context);

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
            label: Text(l10n.addons_actionViewPermissions),
          ),
        ],
        const SizedBox(height: 16),
        Text(l10n.addons_sectionDetails, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        _DetailsCard(addon: addon),
        const SizedBox(height: 16),
        Text(
          l10n.addons_sectionDescription,
          style: theme.textTheme.titleMedium,
        ),
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
    final l10n = AppLocalizations.of(context);
    final addonAsync = ref.watch(addonDetailsProvider(addonId));
    final addon = addonAsync.value;

    return FilledButton.icon(
      onPressed: (addonAsync.isLoading || addon == null)
          ? null
          : () async {
              final displayName = addon.displayName;

              await ref.read(addonDetailsProvider(addonId).notifier).install();

              if (!context.mounted) return;

              showInfoMessage(
                context,
                l10n.addons_extensionInstalled(displayName),
              );
            },
      icon: const Icon(Icons.download),
      label: Text(l10n.addons_actionInstallExtension),
    );
  }
}

class _AddonHeader extends StatelessWidget {
  final AddonInfo addon;

  const _AddonHeader({required this.addon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

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
                                  ? (addon.isEnabled
                                        ? l10n.addons_statusInstalled
                                        : l10n.addons_statusDisabled)
                                  : l10n.addons_statusAvailable,
                            ),
                          ),
                          if (addon.isAllowedInPrivateBrowsing)
                            Chip(label: Text(l10n.addons_chipPrivateBrowsing)),
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
    final l10n = AppLocalizations.of(context);

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
      (_, _, false) => l10n.addons_autoUpdateGloballyDisabled,
      (true, _, true) => l10n.addons_autoUpdateNeedsManualRun,
      (false, true, true) => l10n.addons_autoUpdateAllow,
      (false, false, true) => l10n.addons_autoUpdateDisabledForExtension,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.addons_sectionManagement, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          child: Column(
            children: [
              if (addon.isSupported)
                SwitchListTile.adaptive(
                  title: Text(l10n.addons_switchEnabledTitle),
                  subtitle: Text(
                    addon.canUserToggleEnabled
                        ? l10n.addons_switchEnabledSubtitleAllow
                        : l10n.addons_switchEnabledSubtitleCannot,
                  ),
                  value: addon.isEnabled,
                  onChanged: addonAsync.isLoading || !addon.canUserToggleEnabled
                      ? null
                      : (enabled) => ref
                            .read(addonDetailsProvider(addonId).notifier)
                            .setEnabled(enabled: enabled),
                ),
              SwitchListTile.adaptive(
                title: Text(l10n.addons_switchPrivateBrowsingTitle),
                subtitle: Text(l10n.addons_switchPrivateBrowsingSubtitle),
                value: addon.isAllowedInPrivateBrowsing,
                onChanged: addonAsync.isLoading
                    ? null
                    : (allowed) => ref
                          .read(addonDetailsProvider(addonId).notifier)
                          .setAllowedInPrivateBrowsing(allowed: allowed),
              ),
              SwitchListTile.adaptive(
                title: Text(l10n.addons_switchAutoUpdateTitle),
                subtitle: Text(autoUpdateSubtitle),
                value: addon.isAutoUpdateEnabled,
                onChanged: canChangePerAddonAutoUpdate
                    ? (enabled) => ref
                          .read(addonDetailsProvider(addonId).notifier)
                          .setAutoUpdateEnabled(enabled: enabled)
                    : null,
              ),
              SwitchListTile.adaptive(
                title: Text(l10n.addons_switchPinTitle),
                subtitle: Text(l10n.addons_switchPinSubtitle),
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
                  title: Text(l10n.addons_menuExtensionSettingsTitle),
                  subtitle: Text(
                    addon.openOptionsPageInTab
                        ? l10n.addons_menuExtensionSettingsSubtitleTab
                        : l10n.addons_menuExtensionSettingsSubtitleInline,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => openAddonSettingsFlow(context, ref, addon),
                ),
              if (addon.id == 'uBlock0@raymondhill.net')
                ListTile(
                  leading: const Icon(Icons.filter_list),
                  title: Text(l10n.addons_menuFilterListsTitle),
                  subtitle: Text(l10n.addons_menuFilterListsSubtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => UBlockFilterListsRoute().push<void>(context),
                ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: Text(l10n.addons_permissionsTitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => AddonPermissionsRoute(
                  addonId: addon.id,
                ).push<void>(context),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(l10n.addons_actionRemoveExtension),
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

                        showInfoMessage(
                          context,
                          l10n.addons_extensionRemoved(displayName),
                        );
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
    anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
    builder: (context) {
      final l10n = AppLocalizations.of(context);

      return AlertDialog(
        title: Text(l10n.addons_removeConfirmTitle),
        content: Text(l10n.addons_removeConfirmContent(addon.displayName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.common_cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.common_remove),
          ),
        ],
      );
    },
  );
}

class _UpdatesSection extends ConsumerWidget {
  final String addonId;

  const _UpdatesSection({required this.addonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

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
        Text(l10n.addons_sectionUpdates, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formatUpdateAttemptStatus(context, updateAttempt)),
                const SizedBox(height: 8),
                if (hasAvailableUpdate) ...[
                  Text(
                    l10n.addons_updateAvailable(
                      addon.installedVersion ?? '',
                      availableVersion,
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  updateAttempt == null
                      ? l10n.addons_noUpdateAttemptYet
                      : l10n.addons_lastChecked(
                          formatUpdateAttemptDate(updateAttempt),
                        ),
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
                    checking
                        ? l10n.addons_actionCheckingForUpdates
                        : l10n.addons_actionCheckForUpdatesButton,
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
      _reportUpdateResult(
        context,
        result,
        fallback: AppLocalizations.of(context).addons_noUpdateAvailable,
      );
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
    anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
    builder: (context) {
      final l10n = AppLocalizations.of(context);

      return AlertDialog(
        title: Text(l10n.addons_updateAvailableDialogTitle),
        content: Text(
          l10n.addons_updateConfirmContent(
            addon.displayName,
            addon.installedVersion ?? '',
            availableVersion,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.addons_actionNotNow),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.addons_actionUpdate),
          ),
        ],
      );
    },
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
        AppLocalizations.of(context).addons_noRemoteUpdateSource,
      );
    case AddonUpdateRunFailed():
      showErrorMessage(
        context,
        AppLocalizations.of(context).addons_updateCheckFailed,
      );
  }
}

class _DescriptionCard extends ConsumerWidget {
  final AddonInfo addon;

  const _DescriptionCard({required this.addon});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final markdownAsync = ref.watch(addonDescriptionMarkdownProvider(addon.id));

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: markdownAsync.when(
          skipLoadingOnReload: true,
          data: (markdown) => markdown.isEmpty
              ? Text(l10n.addons_noDescriptionProvided)
              : MarkdownBody(
                  data: markdown,
                  selectable: true,
                  onTapLink: (text, href, title) async {
                    if (href != null && href.isNotEmpty) {
                      await launchUrl(Uri.parse(href));
                    }
                  },
                ),
          loading: () => Text(
            addon.description.isNotEmpty
                ? addon.description
                : l10n.addons_loadingDescription,
          ),
          error: (_, _) => Text(
            addon.description.isNotEmpty
                ? addon.description
                : l10n.addons_noDescriptionProvided,
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
    final l10n = AppLocalizations.of(context);

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Column(
        children: [
          if ((addon.authorName ?? '').isNotEmpty)
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(l10n.addons_fieldAuthor),
              subtitle: Text(addon.authorName!),
              onTap: (addon.authorUrl ?? '').isEmpty
                  ? null
                  : () => launchUrl(Uri.parse(addon.authorUrl!)),
            ),
          ListTile(
            leading: const Icon(Icons.tag_outlined),
            title: Text(l10n.addons_fieldVersion),
            subtitle: Text(addon.installedVersion ?? addon.version),
          ),
          ListTile(
            leading: const Icon(Icons.update_outlined),
            title: Text(l10n.addons_fieldLastUpdated),
            subtitle: Text(formatAddonDate(context, addon.updatedAt)),
          ),
          if (addon.homepageUrl.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.public),
              title: Text(l10n.addons_fieldHomepage),
              subtitle: Text(addon.homepageUrl),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => launchUrl(Uri.parse(addon.homepageUrl)),
            ),
          if (addon.detailUrl.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.storefront_outlined),
              title: Text(l10n.addons_fieldAddonListing),
              subtitle: Text(addon.detailUrl),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => launchUrl(Uri.parse(addon.detailUrl)),
            ),
        ],
      ),
    );
  }
}
