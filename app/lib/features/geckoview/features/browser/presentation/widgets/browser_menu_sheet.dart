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
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/core/providers/persisted_bool.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/controllers/bottom_sheet.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/readerable.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_container_selection.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/providers/desktop_mode.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_session.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/providers/web_extensions_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/dialogs/content_selection_dialog.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/dialogs/qr_code.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/extension_badge_icon.dart';
import 'package:weblibre/features/geckoview/features/find_in_page/presentation/controllers/find_in_page.dart';
import 'package:weblibre/features/geckoview/features/pwa/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/pwa/presentation/widgets/pwa_install_button.dart';
import 'package:weblibre/features/geckoview/features/readerview/presentation/controllers/readerable.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/entities/container_selection_result.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/sync/domain/entities/sync_repository_state.dart';
import 'package:weblibre/features/sync/domain/repositories/sync.dart';
import 'package:weblibre/features/tor/domain/services/tor_proxy.dart';
import 'package:weblibre/features/user/domain/presentation/dialogs/quit_browser_dialog.dart';
import 'package:weblibre/features/user/domain/providers.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/controllers/website_title.dart';
import 'package:weblibre/presentation/hooks/cached_future.dart';
import 'package:weblibre/presentation/icons/tor_icons.dart';
import 'package:weblibre/utils/exit_app.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

/// Shows the combined browser menu as a modal bottom sheet.
Future<void> showBrowserMenuSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => const _BrowserMenuSheet(),
  );
}

