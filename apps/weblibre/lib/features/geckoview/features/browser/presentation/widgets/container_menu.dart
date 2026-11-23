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
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_container_selection.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/repositories/bookmarks.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/browser_data.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_view_controllers.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/dialogs/bookmark_all_dialog.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/dialogs/select_folder_dialog.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/utils/close_tab_helper.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/utils/container_freeze_actions.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/utils/tab_close_confirmation.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/utils/tab_sleep_actions.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/dialogs/clear_container_data_dialog.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/dialogs/close_all_private_tabs_dialog.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/dialogs/close_all_tabs_dialog.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/container_freeze.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/screens/container_sites.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/utils/container_actions.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/utils/container_freeze_l10n.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/background_tab_open.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/hooks/menu_controller.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

/// Context menu for a container, mirroring [TabMenu] for tabs.
///
/// Used both by the container chips / accordion headers (long press) and by the
/// tab view's action button, which scopes the tab-bulk actions to the currently
/// selected container. Keeping a single implementation is deliberate: the two
/// entry points previously carried separate copies of the close/bookmark/clear
/// flows and drifted apart.
///
/// The two identity parameters are separate on purpose: [container] is the row
/// the container-level actions edit, [scopeContainerId] is what the tab-bulk
/// actions address. Callers that always hold a loaded row pass `container?.id`
/// for both; the tab view header can't, because its row loads asynchronously
/// while the selected id is known immediately.
///
/// Both may be null, which addresses the "unassigned" pseudo-container.
/// Actions that need a real container row (edit, pin, delete, assigned sites,
/// new tab) and those that need cookie isolation (clear data) hide themselves
/// accordingly, so callers don't have to.
class ContainerMenu extends HookConsumerWidget {
  final MenuAnchorChildBuilder builder;
  final MenuController? controller;

  /// The container row the container-level actions (pin, edit, assigned sites,
  /// clear data, delete) act on. Null hides all of them — either because this
  /// is the unassigned pseudo-container, or because the row hasn't loaded yet.
  final ContainerData? container;

  /// Container the tab-bulk actions (close, bookmark all) are scoped to.
  ///
  /// Deliberately separate from [container] rather than derived from it: null
  /// is a *real* scope here — the DAO maps it to `tab.container_id IS NULL` —
  /// so a caller whose container row is still loading would otherwise
  /// silently close/bookmark the unassigned tabs instead of the selected
  /// container's. Callers that hold the id independently (the tab view header
  /// watches `selectedContainerProvider`) must pass it from there.
  final String? scopeContainerId;

  /// When false every mutating action is greyed out. Used for the synced-tabs
  /// scope, where none of them apply to the visible tabs.
  final bool enabled;

  final bool enableNewTab;
  final bool enablePin;
  final bool enableCloseTabs;

  /// Adds "Filtered Tabs" to the close submenu. Only meaningful where a tab
  /// filter is actually in effect (the tab list/grid).
  final bool enableCloseFilteredTabs;

  final bool enableBookmarkAll;

  /// Adds Freeze, Stop freezing, Retry and Resume for [container] (7.2);
  /// each decides for itself whether it applies.
  final bool enableFreeze;

  final bool enableAssignedSites;
  final bool enableClearData;
  final bool enableEdit;
  final bool enableDelete;

  const ContainerMenu({
    super.key,
    required this.builder,
    required this.container,
    required this.scopeContainerId,
    this.controller,
    this.enabled = true,
    this.enableNewTab = false,
    this.enablePin = false,
    this.enableCloseTabs = true,
    this.enableCloseFilteredTabs = false,
    this.enableBookmarkAll = true,
    this.enableFreeze = true,
    this.enableAssignedSites = false,
    this.enableClearData = true,
    this.enableEdit = false,
    this.enableDelete = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = this.controller ?? useMenuController();

    final closeIsolatedShown = ref.watch(
      closeIsolatedTabsShownProvider(scopeContainerId),
    );
    final sleepShown = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (settings) => settings.isFeatureShown(FeatureId.tabsSleep),
      ),
    );

    final container = this.container;
    final contextualIdentity = container?.metadata.contextualIdentity;

