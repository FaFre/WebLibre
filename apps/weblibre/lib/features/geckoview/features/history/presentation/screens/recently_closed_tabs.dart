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
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/display_features.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/history/domain/repositories/recently_closed_tabs.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/hooks/menu_controller.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';
import 'package:weblibre/presentation/widgets/uri_breadcrumb.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

/// Fenix's "Recently closed tabs": the engine's list of closed tabs, reopened
/// with their back history in the container they were closed in.
class RecentlyClosedTabsScreen extends HookConsumerWidget {
  const RecentlyClosedTabsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final entries = ref.watch(recentlyClosedTabsRepositoryProvider);

    Future<void> clearAll() async {
      final confirmed = await showDialog<bool>(
        context: context,
        anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
        builder: (context) => AlertDialog(
          title: Text(l10n.history_recentlyClosedClearConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.common_cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.common_clear),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await ref
            .read(recentlyClosedTabsRepositoryProvider.notifier)
            .removeAll();
      }
    }

    final explanation = Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Text(
        l10n.history_recentlyClosedExplanation,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.history_recentlyClosedTitle),
        actions: [
          if (entries.value?.isNotEmpty ?? false)
            IconButton(
              tooltip: l10n.history_recentlyClosedClearAll,
              onPressed: clearAll,
              icon: const Icon(Icons.delete),
            ),
        ],
      ),
      body: SafeArea(
        child: entries.when(
          skipLoadingOnReload: true,
          data: (entries) => entries.isEmpty
              ? ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
                      child: Text(
                        l10n.history_recentlyClosedEmpty,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    explanation,
                  ],
                )
              : ListView(
                  children: [
                    for (final entry in entries)
                      RecentlyClosedTabTile(
                        key: ValueKey(entry.tab.id),
                        entry: entry,
                      ),
                    explanation,
                  ],
                ),
          error: (error, stackTrace) => Center(
            child: FailureWidget(
              title: l10n.history_recentlyClosedLoadFailed,
              exception: error,
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

class RecentlyClosedTabTile extends HookConsumerWidget {
  final RecentlyClosedTabEntry entry;

  const RecentlyClosedTabTile({super.key, required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final menuController = useMenuController();
    final uri = entry.uri;
    final container = entry.container;

    Future<void> reopen() async {
      final router = GoRouter.of(context);
      final tabId = await ref
          .read(recentlyClosedTabsRepositoryProvider.notifier)
          .restore(entry, selectTab: true);

      if (tabId != null) {
        router.go(const BrowserRoute().location);
      }
    }

    Future<void> reopenInBackground() async {
      final router = GoRouter.of(context);
      // Read now: reopening takes this row off the list, and the snackbar
      // outlives it.
      final tabRepository = ref.read(tabRepositoryProvider.notifier);
      final tabId = await ref
          .read(recentlyClosedTabsRepositoryProvider.notifier)
          .restore(entry, selectTab: false);

      if (tabId != null && context.mounted) {
        ui_helper.showTabSwitchMessage(
          context,
          onSwitch: () async {
            await tabRepository.selectTab(tabId);
            router.go(const BrowserRoute().location);
          },
        );
      }
    }

    return ListTile(
      // As in the history list: the ⋮ glyph 16 from the edge (#651).
      contentPadding: const EdgeInsetsDirectional.only(start: 16, end: 4),
      leading: uri != null
          ? UrlIcon([uri], iconSize: 24)
          : const Icon(MdiIcons.web, size: 24),
      title: Text(
        entry.tab.title.isNotEmpty ? entry.tab.title : entry.tab.url,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (uri != null) UriBreadcrumb(uri: uri),
          if (container != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  CircleAvatar(backgroundColor: container.color, radius: 6),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      container.name ?? l10n.history_unnamedContainer,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )
          else if (entry.containerDeleted)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(l10n.history_recentlyClosedContainerDeleted),
            ),
        ],
      ),
      trailing: MenuAnchor(
        controller: menuController,
        menuChildren: [
          MenuItemButton(
            leadingIcon: const Icon(MdiIcons.tab),
            onPressed: reopenInBackground,
            child: Text(l10n.history_actionOpenInBackground),
          ),
          MenuItemButton(
            leadingIcon: const Icon(Icons.delete),
            onPressed: () => ref
                .read(recentlyClosedTabsRepositoryProvider.notifier)
                .remove(entry),
            child: Text(l10n.common_remove),
          ),
        ],
        child: IconButton(
          tooltip: l10n.history_tooltipEntryActions,
          onPressed: () {
            if (menuController.isOpen) {
              menuController.close();
            } else {
              menuController.open();
            }
          },
          icon: const Icon(MdiIcons.dotsVertical),
        ),
      ),
      onTap: reopen,
    );
  }
}
