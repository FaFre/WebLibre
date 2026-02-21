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

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/providers/web_extensions_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/extension_badge_icon.dart';
import 'package:weblibre/features/sync/domain/entities/sync_repository_state.dart';
import 'package:weblibre/features/sync/domain/repositories/sync.dart';
import 'package:weblibre/features/tor/domain/services/tor_proxy.dart';
import 'package:weblibre/features/user/domain/presentation/dialogs/quit_browser_dialog.dart';
import 'package:weblibre/features/user/domain/providers.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/icons/tor_icons.dart';
import 'package:weblibre/utils/exit_app.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

/// Navigation drawer for the browser screen.
/// Contains all navigation destinations and settings.
class BrowserNavigationDrawer extends HookConsumerWidget {
  const BrowserNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return NavigationDrawer(
      backgroundColor: colorScheme.surface,
      children: [
        // Profile Header
        _ProfileHeader(),
        _SyncTile(),
        const Divider(),

        // Section 1: Tools & Configuration
        _ExtensionsSection(),

        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          onTap: () async {
            Navigator.of(context).pop();
            await SettingsRoute().push(context);
          },
        ),

        Consumer(
          builder: (context, ref, child) {
            final torConnected = ref.watch(
              torProxyServiceProvider.select(
                (value) => value.value?.isRunning == true,
              ),
            );

            return ListTile(
              leading: Badge(
                isLabelVisible: torConnected,
                backgroundColor: AppColors.of(context).torActiveGreen,
                child: const Icon(TorIcons.onionAlt),
              ),
              title: const Text('Tor™ Proxy'),
              onTap: () async {
                Navigator.of(context).pop();
                await const TorProxyRoute().push(context);
              },
            );
          },
        ),

        const Divider(),

        // Section 2: Data & Content
        ListTile(
          leading: const Icon(Icons.history),
          title: const Text('History'),
          onTap: () async {
            Navigator.of(context).pop();
            await const HistoryRoute().push(context);
          },
        ),

        ListTile(
          leading: const Icon(MdiIcons.bookmarkMultiple),
          title: const Text('Bookmarks'),
          onTap: () async {
            Navigator.of(context).pop();
            await BookmarkListRoute(
              entryGuid: BookmarkRoot.root.id,
            ).push(context);
          },
        ),

        ListTile(
          leading: const Icon(MdiIcons.exclamationThick),
          title: const Text('Bangs'),
          onTap: () async {
            Navigator.of(context).pop();
            await const BangMenuRoute().push(context);
          },
        ),

        ListTile(
          leading: const Icon(MdiIcons.folder),
          title: const Text('Containers'),
          onTap: () async {
            Navigator.of(context).pop();
            await const ContainerListRoute().push(context);
          },
        ),

        ListTile(
          leading: const Icon(Icons.rss_feed),
          title: const Text('Feeds'),
          onTap: () async {
            Navigator.of(context).pop();
            await context.push(FeedListRoute().location);
          },
        ),

        const Divider(),

        // Section 3: App
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('About'),
          onTap: () async {
            Navigator.of(context).pop();
            await AboutRoute().push(context);
          },
        ),

        // Quit Browser - styled as destructive action
        ListTile(
          leading: Icon(MdiIcons.power, color: colorScheme.error),
          title: Text(
            'Quit Browser',
            style: TextStyle(color: colorScheme.error),
          ),
          onTap: () async {
            final result = await showQuitBrowserDialog(context);

            if (result == true && context.mounted) {
              await exitApp(ProviderScope.containerOf(context));
            }
          },
        ),
      ],
    );
  }
}