    /// Every close item ends here, so closing the last tab of an isolation
    /// group always asks first — "Close all tabs" may no longer have, once
    /// its own question is answered with "Don't ask again".
    ///
    /// [confirm] is the item's own question. It is asked in place of the
    /// groups' one, not after it: see [confirmBulkTabCloseIfNeeded].
    Future<void> closeTabs({
      bool includeRegular = true,
      bool includePrivate = true,
      bool includeIsolated = true,
      Future<bool> Function()? confirm,
    }) async {
      final tabIds = await ref
          .read(tabDataRepositoryProvider.notifier)
          .getContainerTabIds(
            scopeContainerId,
            includeRegular: includeRegular,
            includePrivate: includePrivate,
            includeIsolated: includeIsolated,
          );

      if (!context.mounted ||
          !await confirmBulkTabCloseIfNeeded(
            context,
            ref,
            tabIds,
            otherwise: confirm,
          )) {
        return;
      }

      if (tabIds.isEmpty) return;
      final result = await ref
          .read(tabRepositoryProvider.notifier)
          .closeTabs(tabIds);

      if (context.mounted) {
        showTabCloseResult(
          context,
          result,
          ref.read(tabRepositoryProvider.notifier).undoClose,
        );
      }
    }

    final canEdit = enabled && container != null;
    // Non-null exactly when the clear-data item should show: it wipes a Gecko
    // storage partition, which only an isolated container has.
    final clearDataContextId = enableClearData ? contextualIdentity : null;
    final hasTrailingSection =
        enableAssignedSites && container != null ||
        clearDataContextId != null ||
        enableEdit && container != null;

