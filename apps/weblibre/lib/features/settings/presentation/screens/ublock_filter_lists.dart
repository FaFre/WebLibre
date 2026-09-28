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
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weblibre/core/design/display_features.dart';
import 'package:weblibre/features/settings/presentation/utils/ublock_asset_group_l10n.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/ublock_asset.dart';
import 'package:weblibre/features/user/data/models/ublock_filter_list_settings.dart';
import 'package:weblibre/features/user/data/providers/ublock_assets.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/widgets/uri_breadcrumb.dart';
import 'package:weblibre/utils/form_validators.dart';

typedef _SettingsMutator =
    Future<void> Function(
      UBlockFilterListSettings Function(UBlockFilterListSettings current)
      mutator,
    );

class UBlockFilterListsScreen extends HookConsumerWidget {
  const UBlockFilterListsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(
      engineSettingsWithDefaultsProvider.select(
        (value) => value.ublockFilterListSettings,
      ),
    );

    final registryAsync = ref.watch(ublockAssetsRegistryProvider);
    final registryReady = registryAsync.hasValue;

    Future<void> updateSettingsImpl(
      UBlockFilterListSettings Function(UBlockFilterListSettings current)
      mutator,
    ) async {
      await ref
          .read(engineSettingsRepositoryProvider.notifier)
          .updateSettings(
            (currentSettings) =>
                currentSettings.copyWith.ublockFilterListSettings(
                  mutator(currentSettings.ublockFilterListSettings),
                ),
          );
    }

    // Sync regional auto-tokens when registry becomes available so that an
    // auto-select switch displayed as "on" actually reflects in the enabled
    // lists. Without this fix-up, users would have to toggle the switch
    // off and on for the regional tokens to take effect.
    useEffect(
      () {
        if (!registryReady) return null;
        if (!settings.enabled) return null;
        if (!settings.autoSelectRegionalLists) return null;
        final registry = registryAsync.value!;
        final langCodes = WidgetsBinding.instance.platformDispatcher.locales
            .map((l) => l.toLanguageTag())
            .toList();
        final expected = registry.tokensMatchingLocales(langCodes);
        final current = settings.autoEnabledStockListTokens;
        final same =
            expected.length == current.length &&
            expected.toSet().containsAll(current);
        if (!same) {
          unawaited(
            Future.microtask(
              () => updateSettingsImpl(
                (c) => c.copyWith.autoEnabledStockListTokens(expected),
              ),
            ),
          );
        }
        return null;
      },
      [
        registryReady,
        settings.enabled,
        settings.autoSelectRegionalLists,
        settings.autoEnabledStockListTokens,
      ],
    );

    final updateSettings = updateSettingsImpl;

    Future<void> enableManagement(UBlockFilterListSettings current) async {
      final registry = registryAsync.value!;

      if (!current.enabled &&
          current.enabledStockListTokens.isEmpty &&
          current.autoEnabledStockListTokens.isEmpty &&
          current.externalFilterLists.isEmpty) {
        await updateSettings(
          (_) => UBlockFilterListSettings.managedDefaults(registry),
        );
      } else {
        await updateSettings((c) => c.copyWith.enabled(true));
      }
    }

    Future<void> resetToDefaults() async {
      final registry = registryAsync.value!;
      await updateSettings(
        (_) => UBlockFilterListSettings.managedDefaults(registry),
      );
    }

    Future<void> applyWebLibreHardenings() async {
      await updateSettings((current) {
        final tokens = [...current.enabledStockListTokens];
        for (final token in kUBlockHardeningStockTokens) {
          if (!tokens.contains(token) &&
              !current.autoEnabledStockListTokens.contains(token)) {
            tokens.add(token);
          }
        }
        final externals = [...current.externalFilterLists];
        final existingUrls = externals.map((e) => e.url).toSet();
        for (final entry in kUBlockHardeningExternalLists) {
          if (!existingUrls.contains(entry.url) &&
              externals.length < kUBlockMaxExternalUrls) {
            externals.add(entry);
            existingUrls.add(entry.url);
          }
        }
        return current.copyWith(
          enabledStockListTokens: tokens,
          externalFilterLists: externals,
        );
      });
    }

    Future<void> enableAutoSelect() async {
      final registry = registryAsync.value!;
      final langCodes = WidgetsBinding.instance.platformDispatcher.locales
          .map((l) => l.toLanguageTag())
          .toList();
      final autoTokens = registry.tokensMatchingLocales(langCodes);

      await updateSettings(
        (c) => c.copyWith(
          autoSelectRegionalLists: true,
          autoEnabledStockListTokens: autoTokens,
        ),
      );
    }