/// Profile header widget showing current profile information.
class _ProfileHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(selectedProfileProvider);

    return InkWell(
      onTap: () async {
        Navigator.of(context).pop(); // Close drawer
        await const SelectProfileRoute().push(context);
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.person,
                size: 28,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              profile.value?.name ?? 'User',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to switch profile',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Extensions section with expandable list of installed extensions.
class _ExtensionsSection extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addonService = ref.watch(addonServiceProvider);
    final pageExtensions = ref.watch(
      webExtensionsStateProvider(
        WebExtensionActionType.page,
      ).select((value) => value.values.toList()),
    );
    final browserExtensions = ref.watch(
      webExtensionsStateProvider(
        WebExtensionActionType.browser,
      ).select((value) => value.values.toList()),
    );

    final isExpanded = useState(false);

    return Column(
      children: [
        ListTile(
          leading: const Icon(MdiIcons.puzzle),
          title: const Text('Extensions'),
          trailing: Icon(
            isExpanded.value ? Icons.expand_less : Icons.expand_more,
          ),
          onTap: () => isExpanded.value = !isExpanded.value,
        ),
        if (isExpanded.value)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              children: [
                // Page extensions
                if (pageExtensions.isNotEmpty) ...[
                  ...pageExtensions.map(
                    (extension) => ListTile(
                      leading: ExtensionBadgeIcon(extension),
                      title: Text(extension.title ?? 'Extension'),
                      dense: true,
                      onTap: () async {
                        Navigator.of(context).pop(); // Close drawer
                        await addonService.invokeAddonAction(
                          extension.extensionId,
                          WebExtensionActionType.page,
                        );
                      },
                    ),
                  ),
                  const Divider(indent: 16, endIndent: 16),
                ],
                // Browser extensions
                if (browserExtensions.isNotEmpty) ...[
                  ...browserExtensions.map(
                    (extension) => ListTile(
                      leading: ExtensionBadgeIcon(extension),
                      title: Text(extension.title ?? 'Extension'),
                      dense: true,
                      onTap: () async {
                        Navigator.of(context).pop(); // Close drawer
                        await addonService.invokeAddonAction(
                          extension.extensionId,
                          WebExtensionActionType.browser,
                        );
                      },
                    ),
                  ),
                  const Divider(indent: 16, endIndent: 16),
                ],
                // Management options
                ListTile(
                  leading: const Icon(MdiIcons.puzzleEdit),
                  title: const Text('Manage Extensions'),
                  dense: true,
                  onTap: () async {
                    Navigator.of(context).pop(); // Close drawer
                    await addonService.startAddonManagerActivity();
                  },
                ),
                ListTile(
                  leading: const Icon(MdiIcons.puzzlePlus),
                  title: const Text('Get Extensions'),
                  dense: true,
                  onTap: () async {
                    Navigator.of(context).pop(); // Close drawer
                    final isPrivate =
                        ref
                            .read(generalSettingsWithDefaultsProvider)
                            .defaultCreateTabType ==
                        TabType.private;

                    await ref
                        .read(tabRepositoryProvider.notifier)
                        .addTab(
                          url: Uri.parse('https://addons.mozilla.org'),
                          private: isPrivate,
                          container: const Value(null),
                          selectTab: true,
                        );
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Sync tile widget shown in navigation drawer when sync is active.
/// Displays sync status and allows manual sync trigger.
class _SyncTile extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(syncIsAuthenticatedProvider);

    // Only show if sync is active
    if (!isAuthenticated) {
      return const SizedBox.shrink();
    }

    final syncInfo = ref.watch(
      syncRepositoryProvider.select((value) => value.value?.account),
    );

    final syncStarted = ref.watch(
      syncEventProvider.select(
        (value) => value.isLoading || value.value?.$1 == SyncEvent.started,
      ),
    );
    final isSyncing = syncStarted || syncInfo?.syncing == true;

    final controller = useAnimationController(
      duration: const Duration(seconds: 2),
    );

    useEffect(() {
      if (isSyncing) {
        unawaited(controller.repeat());
      } else {
        controller.stop();
        controller.reset();
      }
      return null;
    }, [isSyncing]);

    return ListTile(
      leading: RotationTransition(
        turns: Tween<double>(begin: 0, end: -1).animate(controller),
        child: const Icon(Icons.sync),
      ),
      title: const Text('Sync Now'),
      onTap: () async {
        await ref.read(syncRepositoryProvider.notifier).syncNow();

        final openedTabs = await ref
            .read(syncRepositoryProvider.notifier)
            .pollIncomingTabsAndOpen();

        if (context.mounted) {
          if (openedTabs > 0) {
            ui_helper.showOpenedTabsFromAnotherDeviceMessage(
              context,
              openedTabs,
            );
          } else {
            ui_helper.showInfoMessage(
              context,
              'Synchronization complete',
              duration: const Duration(seconds: 2),
            );
          }
        }

        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
    );
  }
}