class _BrowserMenuSheet extends HookConsumerWidget {
  const _BrowserMenuSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedTabId = ref.watch(selectedTabProvider);
    final settings = ref.watch(generalSettingsWithDefaultsProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Scrollable content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                children: [
                  // Navigation row
                  if (selectedTabId != null)
                    _NavigationRow(selectedTabId: selectedTabId),
                  const SizedBox(height: 16),

                  // Quick toggles (Desktop Mode / Reader Mode)
                  if (selectedTabId != null) ...[
                    _QuickTogglesGrid(selectedTabId: selectedTabId),
                    const SizedBox(height: 16),
                  ],

                  // Page actions
                  if (selectedTabId != null) ...[
                    _PageActionsCard(selectedTabId: selectedTabId),
                    const SizedBox(height: 16),
                  ],

                  // Extensions
                  _ExtensionsCard(),
                  const SizedBox(height: 16),

                  // Tab actions
                  if (selectedTabId != null) ...[
                    _TabActionsCard(selectedTabId: selectedTabId),
                    const SizedBox(height: 16),
                  ],

                  // Quick links grid
                  _QuickLinksGrid(showContainerUi: settings.showContainerUi),
                  const SizedBox(height: 16),

                  // Profile
                  _ProfileCard(),
                  const SizedBox(height: 16),

                  // App
                  const _SettingsCard(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Helper Builders ───

Widget _buildMenuCard(BuildContext context, {required List<Widget> children}) {
  return Material(
    color: Theme.of(context).colorScheme.surfaceContainerHigh,
    borderRadius: BorderRadius.circular(16),
    clipBehavior: Clip.antiAlias,
    child: Column(children: children),
  );
}

Widget _buildDivider() {
  return const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16);
}

Widget _buildSubTile(
  String title, {
  IconData? icon,
  Color? iconColor,
  required VoidCallback onTap,
}) {
  return ListTile(
    contentPadding: const EdgeInsets.only(left: 56, right: 16),
    leading: icon != null ? Icon(icon, color: iconColor, size: 20) : null,
    title: Text(title, style: const TextStyle(fontSize: 14)),
    dense: true,
    onTap: onTap,
  );
}

// ─── Navigation Row ───

class _NavigationRow extends HookConsumerWidget {
  final String selectedTabId;

  const _NavigationRow({required this.selectedTabId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(
      tabStateProvider(selectedTabId).select((value) => value?.historyState),
    );
    final isLoading = ref.watch(
      tabStateProvider(
        selectedTabId,
      ).select((state) => state?.isLoading ?? false),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildNavIcon(
          icon: isLoading ? Icons.close : Icons.arrow_back,
          label: isLoading ? 'Stop' : 'Back',
          disabled: !isLoading && history?.canGoBack != true,
          onTap: () async {
            final controller = ref.read(
              tabSessionProvider(tabId: selectedTabId).notifier,
            );
            if (isLoading) {
              await controller.stopLoading();
            } else {
              await controller.goBack();
            }
            if (context.mounted) Navigator.pop(context);
          },
        ),
        _buildNavIcon(
          icon: Icons.arrow_forward,
          label: 'Forward',
          disabled: history?.canGoForward != true,
          onTap: () async {
            await ref
                .read(tabSessionProvider(tabId: selectedTabId).notifier)
                .goForward();
            if (context.mounted) Navigator.pop(context);
          },
        ),
        _buildNavIcon(
          icon: MdiIcons.tabMinus,
          label: 'Close Tab',
          onTap: () async {
            final tabState = ref.read(tabStateProvider(selectedTabId));
            if (tabState != null && tabState.tabMode is IsolatedTabMode) {
              final allStates = ref.read(tabStatesProvider);
              final groupCount = allStates.values
                  .where(
                    (s) => s.isolationContextId == tabState.isolationContextId,
                  )
                  .length;
              if (groupCount <= 1 && context.mounted) {
                final confirmed = await ui_helper.confirmIsolatedTabClose(
                  context,
                );
                if (!confirmed) return;
              }
            }

            await ref
                .read(tabRepositoryProvider.notifier)
                .closeTab(selectedTabId);

            if (context.mounted) {
              Navigator.pop(context);
              ui_helper.showTabUndoClose(
                context,
                ref.read(tabRepositoryProvider.notifier).undoClose,
              );
            }
          },
        ),
        _buildNavIcon(
          icon: Icons.refresh,
          label: 'Reload',
          onTap: () async {
            await ref
                .read(tabSessionProvider(tabId: selectedTabId).notifier)
                .reload();
            if (context.mounted) Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _buildNavIcon({
    required IconData icon,
    required String label,
    bool disabled = false,
    required VoidCallback onTap,
  }) {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return InkWell(
          onTap: disabled ? null : onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: disabled
                      ? colorScheme.onSurface.withValues(alpha: 0.3)
                      : colorScheme.onSurface,
                  size: 28,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: disabled
                        ? colorScheme.onSurface.withValues(alpha: 0.3)
                        : colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Page Actions Card ───

class _PageActionsCard extends HookConsumerWidget {
  final String selectedTabId;

  const _PageActionsCard({required this.selectedTabId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _buildMenuCard(
      context,
      children: [
        // Add Bookmark
        ListTile(
          leading: const Icon(MdiIcons.bookmarkPlus),
          title: const Text('Add Bookmark'),
          onTap: () async {
            final tabState = ref.read(tabStateProvider(selectedTabId))!;
            Navigator.pop(context);
            await BookmarkEntryAddRoute(
              bookmarkInfo: jsonEncode(
                BookmarkInfo(
                  title: tabState.titleOrAuthority,
                  url: tabState.url.toString(),
                ).encode(),
              ),
            ).push(context);
          },
        ),
        _buildDivider(),

        // Find in page
        ListTile(
          leading: const Icon(Icons.search),
          title: const Text('Find in page'),
          onTap: () {
            ref.read(bottomSheetControllerProvider.notifier).requestDismiss();
            ref
                .read(findInPageControllerProvider(selectedTabId).notifier)
                .show();
            Navigator.pop(context);
          },
        ),

        // Add to Home Screen (conditional)
        _AddToHomeScreenTile(selectedTabId: selectedTabId),
      ],
    );
  }
}

// ─── Quick Toggles Grid ───

class _QuickTogglesGrid extends HookConsumerWidget {
  final String selectedTabId;

  const _QuickTogglesGrid({required this.selectedTabId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final desktopEnabled = ref.watch(desktopModeProvider(selectedTabId));

    final readerChanging = ref.watch(readerableScreenControllerProvider);
    final readerabilityState = ref.watch(
      selectedTabStateProvider.select(
        (state) => state?.readerableState ?? ReaderableState.$default(),
      ),
    );
    final isReaderActive = readerabilityState.active;
    final isReaderLoading = readerChanging.isLoading;

    final enableReadability = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (value) => value.enableReadability,
      ),
    );
    final enforceReadability = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (value) => value.enforceReadability,
      ),
    );
    final readerVisible =
        (readerabilityState.readerable &&
            (enableReadability || readerabilityState.active)) ||
        (enforceReadability && enableReadability);

    return Row(
      children: [
        Expanded(
          child: _ToggleTile(
            icon: MdiIcons.monitor,
            label: 'Desktop Mode',
            active: desktopEnabled,
            onTap: () {
              ref
                  .read(desktopModeProvider(selectedTabId).notifier)
                  .enabled(!desktopEnabled);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: readerVisible
              ? _ToggleTile(
                  icon: isReaderActive
                      ? MdiIcons.bookOpen
                      : MdiIcons.bookOpenOutline,
                  label: 'Reader Mode',
                  active: isReaderActive,
                  enabled: !isReaderLoading,
                  onTap: () async {
                    await ref
                        .read(readerableScreenControllerProvider.notifier)
                        .toggleReaderView(!isReaderActive);
                  },
                )
              : _ToggleTile(
                  icon: MdiIcons.bookOpenOutline,
                  label: 'Reader Mode',
                  active: false,
                  enabled: false,
                  onTap: () {},
                ),
        ),
      ],
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final bool enabled;
  final VoidCallback onTap;

  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.active,
    this.enabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final backgroundColor = active
        ? colorScheme.primary
        : colorScheme.surfaceContainerHigh;
    final foregroundColor = active
        ? colorScheme.onPrimary
        : colorScheme.onSurface;
    final effectiveAlpha = enabled ? 1.0 : 0.38;

    return Material(
      color: backgroundColor.withValues(alpha: enabled ? 1.0 : 0.5),
      borderRadius: BorderRadius.circular(28),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Icon(
                icon,
                color: foregroundColor.withValues(alpha: effectiveAlpha),
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: foregroundColor.withValues(alpha: effectiveAlpha),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddToHomeScreenTile extends ConsumerWidget {
  final String selectedTabId;

  const _AddToHomeScreenTile({required this.selectedTabId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInstallable = ref.watch(isCurrentTabInstallableProvider);

    if (!isInstallable) return const SizedBox.shrink();

    return Column(
      children: [
        _buildDivider(),
        ListTile(
          leading: const Icon(Icons.add_to_home_screen),
          title: const Text('Add to Home Screen'),
          onTap: () async {
            await showPwaInstallDialog(context, ref);
            if (context.mounted) Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

class _FetchFeedsTile extends HookConsumerWidget {
  final String selectedTabId;

  const _FetchFeedsTile({required this.selectedTabId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showFeeds = useState(false);

    if (!showFeeds.value) {
      return Column(
        children: [
          _buildDivider(),
          ListTile(
            leading: const Icon(Icons.rss_feed),
            title: const Text('Fetch Feeds'),
            onTap: () {
              showFeeds.value = true;
            },
          ),
        ],
      );
    }

    final feedsAsync = ref.watch(websiteFeedProviderProvider(selectedTabId));

    return feedsAsync.when(
      skipLoadingOnReload: true,
      data: (feeds) {
        if (feeds.value.isEmpty) {
          return Column(
            children: [
              _buildDivider(),
              const ListTile(
                leading: Icon(Icons.rss_feed_outlined),
                title: Text('No Web Feeds Found'),
                enabled: false,
              ),
            ],
          );
        }

        return Column(
          children: [
            _buildDivider(),
            ListTile(
              leading: const Icon(Icons.rss_feed),
              title: const Text('Available Web Feeds'),
              trailing: Badge(label: Text(feeds.value!.length.toString())),
              onTap: () async {
                Navigator.pop(context);
                await SelectFeedDialogRoute(
                  feedsJson: jsonEncode(
                    feeds.value!.map((feed) => feed.toString()).toList(),
                  ),
                ).push(context);
              },
            ),
          ],
        );
      },
      error: (_, _) => const SizedBox.shrink(),
      loading: () => Column(
        children: [
          _buildDivider(),
          const ListTile(
            leading: Icon(Icons.rss_feed),
            title: Text('Fetching Web Feeds...'),
            trailing: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab Actions Card ───

class _TabActionsCard extends HookConsumerWidget {
  final String selectedTabId;

  const _TabActionsCard({required this.selectedTabId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(generalSettingsWithDefaultsProvider);
    final showMore = useState(false);

    return _buildMenuCard(
      context,
      children: [
        // Container (conditional)
        if (settings.showContainerUi) ...[
          _ContainerExpansion(selectedTabId: selectedTabId),
          _buildDivider(),
        ],

        // Share
        _ShareExpansion(selectedTabId: selectedTabId),
        _buildDivider(),

        // More / Less toggle
        if (!showMore.value)
          ListTile(
            leading: const Icon(Icons.more_horiz),
            title: const Text('More'),
            subtitle: const Text('Clone Tab, Export, Fetch Feeds'),
            trailing: const Icon(Icons.expand_more),
            onTap: () => showMore.value = true,
          )
        else ...[
          _CloneTabExpansion(selectedTabId: selectedTabId),
          _buildDivider(),
          _ExportExpansion(selectedTabId: selectedTabId),
          _FetchFeedsTile(selectedTabId: selectedTabId),
        ],
      ],
    );
  }
}

class _CloneTabExpansion extends ConsumerWidget {
  final String selectedTabId;

  const _CloneTabExpansion({required this.selectedTabId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = AppColors.of(context);
    final settings = ref.watch(generalSettingsWithDefaultsProvider);

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: const Icon(MdiIcons.tabPlus),
        title: const Text('Clone Tab'),
        children: [
          _buildSubTile(
            'Regular',
            icon: MdiIcons.tab,
            onTap: () async {
              final tabState = ref.read(tabStateProvider(selectedTabId))!;
              final containerData = await ref
                  .read(tabDataRepositoryProvider.notifier)
                  .getTabContainerData(selectedTabId);

              final tabId = (tabState.tabMode is! RegularTabMode)
                  ? await ref
                        .read(tabRepositoryProvider.notifier)
                        .addTab(
                          tabMode: TabMode.regular,
                          url: tabState.url,
                          containerSelection: containerData == null
                              ? const TabContainerSelection.unassigned()
                              : TabContainerSelection.specific(containerData),
                          selectTab: false,
                        )
                  : await ref
                        .read(tabRepositoryProvider.notifier)
                        .duplicateTab(
                          selectTabId: selectedTabId,
                          containerData: containerData,
                          selectTab: false,
                        );

              if (context.mounted) {
                final repo = ref.read(tabRepositoryProvider.notifier);
                Navigator.pop(context);
                ui_helper.showTabSwitchMessage(
                  context,
                  onSwitch: () => repo.selectTab(tabId),
                );
              }
            },
          ),
          _buildSubTile(
            'Private',
            icon: MdiIcons.dominoMask,
            iconColor: appColors.privateTabPurple,
            onTap: () async {
              final tabState = ref.read(tabStateProvider(selectedTabId))!;
              final containerData = await ref
                  .read(tabDataRepositoryProvider.notifier)
                  .getTabContainerData(selectedTabId);

              final tabId = (tabState.tabMode is! PrivateTabMode)
                  ? await ref
                        .read(tabRepositoryProvider.notifier)
                        .addTab(
                          url: tabState.url,
                          tabMode: TabMode.private,
                          containerSelection: containerData == null
                              ? const TabContainerSelection.unassigned()
                              : TabContainerSelection.specific(containerData),
                          selectTab: false,
                        )
                  : await ref
                        .read(tabRepositoryProvider.notifier)
                        .duplicateTab(
                          selectTabId: selectedTabId,
                          containerData: containerData,
                          selectTab: false,
                        );

              if (context.mounted) {
                final repo = ref.read(tabRepositoryProvider.notifier);
                Navigator.pop(context);
                ui_helper.showTabSwitchMessage(
                  context,
                  onSwitch: () => repo.selectTab(tabId),
                );
              }
            },
          ),
          if (settings.showIsolatedTabUi)
            _buildSubTile(
              'Isolated',
              icon: MdiIcons.snowflake,
              iconColor: appColors.isolatedTabTeal,
              onTap: () async {
                final tabState = ref.read(tabStateProvider(selectedTabId))!;
                final containerData = await ref
                    .read(tabDataRepositoryProvider.notifier)
                    .getTabContainerData(selectedTabId);

                final tabId = await ref
                    .read(tabRepositoryProvider.notifier)
                    .addTab(
                      url: tabState.url,
                      tabMode: TabMode.newIsolated(),
                      containerSelection: containerData == null
                          ? const TabContainerSelection.unassigned()
                          : TabContainerSelection.specific(containerData),
                      selectTab: false,
                    );

                if (context.mounted) {
                  final repo = ref.read(tabRepositoryProvider.notifier);
                  Navigator.pop(context);
                  ui_helper.showTabSwitchMessage(
                    context,
                    onSwitch: () => repo.selectTab(tabId),
                  );
                }
              },
            ),
        ],
      ),
    );
  }
}

class _ContainerExpansion extends ConsumerWidget {
  final String selectedTabId;

  const _ContainerExpansion({required this.selectedTabId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: const Icon(MdiIcons.folder),
        title: const Text('Containers'),
        children: [
          _buildSubTile(
            'Manage Containers',
            icon: MdiIcons.folder,
            onTap: () async {
              Navigator.pop(context);
              await const ContainerListRoute().push(context);
            },
          ),

          // Assign Container
          _buildSubTile(
            'Assign Container',
            icon: MdiIcons.folderArrowUpDownOutline,
            onTap: () async {
              final selection = await const ContainerSelectionRoute()
                  .push<ContainerSelectionResult?>(context);

              switch (selection) {
                case ContainerSelectionSelected(:final containerId):
                  final containerData = await ref
                      .read(containerRepositoryProvider.notifier)
                      .getContainerData(containerId);

                  if (containerData != null) {
                    final tabState = ref.read(tabStateProvider(selectedTabId))!;
                    await ref
                        .read(tabDataRepositoryProvider.notifier)
                        .assignContainer(tabState.id, containerData);
                  }
                case ContainerSelectionUnassigned():
                  final tabState = ref.read(tabStateProvider(selectedTabId))!;
                  await ref
                      .read(tabDataRepositoryProvider.notifier)
                      .unassignContainer(tabState.id);
                case null:
                  break;
              }

              if (context.mounted) Navigator.pop(context);
            },
          ),

          // URL relation (conditional)
          Consumer(
            builder: (context, ref, child) {
              final isSiteAssigned = ref.watch(
                watchIsCurrentSiteAssignedToContainerProvider,
              );

              if (!isSiteAssigned.hasValue || isSiteAssigned.requireValue) {
                return const SizedBox.shrink();
              }

              return _buildSubTile(
                'Assign URL to Container',
                icon: MdiIcons.webPlus,
                onTap: () async {
                  final selection = await const ContainerSelectionRoute()
                      .push<ContainerSelectionResult?>(context);

                  if (selection case ContainerSelectionSelected(
                    :final containerId,
                  )) {
                    final containerData = await ref
                        .read(containerRepositoryProvider.notifier)
                        .getContainerData(containerId);

                    if (containerData != null) {
                      final tabState = ref.read(
                        tabStateProvider(selectedTabId),
                      );
                      final origin = tabState?.url.origin.mapNotNull(Uri.parse);

                      if (origin != null) {
                        await ref
                            .read(containerRepositoryProvider.notifier)
                            .replaceContainer(
                              containerData.copyWith.metadata(
                                containerData.metadata.copyWith.assignedSites([
                                  ...?containerData.metadata.assignedSites,
                                  origin,
                                ]),
                              ),
                            );
                      }
                    }
                  }

                  if (context.mounted) Navigator.pop(context);
                },
              );
            },
          ),

          // Unassign URL relation (conditional)
          Consumer(
            builder: (context, ref, child) {
              final isSiteAssigned = ref.watch(
                watchIsCurrentSiteAssignedToContainerProvider,
              );

              if (!isSiteAssigned.hasValue || !isSiteAssigned.requireValue) {
                return const SizedBox.shrink();
              }

              return _buildSubTile(
                'Unassign URL from Container',
                icon: MdiIcons.webMinus,
                onTap: () async {
                  final tabState = ref.read(tabStateProvider(selectedTabId));
                  final origin = tabState?.url.origin.mapNotNull(Uri.parse);

                  if (origin != null) {
                    final containerId = await ref
                        .read(containerRepositoryProvider.notifier)
                        .siteAssignedContainerId(origin);

                    if (containerId != null) {
                      final containerData = await ref
                          .read(containerRepositoryProvider.notifier)
                          .getContainerData(containerId);

                      if (containerData != null) {
                        final updatedSites = containerData
                            .metadata
                            .assignedSites
                            ?.where((site) => site != origin)
                            .toList();

                        await ref
                            .read(containerRepositoryProvider.notifier)
                            .replaceContainer(
                              containerData.copyWith.metadata(
                                containerData.metadata.copyWith.assignedSites(
                                  updatedSites,
                                ),
                              ),
                            );
                      }
                    }
                  }

                  if (context.mounted) Navigator.pop(context);
                },
              );
            },
          ),

          // Unassign Container (conditional)
          Consumer(
            builder: (context, ref, child) {
              final containerId = ref.watch(
                watchContainerTabIdProvider(
                  selectedTabId,
                ).select((value) => value.value),
              );

              if (containerId == null) return const SizedBox.shrink();

              return _buildSubTile(
                'Unassign Container',
                icon: MdiIcons.folderCancelOutline,
                onTap: () async {
                  final tabState = ref.read(tabStateProvider(selectedTabId))!;
                  await ref
                      .read(tabDataRepositoryProvider.notifier)
                      .unassignContainer(tabState.id);
                  if (context.mounted) Navigator.pop(context);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ShareExpansion extends HookConsumerWidget {
  final String selectedTabId;

  const _ShareExpansion({required this.selectedTabId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: const Icon(Icons.share),
        title: const Text('Share'),
        children: [
          // Copy Address
          _buildSubTile(
            'Copy Address',
            icon: MdiIcons.contentCopy,
            onTap: () async {
              final tabState = ref.read(tabStateProvider(selectedTabId))!;
              await Clipboard.setData(
                ClipboardData(text: tabState.url.toString()),
              );
              if (context.mounted) Navigator.pop(context);
            },
          ),

          // Open in App (conditional)
          _OpenInAppSubTile(selectedTabId: selectedTabId),

          // Share Screenshot
          _buildSubTile(
            'Share Screenshot',
            icon: Icons.mobile_screen_share,
            onTap: () async {
              final screenshot = await ref
                  .read(selectedTabSessionProvider)
                  .requestScreenshot();

              final tabState = ref.read(tabStateProvider(selectedTabId))!;

              if (screenshot != null) {
                ui.decodeImageFromList(screenshot, (result) async {
                  try {
                    final png = await result.toByteData(
                      format: ui.ImageByteFormat.png,
                    );

                    if (png != null) {
                      final file = XFile.fromData(
                        png.buffer.asUint8List(),
                        mimeType: 'image/png',
                      );

                      await SharePlus.instance.share(
                        ShareParams(
                          files: [file],
                          subject: tabState.titleOrAuthority,
                        ),
                      );
                    }
                  } finally {
                    result.dispose();
                  }
                });
              }

              if (context.mounted) Navigator.pop(context);
            },
          ),

          // Share Link
          _buildSubTile(
            'Share Link',
            icon: Icons.share,
            onTap: () async {
              final tabState = ref.read(tabStateProvider(selectedTabId))!;
              await SharePlus.instance.share(ShareParams(uri: tabState.url));
              if (context.mounted) Navigator.pop(context);
            },
          ),

          // Send To Device (conditional)
          _SendToDeviceExpansion(selectedTabId: selectedTabId),

          // Show QR Code
          _buildSubTile(
            'Show QR Code',
            icon: Icons.qr_code,
            onTap: () async {
              final tabState = ref.read(tabStateProvider(selectedTabId))!;
              if (context.mounted) {
                Navigator.pop(context);
                await showQrCode(context, tabState.url.toString());
              }
            },
          ),
        ],
      ),
    );
  }
}

class _OpenInAppSubTile extends HookConsumerWidget {
  final String selectedTabId;

  static final _service = GeckoAppLinksService();

  const _OpenInAppSubTile({required this.selectedTabId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabState = ref.watch(tabStateProvider(selectedTabId));
    final url = tabState?.url;
    final hasExternalApp = useCachedFuture(
      () => url != null ? _service.hasExternalApp(url) : Future.value(false),
      [url],
    );

    if (hasExternalApp.data != true) return const SizedBox.shrink();

    return _buildSubTile(
      'Open in App',
      icon: Icons.open_in_new,
      onTap: () async {
        if (url == null) return;
        final success = await _service.openAppLink(url);
        if (success && context.mounted) Navigator.pop(context);
      },
    );
  }
}

class _SendToDeviceExpansion extends ConsumerWidget {
  final String selectedTabId;

  const _SendToDeviceExpansion({required this.selectedTabId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(syncIsAuthenticatedProvider);
    final devices = ref.watch(syncDevicesProvider);

    if (!isAuthenticated) return const SizedBox.shrink();

    return Skeletonizer(
      enabled: devices.isLoading && devices.value == null,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.only(left: 56, right: 16),
          leading: const Icon(Icons.send_outlined, size: 20),
          title: const Text('Send To Device', style: TextStyle(fontSize: 14)),
          children: devices.when(
            data: (deviceList) {
              final targets = deviceList
                  .where(
                    (device) => !device.isCurrentDevice && device.canSendTab,
                  )
                  .toList(growable: false);

              if (targets.isEmpty) {
                return [
                  const ListTile(
                    contentPadding: EdgeInsets.only(left: 72, right: 16),
                    title: Text(
                      'No target devices',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ];
              }

              return targets
                  .map(
                    (device) => ListTile(
                      contentPadding: const EdgeInsets.only(
                        left: 72,
                        right: 16,
                      ),
                      leading: const Icon(Icons.devices_other, size: 18),
                      title: Text(
                        device.displayName,
                        style: const TextStyle(fontSize: 13),
                      ),
                      dense: true,
                      onTap: () async {
                        final tabState = ref.read(
                          tabStateProvider(selectedTabId),
                        );
                        if (tabState == null) return;

                        final title = tabState.title.isNotEmpty
                            ? tabState.title
                            : tabState.url.toString();

                        final success = await ref
                            .read(syncRepositoryProvider.notifier)
                            .sendTabToDevice(
                              deviceId: device.deviceId,
                              title: title,
                              url: tabState.url.toString(),
                            );

                        if (context.mounted) {
                          Navigator.pop(context);
                          if (success) {
                            ui_helper.showInfoMessage(
                              context,
                              'Sent tab to ${device.displayName}',
                            );
                          } else {
                            ui_helper.showErrorMessage(
                              context,
                              'Failed to send tab',
                            );
                          }
                        }
                      },
                    ),
                  )
                  .toList(growable: false);
            },
            loading: () => const [
              ListTile(
                contentPadding: EdgeInsets.only(left: 72, right: 16),
                leading: Icon(Icons.devices_other, size: 18),
                title: Text(
                  'Loading devices...',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
            error: (_, _) => const [
              ListTile(
                contentPadding: EdgeInsets.only(left: 72, right: 16),
                title: Text(
                  'Failed to load devices',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExportExpansion extends ConsumerWidget {
  final String selectedTabId;

  const _ExportExpansion({required this.selectedTabId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: const Icon(MdiIcons.fileExport),
        title: const Text('Export'),
        children: [
          // Copy as Markdown
          _buildSubTile(
            'Copy as Markdown',
            // ignore: deprecated_member_use
            icon: MdiIcons.languageMarkdownOutline,
            onTap: () async {
              await _handleMarkdownExport(context, ref, selectedTabId, (
                content,
                fileName,
              ) async {
                await Clipboard.setData(ClipboardData(text: content));
                if (context.mounted) {
                  ui_helper.showInfoMessage(
                    context,
                    'Markdown copied to clipboard',
                  );
                }
              }, const Text('Copy as Markdown'));
            },
          ),

          // Export as Markdown
          _buildSubTile(
            'Export as Markdown',
            // ignore: deprecated_member_use
            icon: MdiIcons.languageMarkdown,
            onTap: () async {
              await _handleMarkdownExport(context, ref, selectedTabId, (
                content,
                fileName,
              ) async {
                await FilePicker.platform.saveFile(
                  fileName: fileName,
                  type: FileType.custom,
                  allowedExtensions: ['md'],
                  bytes: utf8.encode(content),
                );
              }, const Text('Export as Markdown'));
            },
          ),

          // Export as PDF
          _buildSubTile(
            'Export as PDF',
            icon: MdiIcons.filePdfBox,
            onTap: () async {
              await ref
                  .read(tabSessionProvider(tabId: selectedTabId).notifier)
                  .saveToPdf();
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _handleMarkdownExport(
    BuildContext context,
    WidgetRef ref,
    String tabId,
    Future<void> Function(String content, String? fileName) shareAction,
    Widget title,
  ) async {
    final tabData = await ref
        .read(tabDataRepositoryProvider.notifier)
        .getTabDataById(tabId);

    if (tabData == null || tabData.fullContentMarkdown.isEmpty) {
      if (context.mounted) Navigator.pop(context);
      return;
    }

    final shouldShowDialog =
        tabData.isProbablyReaderable == true &&
        tabData.extractedContentMarkdown.isNotEmpty;

    if (shouldShowDialog && context.mounted) {
      Navigator.pop(context);
      await showContentSelectionDialog(
        context,
        title: title,
        tabData: tabData,
        shareMarkdownAction: shareAction,
      );
    } else {
      await shareAction(
        tabData.fullContentMarkdown!,
        tabData.title ?? tabData.url?.authority,
      );
      if (context.mounted) Navigator.pop(context);
    }
  }
}

// ─── Extensions Card ───

class _ExtensionsCard extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addonService = ref.watch(addonServiceProvider);
    final extensionsExpanded = ref.watch(persistedBoolProvider(PersistedBoolKey.extensionsExpanded));
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
    Future<void> openExtensionSettings(String extensionId) async {
      Navigator.pop(context);
      await addonService.startAddonSettingsActivity(extensionId);
    }

    return _buildMenuCard(
      context,
      children: [
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: const Icon(MdiIcons.puzzle),
            title: const Text('Extensions'),
            initiallyExpanded: extensionsExpanded,
            onExpansionChanged: (_) =>
                ref.read(persistedBoolProvider(PersistedBoolKey.extensionsExpanded).notifier).toggle(),
            children: [
              // Page extensions
              if (pageExtensions.isNotEmpty) ...[
                ...pageExtensions.map(
                  (extension) => ListTile(
                    contentPadding: const EdgeInsets.only(left: 56, right: 16),
                    leading: ExtensionBadgeIcon(extension),
                    title: Text(
                      extension.title ?? 'Extension',
                      style: const TextStyle(fontSize: 14),
                    ),
                    dense: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const VerticalDivider(indent: 4, endIndent: 4),
                        IconButton(
                          icon: const Icon(Icons.settings, size: 20),
                          tooltip: 'Extension settings',
                          onPressed: () async {
                            await openExtensionSettings(extension.extensionId);
                          },
                        ),
                      ],
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      await addonService.invokeAddonAction(
                        extension.extensionId,
                        WebExtensionActionType.page,
                      );
                    },
                  ),
                ),
                const Divider(indent: 56, endIndent: 16),
              ],
              // Browser extensions
              if (browserExtensions.isNotEmpty) ...[
                ...browserExtensions.map(
                  (extension) => ListTile(
                    contentPadding: const EdgeInsets.only(left: 56, right: 16),
                    leading: ExtensionBadgeIcon(extension),
                    title: Text(
                      extension.title ?? 'Extension',
                      style: const TextStyle(fontSize: 14),
                    ),
                    dense: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const VerticalDivider(indent: 4, endIndent: 4),
                        IconButton(
                          icon: const Icon(Icons.settings, size: 20),
                          tooltip: 'Extension settings',
                          onPressed: () async {
                            await openExtensionSettings(extension.extensionId);
                          },
                        ),
                      ],
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      await addonService.invokeAddonAction(
                        extension.extensionId,
                        WebExtensionActionType.browser,
                      );
                    },
                  ),
                ),
                const Divider(indent: 56, endIndent: 16),
              ],
              // Management
              _buildSubTile(
                'Manage Extensions',
                icon: MdiIcons.puzzleEdit,
                onTap: () async {
                  Navigator.pop(context);
                  await addonService.startAddonManagerActivity();
                },
              ),
              _buildSubTile(
                'Get Extensions',
                icon: MdiIcons.puzzlePlus,
                onTap: () async {
                  Navigator.pop(context);
                  final tabMode = TabMode.fromTabType(
                    ref
                        .read(generalSettingsWithDefaultsProvider)
                        .effectiveDefaultCreateTabType,
                  );
                  await ref
                      .read(tabRepositoryProvider.notifier)
                      .addTab(
                        url: Uri.parse('https://addons.mozilla.org'),
                        tabMode: tabMode,
                        containerSelection:
                            const TabContainerSelection.unassigned(),
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

// ─── Quick Links Grid ───

class _QuickLinksGrid extends ConsumerWidget {
  final bool showContainerUi;

  const _QuickLinksGrid({required this.showContainerUi});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final torConnected = ref.watch(
      torProxyServiceProvider.select((value) => value.value?.isRunning == true),
    );

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildGridItem(
                context,
                Icons.history,
                'History',
                () async {
                  Navigator.pop(context);
                  await const HistoryRoute().push(context);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildGridItem(
                context,
                MdiIcons.bookmarkMultiple,
                'Bookmarks',
                () async {
                  Navigator.pop(context);
                  await BookmarkListRoute(
                    entryGuid: BookmarkRoot.root.id,
                  ).push(context);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildGridItem(
                context,
                MdiIcons.fileDownload,
                'Downloads',
                () async {
                  Navigator.pop(context);
                  await const HistoryDownloadsRoute().push(context);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildGridItem(
                context,
                MdiIcons.exclamationThick,
                'Bangs',
                () async {
                  Navigator.pop(context);
                  await const BangMenuRoute().push(context);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildGridItem(
                context,
                TorIcons.onionAlt,
                'Tor\u2122 Proxy',
                () async {
                  Navigator.pop(context);
                  await const TorProxyRoute().push(context);
                },
                badge: torConnected,
                badgeColor: AppColors.of(context).torActiveGreen,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildGridItem(context, Icons.rss_feed, 'Feeds', () async {
                Navigator.pop(context);
                await context.push(FeedListRoute().location);
              }),
            ),
            const SizedBox(width: 8),
            const Expanded(child: SizedBox.shrink()),
            const SizedBox(width: 8),
            const Expanded(child: SizedBox.shrink()),
          ],
        ),
      ],
    );
  }

  Widget _buildGridItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool badge = false,
    Color? badgeColor,
  }) {
    final iconWidget = Icon(
      icon,
      color: Theme.of(context).colorScheme.onSurface,
    );

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (badge)
                Badge(backgroundColor: badgeColor, child: iconWidget)
              else
                iconWidget,
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Profile Card ───

class _ProfileCard extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(selectedProfileProvider);
    final isAuthenticated = ref.watch(syncIsAuthenticatedProvider);

    return _buildMenuCard(
      context,
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(
              Icons.person,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          title: Text(profile.value?.name ?? 'User'),
          subtitle: Text(
            'Tap to switch profile',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          onTap: () async {
            Navigator.pop(context);
            await const SelectProfileRoute().push(context);
          },
        ),

        // Sync Now (conditional)
        if (isAuthenticated) ...[_buildDivider(), _SyncTile()],

        _buildDivider(),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Settings'),
          onTap: () async {
            Navigator.pop(context);
            await SettingsRoute().push(context);
          },
        ),

        _buildDivider(),
        ListTile(
          leading: Icon(MdiIcons.power, color: theme.colorScheme.error),
          title: Text(
            'Quit Browser',
            style: TextStyle(color: theme.colorScheme.error),
          ),
          onTap: () async {
            Navigator.pop(context);
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

class _SyncTile extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

        if (context.mounted) Navigator.pop(context);
      },
    );
  }
}

// ─── Settings & App Card ───

class _SettingsCard extends StatelessWidget {
  const _SettingsCard();

  @override
  Widget build(BuildContext context) {
    return _buildMenuCard(
      context,
      children: [
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('About'),
          onTap: () async {
            Navigator.pop(context);
            await AboutRoute().push(context);
          },
        ),
      ],
    );
  }
}