    return MenuAnchor(
      controller: controller,
      consumeOutsideTap: true,
      builder: builder,
      menuChildren: [
        if (enableNewTab)
          MenuItemButton(
            leadingIcon: const Icon(MdiIcons.tabPlus),
            onPressed: enabled
                ? () async {
                    final tabs = ref.read(tabRepositoryProvider.notifier);
                    // A container being deleted refuses the tab.
                    final tabId = await openUnlessContainerRefuses(
                      context,
                      () => tabs.addTab(
                        tabMode: TabMode.regular,
                        selectTab: false,
                        containerSelection: container == null
                            ? const TabContainerSelection.unassigned()
                            : TabContainerSelection.specific(container),
                      ),
                    );

                    if (tabId != null && context.mounted) {
                      handleBackgroundTabOpened(context, ref, tabId);
                    }
                  }
                : null,
            child: Text(l10n.browser_containerMenuNewTab),
          ),
        if (enablePin && container != null)
          MenuItemButton(
            closeOnActivate: false,
            leadingIcon: Icon(
              container.isPinned ? MdiIcons.pinOff : MdiIcons.pin,
            ),
            onPressed: enabled
                ? () async {
                    await ref
                        .read(containerRepositoryProvider.notifier)
                        .setContainerPinned(
                          container.id,
                          isPinned: !container.isPinned,
                        );

                    if (context.mounted) {
                      MenuController.maybeOf(context)?.close();
                    }
                  }
                : null,
            child: Text(
              container.isPinned
                  ? l10n.browser_unpinContainer
                  : l10n.browser_pinContainer,
            ),
          ),
        if (enableNewTab || enablePin && container != null) const Divider(),
        if (enableCloseTabs)
          SubmenuButton(
            leadingIcon: const Icon(MdiIcons.closeCircle),
            menuChildren: [
              MenuItemButton(
                leadingIcon: const Icon(MdiIcons.closeCircle),
                onPressed: enabled
                    ? () async {
                        await closeTabs(
                          confirm: () =>
                              showCloseAllTabsDialog(context, ref.read),
                        );
                      }
                    : null,
                child: Text(l10n.browser_closeSubmenuAllTabs),
              ),
              MenuItemButton(
                leadingIcon: Icon(
                  MdiIcons.dominoMask,
                  color: AppColors.of(context).privateTabPurple,
                ),
                onPressed: enabled
                    ? () async {
                        final result = await showCloseAllPrivateTabsDialog(
                          context,
                        );
                        if (result == true) {
                          await closeTabs(
                            includeRegular: false,
                            includeIsolated: false,
                          );
                        }
                      }
                    : null,
                child: Text(l10n.browser_closeSubmenuPrivateTabs),
              ),
              if (closeIsolatedShown)
                MenuItemButton(
                  leadingIcon: Icon(
                    MdiIcons.snowflake,
                    color: AppColors.of(context).isolatedTabTeal,
                  ),
                  onPressed: enabled
                      ? () async {
                          // closeTabs asks before deleting the groups' data.
                          await closeTabs(
                            includeRegular: false,
                            includePrivate: false,
                          );
                        }
                      : null,
                  child: Text(l10n.browser_closeSubmenuIsolatedTabs),
                ),
              if (enableCloseFilteredTabs)
                MenuItemButton(
                  leadingIcon: const Icon(MdiIcons.filterOutline),
                  onPressed:
                      enabled &&
                          ref
                              .read(tabViewFilterControllerProvider)
                              .hasActiveFilter
                      ? () async {
                          final filteredIds = await ref
                              .read(tabDataRepositoryProvider.notifier)
                              .getFilteredTabIds(scopeContainerId);

                          if (filteredIds.isEmpty || !context.mounted) return;

                          if (!await confirmBulkTabCloseIfNeeded(
                            context,
                            ref,
                            filteredIds,
                          )) {
                            return;
                          }

                          final result = await ref
                              .read(tabRepositoryProvider.notifier)
                              .closeTabs(filteredIds);

                          if (context.mounted) {
                            showTabCloseResult(
                              context,
                              result,
                              ref
                                  .read(tabRepositoryProvider.notifier)
                                  .undoClose,
                            );
                          }
                        }
                      : null,
                  child: Text(l10n.browser_closeSubmenuFilteredTabs),
                ),
            ],
            child: Text(l10n.browser_menuCloseTabs),
          ),
        if (enableCloseTabs && sleepShown)
          MenuItemButton(
            leadingIcon: const Icon(MdiIcons.sleep),
            onPressed: enabled
                ? () async {
                    final tabIds = await ref
                        .read(tabDataRepositoryProvider.notifier)
                        .getContainerTabIds(scopeContainerId);
                    if (!context.mounted || tabIds.isEmpty) return;
                    await sleepTabsWithConfirmation(context, ref.read, tabIds);
                  }
                : null,
            child: Text(l10n.browser_menuSleepAllTabs),
          ),
        if (enableFreeze && container != null) ...[
          _FreezeContainerMenuItem(
            container: container,
            enabled: enabled,
            onFreeze: () =>
                freezeContainerWithConfirmation(context, ref.read, container),
            onResume: () =>
                resumeContainerWithFeedback(context, ref.read, container),
          ),
          _ResumeContainerMenuItem(
            containerId: container.id,
            enabled: enabled,
            onResume: () =>
                resumeContainerWithFeedback(context, ref.read, container),
          ),
        ],
        if (enableBookmarkAll)
          MenuItemButton(
            leadingIcon: const Icon(MdiIcons.bookmarkPlusOutline),
            onPressed: enabled
                ? () => _bookmarkAllTabs(context, ref, scopeContainerId)
                : null,
            child: Text(l10n.browser_menuBookmarkAll),
          ),
        if (hasTrailingSection) const Divider(),
        if (enableAssignedSites && container != null)
          MenuItemButton(
            leadingIcon: const Icon(Icons.web),
            onPressed: canEdit
                ? () => _editAssignedSites(context, ref, container)
                : null,
            child: Text(l10n.browser_menuAssignedSites),
          ),
        if (clearDataContextId != null)
          MenuItemButton(
            closeOnActivate: false,
            leadingIcon: const Icon(MdiIcons.databaseRemove),
            onPressed: enabled
                ? () async {
                    await _clearContainerData(
                      context,
                      ref,
                      container!,
                      clearDataContextId,
                    );

                    if (context.mounted) {
                      MenuController.maybeOf(context)?.close();
                    }
                  }
                : null,
            child: Text(l10n.browser_menuClearContainerData),
          ),
        if (enableEdit && container != null)
          MenuItemButton(
            leadingIcon: const Icon(Icons.tune),
            onPressed: canEdit
                ? () async {
                    await ContainerEditRoute(
                      containerData: jsonEncode(container.toJson()),
                    ).push(context);
                  }
                : null,
            child: Text(l10n.browser_menuEditContainer),
          ),
        if (enableDelete && container != null) ...[
          const Divider(),
          MenuItemButton(
            leadingIcon: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            onPressed: canEdit
                ? () async {
                    await confirmAndDeleteContainer(context, ref, container);
                  }
                : null,
            child: Text(l10n.browser_menuDeleteContainer),
          ),
        ],
      ],
    );
  }
}

/// A menu entry's title with the state line under it.
class _TitleWithState extends StatelessWidget {
  final String title;
  final String? state;

  const _TitleWithState({required this.title, required this.state});