    final search = useSettingsSearch();

    return SettingsCustomScrollScaffold(
      title: l10n.settings_ublockListsTitle,
      searchController: search.controller,
      searchHintText: l10n.settings_ublockListsSearchHint,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                _SectionHeader(label: l10n.settings_ublockSectionManagement),
                _ManagementCard(
                  settings: settings,
                  registryReady: registryReady,
                  onToggleManagement: (value) async {
                    if (!value) {
                      await updateSettings((c) => c.copyWith.enabled(false));
                      return;
                    }
                    await enableManagement(settings);
                  },
                  onToggleAutoSelect: (value) async {
                    if (value) {
                      await enableAutoSelect();
                    } else {
                      await updateSettings(
                        (c) => c.copyWith(
                          autoSelectRegionalLists: false,
                          autoEnabledStockListTokens: [],
                        ),
                      );
                    }
                  },
                ),
                if (settings.enabled) ...[
                  const SizedBox(height: 24),
                  _SectionHeader(
                    label: l10n.settings_ublockSectionQuickActions,
                  ),
                  _QuickActionsCard(
                    enabled: registryReady,
                    onResetDefaults: () => _confirmAndRun(
                      context,
                      title: l10n.settings_ublockResetDialogTitle,
                      message: l10n.settings_ublockResetDialogMessage,
                      confirmLabel: l10n.common_reset,
                      action: resetToDefaults,
                    ),
                    onApplyHardenings: () => _confirmAndRun(
                      context,
                      title: l10n.settings_ublockApplyHardeningsDialogTitle,
                      message: l10n.settings_ublockApplyHardeningsDialogMessage,
                      confirmLabel: l10n.settings_actionApply,
                      action: applyWebLibreHardenings,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                _SectionHeader(label: l10n.settings_ublockSectionFilterLists),
                _InfoBanner(message: l10n.settings_ublockInfoBannerMessage),
                registryAsync.when(
                  data: (registry) => _FilterListGroups(
                    registry: registry,
                    settings: settings,
                    onUpdate: updateSettings,
                    query: search.normalizedQuery,
                  ),
                  loading: () => const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(l10n.settings_ublockLoadFailed('$error')),
                  ),
                ),
                const SizedBox(height: 24),
                _SectionHeader(label: l10n.settings_ublockSectionExternalLists),
                _ExternalListsCard(
                  settings: settings,
                  onUpdate: updateSettings,
                  query: search.normalizedQuery,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> _confirmAndRun(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  required Future<void> Function() action,
}) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.common_cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  if (confirmed == true) {
    await action();
  }
}

class _QuickActionsCard extends StatelessWidget {
  final bool enabled;
  final VoidCallback onResetDefaults;
  final VoidCallback onApplyHardenings;

  const _QuickActionsCard({
    required this.enabled,
    required this.onResetDefaults,
    required this.onApplyHardenings,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      color: colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.restart_alt),
            title: Text(l10n.settings_ublockQuickResetTitle),
            subtitle: Text(l10n.settings_ublockQuickResetSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: enabled ? onResetDefaults : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              height: 1,
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: Text(l10n.settings_ublockQuickApplyHardeningsTitle),
            subtitle: Text(l10n.settings_ublockQuickApplyHardeningsSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: enabled ? onApplyHardenings : null,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8, top: 8),
      child: Text(
        label,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String message;

  const _InfoBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: colorScheme.onSecondaryContainer),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManagementCard extends StatelessWidget {
  final UBlockFilterListSettings settings;
  final bool registryReady;
  final ValueChanged<bool> onToggleManagement;
  final ValueChanged<bool> onToggleAutoSelect;

  const _ManagementCard({
    required this.settings,
    required this.registryReady,
    required this.onToggleManagement,
    required this.onToggleAutoSelect,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final showAutoSelect = settings.enabled;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      color: colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          SwitchListTile.adaptive(
            title: Text(l10n.settings_ublockManageTitle),
            subtitle: Text(l10n.settings_ublockManageSubtitle),
            value: settings.enabled,
            onChanged: !registryReady ? null : onToggleManagement,
          ),
          if (!settings.enabled)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.settings_ublockManageHint,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          if (showAutoSelect) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(
                height: 1,
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            SwitchListTile.adaptive(
              title: Text(l10n.settings_ublockAutoSelectTitle),
              subtitle: Text(l10n.settings_ublockAutoSelectSubtitle),
              value: settings.autoSelectRegionalLists,
              onChanged: !registryReady ? null : onToggleAutoSelect,
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterListGroups extends StatelessWidget {
  final UBlockAssetsRegistry registry;
  final UBlockFilterListSettings settings;
  final _SettingsMutator onUpdate;
  final String query;

  const _FilterListGroups({
    required this.registry,
    required this.settings,
    required this.onUpdate,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    final groupedTree = registry.buildGroupedParentTree();
    final enabledTokens = {
      ...settings.enabledStockListTokens,
      ...settings.autoEnabledStockListTokens,
    };
    final autoTokens = settings.autoEnabledStockListTokens.toSet();

    Future<void> toggle(String token, bool value) async {
      await onUpdate((current) {
        if (value) {
          final manual = [...current.enabledStockListTokens, token];
          return current.copyWith.enabledStockListTokens(manual);
        }
        final manual = [...current.enabledStockListTokens]..remove(token);
        final auto = [...current.autoEnabledStockListTokens]..remove(token);
        return current.copyWith(
          enabledStockListTokens: manual,
          autoEnabledStockListTokens: auto,
        );
      });
    }

    return Column(
      children: [
        for (final group in UBlockAssetGroup.displayOrder)
          if (groupedTree.containsKey(group))
            _GroupCard(
              group: group,
              parentTree: groupedTree[group]!,
              registry: registry,
              enabledTokens: enabledTokens,
              autoTokens: autoTokens,
              managementEnabled: settings.enabled,
              onToggle: toggle,
              query: query,
            ),
      ],
    );
  }
}

class _CountPill extends StatelessWidget {
  final int enabled;
  final int total;
  final bool primary;

  const _CountPill({
    required this.enabled,
    required this.total,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: primary
            ? colorScheme.primaryContainer
            : colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$enabled/$total',
        style: TextStyle(
          color: primary
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final UBlockAssetGroup group;
  final Map<String?, List<String>> parentTree;
  final UBlockAssetsRegistry registry;
  final Set<String> enabledTokens;
  final Set<String> autoTokens;
  final bool managementEnabled;
  final String query;
  final Future<void> Function(String token, bool value) onToggle;

  const _GroupCard({
    required this.group,
    required this.parentTree,
    required this.registry,
    required this.enabledTokens,
    required this.autoTokens,
    required this.managementEnabled,
    required this.query,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Callers pass `search.normalizedQuery` so trimming/lowercasing already happened.
    final groupMatches =
        query.isEmpty || group.label(context).toLowerCase().contains(query);
    final filteredParentTree = <String?, List<String>>{};

    for (final entry in parentTree.entries) {
      final parentMatches =
          groupMatches || (entry.key?.toLowerCase().contains(query) ?? false);
      final filteredTokens = entry.value.where((tokenKey) {
        if (query.isEmpty || parentMatches) return true;
        final asset = registry[tokenKey];
        if (asset == null) return false;
        return matchesSettingsSearch(query, [
          tokenKey,
          if (asset.title != null) asset.title!,
          if (asset.tags != null) asset.tags!,
          if (asset.supportURL != null) asset.supportURL!,
        ]);
      }).toList();

      if (filteredTokens.isNotEmpty) {
        filteredParentTree[entry.key] = filteredTokens;
      }
    }

    if (filteredParentTree.isEmpty) {
      return const SizedBox.shrink();
    }

    final allTokens = filteredParentTree.values.expand((l) => l).toList();
    final totalCount = allTokens.length;
    final enabledCount = allTokens.where(enabledTokens.contains).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      color: colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: group == UBlockAssetGroup.$default,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Text(
            group.label(context),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          trailing: _CountPill(
            enabled: enabledCount,
            total: totalCount,
            primary: true,
          ),
          children: [
            ColoredBox(
              color: colorScheme.surfaceContainerLow,
              child: Column(
                children: [
                  for (final entry in filteredParentTree.entries)
                    if (entry.key != null)
                      _SubGroupTile(
                        parentTitle: entry.key!,
                        tokenKeys: entry.value,
                        registry: registry,
                        enabledTokens: enabledTokens,
                        autoTokens: autoTokens,
                        managementEnabled: managementEnabled,
                        onToggle: onToggle,
                        depth: 1,
                      )
                    else
                      for (final tokenKey in entry.value)
                        _FilterListTile(
                          tokenKey: tokenKey,
                          entry: registry[tokenKey]!,
                          isEnabled: enabledTokens.contains(tokenKey),
                          isAuto: autoTokens.contains(tokenKey),
                          managementEnabled: managementEnabled,
                          onToggle: onToggle,
                          depth: 1,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubGroupTile extends StatelessWidget {
  final String parentTitle;
  final List<String> tokenKeys;
  final UBlockAssetsRegistry registry;
  final Set<String> enabledTokens;
  final Set<String> autoTokens;
  final bool managementEnabled;
  final int depth;
  final Future<void> Function(String token, bool value) onToggle;

  const _SubGroupTile({
    required this.parentTitle,
    required this.tokenKeys,
    required this.registry,
    required this.enabledTokens,
    required this.autoTokens,
    required this.managementEnabled,
    required this.onToggle,
    required this.depth,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final enabledCount = tokenKeys.where(enabledTokens.contains).length;
    final indent = 16.0 + (depth * 12.0);

    return Column(
      children: [
        Divider(
          height: 1,
          indent: indent,
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
        ColoredBox(
          color: colorScheme.surfaceContainer,
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.only(left: indent, right: 16),
              title: Text(
                parentTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              trailing: _CountPill(
                enabled: enabledCount,
                total: tokenKeys.length,
                primary: false,
              ),
              children: [
                for (final tokenKey in tokenKeys)
                  _FilterListTile(
                    tokenKey: tokenKey,
                    entry: registry[tokenKey]!,
                    isEnabled: enabledTokens.contains(tokenKey),
                    isAuto: autoTokens.contains(tokenKey),
                    managementEnabled: managementEnabled,
                    onToggle: onToggle,
                    depth: depth + 1,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterListTile extends StatelessWidget {
  final String tokenKey;
  final UBlockAssetEntry entry;
  final bool isEnabled;
  final bool isAuto;
  final bool managementEnabled;
  final int depth;
  final Future<void> Function(String token, bool value) onToggle;

  const _FilterListTile({
    required this.tokenKey,
    required this.entry,
    required this.isEnabled,
    required this.isAuto,
    required this.managementEnabled,
    required this.onToggle,
    required this.depth,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final supportUrl = entry.supportURL;
    final hasLink = supportUrl != null;
    final indent = 16.0 + (depth * 12.0);

    return Column(
      children: [
        if (depth > 1)
          Divider(
            height: 1,
            indent: indent,
            color: colorScheme.outlineVariant.withValues(alpha: 0.2),
          ),
        ListTile(
          contentPadding: EdgeInsets.only(left: indent, right: 8),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  entry.title ?? tokenKey,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              if (isAuto)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Tooltip(
                    message: l10n.settings_ublockAutoSelectedTooltip,
                    child: Icon(
                      Icons.language,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              if (entry.isDefaultEnabled && !isEnabled)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Tooltip(
                    message: l10n.settings_ublockDefaultOnTooltip,
                    child: Icon(
                      Icons.recommend_outlined,
                      size: 16,
                      color: colorScheme.outline,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: entry.tags != null
              ? Text(
                  entry.tags!,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                )
              : null,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasLink)
                IconButton(
                  icon: const Icon(Icons.open_in_new, size: 18),
                  color: colorScheme.onSurfaceVariant,
                  tooltip: l10n.settings_ublockVisitSupportTooltip,
                  visualDensity: VisualDensity.compact,
                  onPressed: () => launchUrl(Uri.parse(supportUrl)),
                ),
              Switch.adaptive(
                value: isEnabled,
                onChanged: managementEnabled
                    ? (value) => onToggle(tokenKey, value)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExternalListsCard extends StatelessWidget {
  final UBlockFilterListSettings settings;
  final _SettingsMutator onUpdate;
  final String query;

  const _ExternalListsCard({
    required this.settings,
    required this.onUpdate,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final lists = settings.externalFilterLists;
    // Callers pass `search.normalizedQuery`.
    final filteredLists = lists.where((entry) {
      if (query.isEmpty) return true;
      return matchesSettingsSearch(query, [
        entry.url,
        if (entry.description != null) entry.description!,
      ]);
    }).toList();
    final canAdd = settings.enabled && lists.length < kUBlockMaxExternalUrls;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      color: colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.settings_ublockExternalListsHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          if (lists.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(l10n.settings_ublockNoExternalLists),
              ),
            )
          else if (filteredLists.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(l10n.settings_ublockNoExternalListsMatch(query)),
              ),
            )
          else
            for (var i = 0; i < filteredLists.length; i++) ...[
              if (i > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(
                    height: 1,
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
              _ExternalListRow(
                index: lists.indexOf(filteredLists[i]),
                entry: filteredLists[i],
                allEntries: lists,
                enabled: settings.enabled,
                onUpdate: onUpdate,
              ),
            ],
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                icon: const Icon(Icons.add),
                label: Text(l10n.settings_ublockAddExternalListButton),
                onPressed: !canAdd
                    ? null
                    : () async {
                        final result = await _promptForExternalList(
                          context,
                          existing: lists,
                        );
                        if (result == null) return;
                        await onUpdate((current) {
                          final updated = [
                            ...current.externalFilterLists,
                            result,
                          ];
                          return current.copyWith.externalFilterLists(updated);
                        });
                      },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExternalListRow extends StatelessWidget {
  final int index;
  final UBlockExternalList entry;
  final List<UBlockExternalList> allEntries;
  final bool enabled;
  final _SettingsMutator onUpdate;

  const _ExternalListRow({
    required this.index,
    required this.entry,
    required this.allEntries,
    required this.enabled,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasDescription =
        entry.description != null && entry.description!.trim().isNotEmpty;
    final uri = Uri.tryParse(entry.url);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasDescription ? entry.description!.trim() : entry.url,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (hasDescription && uri != null) ...[
                  const SizedBox(height: 4),
                  UriBreadcrumb(
                    uri: uri,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            color: colorScheme.onSurfaceVariant,
            tooltip: l10n.common_edit,
            visualDensity: VisualDensity.compact,
            onPressed: enabled
                ? () async {
                    final result = await _promptForExternalList(
                      context,
                      existing: allEntries,
                      initial: entry,
                    );
                    if (result == null) return;
                    await onUpdate((current) {
                      final updated = [...current.externalFilterLists];
                      updated[index] = result;
                      return current.copyWith.externalFilterLists(updated);
                    });
                  }
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: colorScheme.onSurfaceVariant,
            tooltip: l10n.common_remove,
            visualDensity: VisualDensity.compact,
            onPressed: enabled
                ? () async {
                    await onUpdate((current) {
                      final updated = [...current.externalFilterLists]
                        ..removeAt(index);
                      return current.copyWith.externalFilterLists(updated);
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

Future<UBlockExternalList?> _promptForExternalList(
  BuildContext context, {
  required List<UBlockExternalList> existing,
  UBlockExternalList? initial,
}) {
  return showDialog<UBlockExternalList>(
    context: context,
    anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
    builder: (context) =>
        _ExternalListDialog(existing: existing, initial: initial),
  );
}

class _ExternalListDialog extends HookWidget {
  final List<UBlockExternalList> existing;
  final UBlockExternalList? initial;

  const _ExternalListDialog({required this.existing, this.initial});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final urlController = useTextEditingController(text: initial?.url ?? '');
    final descriptionController = useTextEditingController(
      text: initial?.description ?? '',
    );
    final isEdit = initial != null;

    return AlertDialog(
      title: Text(
        isEdit
            ? l10n.settings_ublockEditListDialogTitle
            : l10n.settings_ublockAddListDialogTitle,
      ),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: urlController,
              autofocus: !isEdit,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                labelText: l10n.settings_ublockListUrlLabel,
                hintText: 'https://example.com/list.txt',
              ),
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                final urlError = validateUrl(
                  trimmed,
                  onlyHttpProtocol: true,
                  eagerParsing: false,
                  l10n: l10n,
                );
                if (urlError != null) return urlError;
                final clash = existing.any(
                  (e) => e.url == trimmed && e.url != initial?.url,
                );
                if (clash) {
                  return l10n.settings_ublockListUrlAlreadyAdded;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: descriptionController,
              autofocus: isEdit,
              maxLength: 80,
              decoration: InputDecoration(
                labelText: l10n.settings_ublockDescriptionLabel,
                hintText: l10n.settings_ublockDescriptionHint,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.common_cancel),
        ),
        FilledButton(
          onPressed: () {
            if (formKey.currentState?.validate() == true) {
              final desc = descriptionController.text.trim();
              Navigator.of(context).pop(
                UBlockExternalList(
                  url: urlController.text.trim(),
                  description: desc.isEmpty ? null : desc,
                ),
              );
            }
          },
          child: Text(isEdit ? l10n.common_save : l10n.common_add),
        ),
      ],
    );
  }
}
