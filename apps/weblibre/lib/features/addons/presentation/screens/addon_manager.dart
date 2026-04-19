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
import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/addons/domain/providers.dart';
import 'package:weblibre/features/addons/extensions/addon_info.dart';
import 'package:weblibre/features/addons/presentation/screens/addon_browse.dart';
import 'package:weblibre/features/addons/presentation/widgets/addon_ui.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/dialogs/install_local_addon_dialog.dart';
import 'package:weblibre/utils/ui_helper.dart';

class AddonManagerScreen extends ConsumerWidget {
  const AddonManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addonsAsync = ref.watch(addonListProvider);

    Future<void> refresh() => ref.read(addonListProvider.notifier).refresh();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Extensions'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Installed'),
              Tab(text: 'Browse'),
            ],
          ),
          actions: [
            IconButton(
              onPressed: addonsAsync.isLoading ? null : refresh,
              icon: const Icon(Icons.refresh),
            ),
            _AddonManagerOverflowMenu(
              canCheckForUpdates: addonsAsync.maybeWhen(
                data: (addons) =>
                    addons.any((a) => a.isInstalled && a.isSupported),
                orElse: () => false,
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              addonsAsync.when(
                skipLoadingOnReload: true,
                skipError: true,
                data: (addons) => RefreshIndicator(
                  onRefresh: refresh,
                  child: _AddonList(addons: addons),
                ),
                error: (error, _) =>
                    _AddonLoadError(error: error, onRetry: refresh),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
              const AddonBrowseView(),
            ],
          ),
        ),
      ),
    );
  }
}

enum _AddonManagerMenuAction { checkForUpdates, installFromFile }

class _AddonManagerOverflowMenu extends ConsumerWidget {
  final bool canCheckForUpdates;

  const _AddonManagerOverflowMenu({required this.canCheckForUpdates});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updatesBusy = ref.watch(
      bulkAddonUpdateProvider.select((value) => value.isLoading),
    );

    return PopupMenuButton<_AddonManagerMenuAction>(
      icon: updatesBusy
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.more_vert),
      onSelected: (action) async {
        switch (action) {
          case _AddonManagerMenuAction.checkForUpdates:
            await ref.read(bulkAddonUpdateProvider.notifier).triggerAll();
            if (!context.mounted) return;
            showInfoMessage(
              context,
              'Background update checks started for installed extensions',
            );
          case _AddonManagerMenuAction.installFromFile:
            await showInstallLocalAddonDialog(context);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _AddonManagerMenuAction.checkForUpdates,
          enabled: canCheckForUpdates && !updatesBusy,
          child: const ListTile(
            leading: Icon(Icons.system_update_alt),
            title: Text('Check for updates'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: _AddonManagerMenuAction.installFromFile,
          child: ListTile(
            leading: Icon(Icons.file_open),
            title: Text('Install from file'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}

class _AddonList extends StatelessWidget {
  final List<AddonInfo> addons;

  const _AddonList({required this.addons});

  @override
  Widget build(BuildContext context) {
    final enabled = addons
        .where((a) => a.isInstalled && a.isSupported && a.isEnabled)
        .toList();
    final disabled = addons
        .where((a) => a.isInstalled && a.isSupported && !a.isEnabled)
        .toList();
    final unsupported = addons
        .where((a) => a.isInstalled && !a.isSupported)
        .toList();
    final installed = enabled.length + disabled.length + unsupported.length;

    return FadingScroll(
      fadingSize: 25,
      builder: (context, controller) {
        return ListView(
          controller: controller,
          padding: const EdgeInsets.all(16),
          children: [
            if (enabled.isNotEmpty) ...[
              const SizedBox(height: 16),
              const _Section(title: 'Enabled'),
              for (final addon in enabled) _AddonCard(addon: addon),
            ],
            if (disabled.isNotEmpty) ...[
              const SizedBox(height: 16),
              const _Section(title: 'Disabled'),
              for (final addon in disabled) _AddonCard(addon: addon),
            ],
            if (unsupported.isNotEmpty) ...[
              const SizedBox(height: 16),
              const _Section(title: 'Unsupported'),
              for (final addon in unsupported)
                _AddonCard(
                  addon: addon,
                  action: _UninstallAction(addon: addon),
                ),
            ],
            if (installed == 0)
              const Padding(
                padding: EdgeInsets.only(top: 48),
                child: Center(
                  child: Text(
                    'No extensions installed yet.\nBrowse the store to find some.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _UninstallAction extends ConsumerWidget {
  final AddonInfo addon;

  const _UninstallAction({required this.addon});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busy = ref.watch(addonBusyIdsProvider).contains(addon.id);
    return IconButton(
      tooltip: 'Remove extension',
      onPressed: busy
          ? null
          : () async {
              await ref.read(addonListProvider.notifier).uninstall(addon);
              if (!context.mounted) return;
              showInfoMessage(context, '${addon.displayName} removed');
            },
      icon: const Icon(Icons.delete_outline),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;

  const _Section({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _AddonCard extends ConsumerWidget {
  final AddonInfo addon;
  final Widget? action;

  const _AddonCard({required this.addon, this.action});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busy = ref.watch(addonBusyIdsProvider).contains(addon.id);

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: busy
            ? null
            : () => AddonDetailsRoute(addonId: addon.id).push<void>(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AddonIconView(addon: addon),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          addon.displayName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if ((addon.summary ?? '').isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(addon.summary!),
                        ],
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            if (addon.isAllowedInPrivateBrowsing)
                              const Chip(label: Text('Private Browsing')),
                            if (addon.ratingAverage != null)
                              Chip(
                                avatar: const Icon(Icons.star, size: 16),
                                label: Text(
                                  addon.ratingAverage!.toStringAsFixed(1),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  action ?? const Icon(Icons.chevron_right),
                ],
              ),
              if (addon.statusBannerMessage != null) ...[
                const SizedBox(height: 12),
                AddonStatusBanner(addon: addon),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AddonLoadError extends StatelessWidget {
  final Object? error;
  final VoidCallback onRetry;

  const _AddonLoadError({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40),
            const SizedBox(height: 12),
            const Text('Failed to load extensions'),
            const SizedBox(height: 8),
            Text(error.toString(), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