  @override
  Widget build(BuildContext context) {
    final state = this.state;
    if (state == null) return Text(title);
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        ConstrainedBox(
          // Long states wrap instead of widening the menu past the screen.
          constraints: const BoxConstraints(maxWidth: 240),
          child: Text(
            state,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

/// "Freeze container", or while a freeze runs "Stop freezing and resume"
/// with its progress, or "Try freezing again" after one did not finish (5.4,
/// 7.2). Freeze follows the feature's visibility; stopping never hides (P5).
///
/// Only decides which entry applies; [ContainerMenu] runs it.
class _FreezeContainerMenuItem extends HookConsumerWidget {
  final ContainerData container;
  final bool enabled;
  final VoidCallback onFreeze;
  final VoidCallback onResume;

  const _FreezeContainerMenuItem({
    required this.container,
    required this.enabled,
    required this.onFreeze,
    required this.onResume,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final shown = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (settings) => settings.isFeatureShown(FeatureId.containerFreeze),
      ),
    );
    final view = ref.watch(containerFreezeStateProvider(container.id));
    final progress = ref.watch(
      containerFreezeProgressProvider(
        container.id,
      ).select((value) => value.value),
    );
    final recovery = ref.watch(freezeRecoveryModeProvider);

    if (view != null && view.operation == LifecycleOperationState.freezing) {
      return MenuItemButton(
        onPressed: enabled ? onResume : null,
        leadingIcon: const Icon(MdiIcons.play),
        child: _TitleWithState(
          title: l10n.browser_stopFreezing,
          state: view.stateLabel(l10n, progress: progress),
        ),
      );
    }
    if (!shown || recovery) return const SizedBox.shrink();
    if (view != null) {
      if (view.phase != ContextFreezePhase.failed ||
          view.operation != LifecycleOperationState.idle) {
        return const SizedBox.shrink();
      }
      return MenuItemButton(
        onPressed: enabled ? onFreeze : null,
        leadingIcon: const Icon(MdiIcons.pause),
        child: Text(l10n.browser_retryFreeze),
      );
    }

    // Unavailable stays visible with its reason (7.2).
    final hasOwnStorage = container.metadata.contextualIdentity != null;
    return MenuItemButton(
      onPressed: enabled && hasOwnStorage ? onFreeze : null,
      leadingIcon: const Icon(MdiIcons.pause),
      child: _TitleWithState(
        title: l10n.browser_menuFreezeContainer,
        state: hasOwnStorage ? null : l10n.browser_freezeNeedsOwnStorage,
      ),
    );
  }
}

/// "Resume container" with the container's state under it, for a container
/// shown as frozen and not being frozen or resumed right now. Never hidden
/// (P5).
class _ResumeContainerMenuItem extends HookConsumerWidget {
  final String containerId;
  final bool enabled;
  final VoidCallback onResume;

  const _ResumeContainerMenuItem({
    required this.containerId,
    required this.enabled,
    required this.onResume,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final view = ref.watch(containerFreezeStateProvider(containerId));

    if (view == null || !view.showsFrozen) return const SizedBox.shrink();
    if (view.operation == LifecycleOperationState.freezing) {
      // "Stop freezing and resume" stands in for it.
      return const SizedBox.shrink();
    }
    final resuming = view.operation == LifecycleOperationState.resuming;
    return MenuItemButton(
      onPressed: enabled && !resuming ? onResume : null,
      leadingIcon: const Icon(MdiIcons.play),
      child: _TitleWithState(
        title: l10n.browser_resumeContainer,
        state: view.stateLabel(l10n),
      ),
    );
  }
}

Future<void> _bookmarkAllTabs(
  BuildContext context,
  WidgetRef ref,
  String? containerId,
) async {
  final choice = await showBookmarkAllDialog(context);
  if (choice == null || !context.mounted) {
    return;
  }

  final tabData = await ref
      .read(tabDataRepositoryProvider.notifier)
      .getContainerTabsData(containerId);

  if (choice == BookmarkAllChoice.fast) {
    if (!context.mounted) return;
    final folderGuid = await showSelectFolderDialog(context);
    if (folderGuid == null) return;

    final repository = ref.read(bookmarksRepositoryProvider.notifier);
    for (final tab in tabData) {
      if (tab.url != null) {
        await repository.addBookmark(
          parentGuid: folderGuid,
          url: tab.url!,
          title: tab.title ?? tab.url.toString(),
        );
      }
    }

    if (context.mounted) {
      final l10n = AppLocalizations.of(context);
      ui_helper.showInfoMessage(
        context,
        l10n.browser_bookmarksAddedCount(tabData.length),
      );
    }
  } else {
    for (final tab in tabData) {
      if (context.mounted) {
        await BookmarkEntryAddRoute(
          bookmarkInfo: jsonEncode(
            BookmarkInfo(title: tab.title, url: tab.url.toString()).encode(),
          ),
        ).push(context);
      }
    }
  }
}

Future<void> _editAssignedSites(
  BuildContext context,
  WidgetRef ref,
  ContainerData container,
) async {
  final result = await showDialog<Set<Uri>>(
    context: context,
    builder: (context) => ContainerSitesScreen(
      initialSites: container.metadata.assignedSites?.toSet() ?? {},
    ),
  );

  if (result == null) {
    return;
  }

  await ref
      .read(containerRepositoryProvider.notifier)
      .replaceContainer(
        container.copyWith.metadata(
          container.metadata.copyWith
              .assignedSites(result.isEmpty ? null : result.toList())
              .sanitized(),
        ),
      );
}

/// Close the container's tabs, wipe its Gecko storage partition and — if the
/// user asked for it — restore the tabs afterwards.
Future<void> _clearContainerData(
  BuildContext context,
  WidgetRef ref,
  ContainerData container,
  String contextualIdentity,
) async {
  final tabs = await ref
      .read(tabDataRepositoryProvider.notifier)
      .getContainerTabsData(container.id);

  if (!context.mounted) return;

  final result = await showClearContainerDataDialog(context, tabs.length);
  if (result?.confirmed != true) {
    return;
  }

  final shouldReopenTabs = result!.reopenTabs;

  // Isolated tabs reopen in their own contexts, which a frozen container may
  // refuse (D19): checked before anything is closed.
  final isolationContextIds = [
    for (final tab in tabs)
      if (tab.tabMode == TabModeDbValue.isolated) ?tab.isolationContextId,
  ];
  if (shouldReopenTabs &&
      isolationContextIds.isNotEmpty &&
      !await ref
          .read(tabRepositoryProvider.notifier)
          .mayAddIsolatedTabs(container.id, isolationContextIds)) {
    if (context.mounted) {
      ui_helper.showInfoMessage(
        context,
        AppLocalizations.of(context).browser_containerFrozen,
      );
    }
    return;
  }

  try {
    // Off the recently closed list, which would keep their back history
    // past the clearing. Locked tabs stay open: the clear closes their
    // sessions too, and they reload into the cleared storage with their back
    // history.
    final closed = await ref
        .read(tabDataRepositoryProvider.notifier)
        .closeContainerTabs(container.id, keepOffRecentlyClosed: true);
    // Nothing closed, because the tab locks could not be read: clearing now
    // would leave every tab open with its back history.
    if (closed.locksUnavailable) {
      if (context.mounted) {
        ui_helper.showErrorMessage(
          context,
          AppLocalizations.of(context).browser_closeFailed,
        );
      }
      return;
    }
    final closedTabIds = closed.removedTabIds.toSet();

    await ref
        .read(browserDataServiceProvider.notifier)
        .clearDataForContext(contextualIdentity);

    // Only what closed is reopened; a locked tab never left.
    final reopened = [
      for (final tab in tabs)
        if (closedTabIds.contains(tab.id)) tab,
    ];
    if (shouldReopenTabs && reopened.isNotEmpty) {
      await ref
          .read(tabRepositoryProvider.notifier)
          .addMultipleTabs(
            tabs: reopened.map((tab) {
              // Re-parent onto the nearest ancestor that survives, so the
              // restored hierarchy doesn't reference closed tabs.
              var parentId = tab.parentId;
              while (parentId != null && closedTabIds.contains(parentId)) {
                parentId = tabs
                    .firstWhereOrNull((old) => old.id == parentId)
                    ?.parentId;
              }

              return AddTabParams(
                url: tab.url.toString(),
                startLoading: true,
                parentId: parentId,
                private: tab.tabMode == TabModeDbValue.private,
                flags: LoadUrlFlags.NONE.toValue(),
                source: Internal.newTab.toValue(),
                contextId: tab.tabMode == TabModeDbValue.isolated
                    ? tab.isolationContextId ?? contextualIdentity
                    : contextualIdentity,
              );
            }).toList(),
            containerSelection: TabContainerSelection.specific(container),
          );
    }

    if (context.mounted) {
      final l10n = AppLocalizations.of(context);
      ui_helper.showInfoMessage(
        context,
        shouldReopenTabs
            ? l10n.browser_containerDataClearedSuccess
            : l10n.browser_containerDataClearedWithTabsClosed(
                closedTabIds.length,
              ),
      );
    }
  } catch (e, s) {
    logger.e('Failed to clear container data', error: e, stackTrace: s);
    if (context.mounted) {
      final l10n = AppLocalizations.of(context);
      ui_helper.showErrorMessage(
        context,
        l10n.browser_errorClearingData(e.toString()),
      );
    }
  }
}
