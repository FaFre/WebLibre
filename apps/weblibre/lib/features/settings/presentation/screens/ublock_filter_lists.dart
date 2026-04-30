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

import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/ublock_asset.dart';
import 'package:weblibre/features/user/data/models/ublock_filter_list_settings.dart';
import 'package:weblibre/features/user/data/providers/ublock_assets.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
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

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(title: const Text('uBlock Filter Lists')),
      body: SafeArea(
        child: FadingScroll(
          fadingSize: 25,
          builder: (context, controller) {
            return ListView(
              controller: controller,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                const _SectionHeader(label: 'Management'),
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
                  const _SectionHeader(label: 'Quick Actions'),
                  _QuickActionsCard(
                    enabled: registryReady,
                    onResetDefaults: () => _confirmAndRun(
                      context,
                      title: 'Reset to defaults?',
                      message:
                          'This will restore uBlock Origin to its default '
                          'filter list configuration and remove any external '
                          'lists you added.',
                      confirmLabel: 'Reset',
                      action: resetToDefaults,
                    ),
                    onApplyHardenings: () => _confirmAndRun(
                      context,
                      title: 'Apply WebLibre Hardenings?',
                      message:
                          'This will enable a curated set of additional '
                          'filter lists and add a legitimate URL shortener '
                          'list as an external list.',
                      confirmLabel: 'Apply',
                      action: applyWebLibreHardenings,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                const _SectionHeader(label: 'Filter Lists'),
                const _InfoBanner(
                  message:
                      'Changes to uBlock Origin filter lists require an '
                      'app restart to take effect. Due to caching, '
                      'some changes may need a few minutes and an '
                      'additional restart to fully apply.',
                ),
                registryAsync.when(
                  data: (registry) => _FilterListGroups(
                    registry: registry,
                    settings: settings,
                    onUpdate: updateSettings,
                  ),
                  loading: () => const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Failed to load filter list assets: $error'),
                  ),
                ),
                const SizedBox(height: 24),
                const _SectionHeader(label: 'External Lists'),
                _ExternalListsCard(
                  settings: settings,
                  onUpdate: updateSettings,
                ),
                const SizedBox(height: 32),
              ],
            );
          },
        ),
      ),
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
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
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
            title: const Text('Reset to defaults'),
            subtitle: const Text(
              "Restore uBlock Origin's default filter list configuration.",
            ),
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
            title: const Text('Apply WebLibre Hardenings'),
            subtitle: const Text(
              'Enable a curated set of additional filter lists.',
            ),
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
            title: const Text('Manage with WebLibre'),
            subtitle: const Text(
              "WebLibre controls uBlock Origin's enabled filter lists on "
              'next browser start.',
            ),
            value: settings.enabled,
            onChanged: !registryReady ? null : onToggleManagement,
          ),
          if (!settings.enabled)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Enabling management starts from uBO's common baseline "
                  'lists and preserves My filters.',
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
              title: const Text('Auto-select languages'),
              subtitle: const Text(
                'Enable regional filter lists matching your device languages.',
              ),
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

  const _FilterListGroups({
    required this.registry,
    required this.settings,
    required this.onUpdate,
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
  final Future<void> Function(String token, bool value) onToggle;

  const _GroupCard({
    required this.group,
    required this.parentTree,
    required this.registry,
    required this.enabledTokens,
    required this.autoTokens,
    required this.managementEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final allTokens = parentTree.values.expand((l) => l).toList();
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
            group.label,
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
                  for (final entry in parentTree.entries)
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
                    message: 'Auto-selected for your language',
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
                    message: 'Default on',
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
                  tooltip: 'Visit support page',
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

  const _ExternalListsCard({required this.settings, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final lists = settings.externalFilterLists;
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
                'Raw URLs are forwarded to uBlock Origin as external lists. '
                'Descriptions are only shown here in WebLibre.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          if (lists.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('No external lists configured.'),
              ),
            )
          else
            for (var i = 0; i < lists.length; i++) ...[
              if (i > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(
                    height: 1,
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
              _ExternalListRow(
                index: i,
                entry: lists[i],
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
                label: const Text('Add external list'),
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
            tooltip: 'Edit',
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
            tooltip: 'Remove',
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
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final urlController = useTextEditingController(text: initial?.url ?? '');
    final descriptionController = useTextEditingController(
      text: initial?.description ?? '',
    );
    final isEdit = initial != null;

    return AlertDialog(
      title: Text(
        isEdit ? 'Edit external filter list' : 'Add external filter list',
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
              decoration: const InputDecoration(
                labelText: 'List URL',
                hintText: 'https://example.com/list.txt',
              ),
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                final urlError = validateUrl(
                  trimmed,
                  onlyHttpProtocol: true,
                  eagerParsing: false,
                );
                if (urlError != null) return urlError;
                final clash = existing.any(
                  (e) => e.url == trimmed && e.url != initial?.url,
                );
                if (clash) {
                  return 'Already added';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: descriptionController,
              autofocus: isEdit,
              maxLength: 80,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'e.g. Annoyances — myAuthor',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
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
          child: Text(isEdit ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
