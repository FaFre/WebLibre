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
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_detail_state.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/utils/close_tab_helper.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/utils/tab_close_confirmation.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_icon.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_lock_badge.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_sleep_badge.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_depth_indicator.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_swipe_actions.dart';
import 'package:weblibre/features/geckoview/features/find_in_page/presentation/utils/find_in_page_suggestion.dart';
import 'package:weblibre/features/geckoview/features/split_view/presentation/widgets/split_member_mark.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/web_search/domain/controllers/sandbox_capture_controller.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/hooks/menu_controller.dart';
import 'package:weblibre/presentation/widgets/safe_raw_image.dart';
import 'package:weblibre/presentation/widgets/uri_breadcrumb.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

class GridTabItemContainer extends StatelessWidget {
  final bool isActive;
  final TabMode tabMode;
  final Widget? child;

  const GridTabItemContainer({
    required this.isActive,
    required this.tabMode,
    this.child,
    super.key,
  });

  static const borderRadius = BorderRadius.all(Radius.circular(12.0));

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appColors = AppColors.of(context);

    final bgColor = switch (tabMode) {
      PrivateTabMode() => appColors.privateTabBackground.withAlpha(80),
      IsolatedTabMode() => appColors.isolatedTabBackground.withAlpha(80),
      RegularTabMode() => colorScheme.surfaceContainerHigh,
    };

    final borderWidth = isActive ? 4.0 : 3.0;
    final innerRadius = BorderRadius.all(Radius.circular(12.0 - borderWidth));

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isActive
              ? colorScheme.primary
              : colorScheme.outline.withAlpha(40),
          width: borderWidth,
        ),
        borderRadius: borderRadius,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: colorScheme.primary.withAlpha(60),
                  blurRadius: 8.0,
                  spreadRadius: 1.0,
                ),
              ]
            : null,
      ),
      child: Material(
        color: colorScheme.surface,
        borderRadius: innerRadius,
        clipBehavior: Clip.antiAlias,
        child: Material(color: bgColor, child: child),
      ),
    );
  }
}

class GridTabPreview extends HookConsumerWidget {
  final String tabId;
  final bool isActive;

  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onDelete;
  final void Function(String host)? onDeleteAll;
  final VoidCallback? onCloseSubtree;

  final bool showPinBadge;

  final Widget? trailingChild;

  /// Hierarchy widget rendered in the top-left corner alongside any
  /// pin badge / [trailingChild]. Used by the tabs grid to inline the
  /// expand/collapse toggle without overlay layers.
  final Widget? groupToggle;

  /// Tree depth (>= 1 for any child). Renders a stack of overlapping
  /// subdirectory glyphs in the bottom-left of the thumbnail to signal
  /// nesting level at a glance.
  final int depth;

  const GridTabPreview({
    required this.tabId,
    required this.isActive,
    this.onTap,
    this.onDoubleTap,
    this.onDelete,
    this.onDeleteAll,
    this.onCloseSubtree,
    this.showPinBadge = false,
    this.trailingChild,
    this.groupToggle,
    this.depth = 0,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final appColors = AppColors.of(context);

    final tabState =
        ref.watch(
          tabStateWithFallbackProvider(
            tabId,
          ).select((asyncValue) => asyncValue.value),
        ) ??
        TabState.$default(tabId);

    final thumbnail = ref.watch(tabThumbnailProvider(tabId));

    final sandboxSourceUri = ref.watch(
      sandboxSourceUriForTabProvider(tabId: tabId),
    );
    final displayUrl = sandboxSourceUri ?? tabState.url;
    final displayTitle = sandboxSourceUri != null && tabState.title.isEmpty
        ? sandboxSourceUri.authority
        : tabState.titleOrAuthority;

    final extendedDeleteMenuController = useMenuController();

    final isPinned = ref.watch(
      tabPinBadgeShownProvider(tabId, enabled: showPinBadge),
    );
    final isLocked = ref.watch(isTabLockedProvider(tabId));
    final unlockIncomplete = ref.watch(isTabUnlockIncompleteProvider(tabId));
    final hasCloseButton =
        onDelete != null || onDeleteAll != null || onCloseSubtree != null;

    final modeTextColor = switch (tabState.tabMode) {
      PrivateTabMode() => appColors.privateTabForeground,
      IsolatedTabMode() => appColors.isolatedTabForeground,
      RegularTabMode() => null,
    };

    final subtitleColor = switch (tabState.tabMode) {
      PrivateTabMode() => Color.lerp(
        appColors.privateTabPurple,
        Colors.white,
        0.4,
      )!,
      IsolatedTabMode() => Color.lerp(
        appColors.isolatedTabTeal,
        Colors.white,
        0.4,
      )!,
      RegularTabMode() => colorScheme.onSurfaceVariant,
    };

    final (modeBadgeIcon, modeBadgeColor) = switch (tabState.tabMode) {
      PrivateTabMode() => (MdiIcons.dominoMask, appColors.privateTabPurple),
      IsolatedTabMode() => (MdiIcons.snowflake, appColors.isolatedTabTeal),
      RegularTabMode() => (null, null),
    };

    return GridTabItemContainer(
      isActive: isActive,
      tabMode: tabState.tabMode,
      // The active tab is only told apart by its outline otherwise.
      child: Semantics(
        selected: isActive,
        child: InkWell(
          borderRadius: GridTabItemContainer.borderRadius,
          onTap: onTap,
          onDoubleTap: onDoubleTap,
          child: Column(
            children: [
              // Thumbnail or icon area
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (thumbnail != null && !thumbnail.isDisposed)
                      RepaintBoundary(
                        child: SafeRawImage(
                          image: thumbnail,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Center(child: TabIcon(tabState: tabState, iconSize: 48)),
                    // Close button overlay
                    if (hasCloseButton)
                      Positioned(
                        top: 0.0,
                        right: 0.0,
                        child: MenuAnchor(
                          controller: extendedDeleteMenuController,
                          builder: (context, controller, child) {
                            return child!;
                          },
                          menuChildren: [
                            MenuItemButton(
                              onPressed: () {
                                onDeleteAll?.call(displayUrl.host);
                              },
                              leadingIcon: const Icon(Icons.language),
                              child: Text(l10n.browser_closeFromSameHost),
                            ),
                            if (onCloseSubtree != null)
                              MenuItemButton(
                                onPressed: onCloseSubtree,
                                leadingIcon: const Icon(Icons.account_tree),
                                child: Text(
                                  l10n.browser_closeTabAndDescendants,
                                ),
                              ),
                          ],
                          child: _GridCloseButton(
                            onTap: onDelete,
                            locked: isLocked,
                            unlockIncomplete: unlockIncomplete,
                            onLongPress:
                                onDeleteAll != null || onCloseSubtree != null
                                ? () {
                                    if (extendedDeleteMenuController.isOpen) {
                                      extendedDeleteMenuController.close();
                                    } else {
                                      extendedDeleteMenuController.open();
                                    }
                                  }
                                : null,
                          ),
                        ),
                      ),
                    if (depth > 0)
                      Positioned(
                        bottom: 6.0,
                        left: 6.0,
                        child: TabDepthIndicator(depth: depth),
                      ),
                    Positioned(
                      bottom: 6.0,
                      right: 6.0,
                      child: SplitMemberMark(
                        tabId: tabId,
                        size: 16,
                        withBackground: true,
                      ),
                    ),
                    // Always there: the lock, sleep, frozen and keep-awake
                    // badges show for any tab, and are empty otherwise. Each
                    // shown item keeps 4 px to the next, in the tab list's
                    // order.
                    Positioned(
                      top: 6.0,
                      left: 6.0,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (groupToggle != null) ...[
                            groupToggle!,
                            const SizedBox(width: 4),
                          ],
                          if (trailingChild != null) ...[
                            trailingChild!,
                            const SizedBox(width: 4),
                          ],
                          if (isPinned)
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: SizedBox(
                                width: 28,
                                height: 28,
                                child: Material(
                                  color: colorScheme.surfaceContainerHighest
                                      .withAlpha(200),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                  child: InkWell(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    onTap: () async {
                                      await ref
                                          .read(
                                            tabDataRepositoryProvider.notifier,
                                          )
                                          .setPinned(tabId, pinned: false);

                                      if (context.mounted) {
                                        ui_helper.showInfoMessage(
                                          context,
                                          l10n.browser_tabUnpinned,
                                          action: SnackBarAction(
                                            label: l10n.common_undo,
                                            onPressed: () async {
                                              await ref
                                                  .read(
                                                    tabDataRepositoryProvider
                                                        .notifier,
                                                  )
                                                  .setPinned(
                                                    tabId,
                                                    pinned: true,
                                                  );
                                            },
                                          ),
                                        );
                                      }
                                    },
                                    child: Icon(
                                      MdiIcons.pin,
                                      size: 16,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ..._stateBadges(
                            tabId,
                            size: 16,
                            withBackground: true,
                            // The close button shows the lock instead.
                            withLock: !hasCloseButton,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Bottom info band
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withAlpha(120),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: modeTextColor,
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Row(
                      children: [
                        TabIcon(tabState: tabState, iconSize: 14.0),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            displayUrl.authority,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
                              color: subtitleColor,
                            ),
                          ),
                        ),
                        if (modeBadgeIcon != null) ...[
                          const SizedBox(width: 4),
                          Icon(modeBadgeIcon, color: modeBadgeColor, size: 14),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ListTabPreview extends HookConsumerWidget {
  final String tabId;
  final bool isActive;

  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final void Function(String host)? onDeleteAll;
  final VoidCallback? onCloseSubtree;

  final bool showPinBadge;

  final Widget? trailingChild;

  /// Hierarchy widget rendered inside the trailing row, just before the
  /// close button. Used to inline the group expand/collapse toggle.
  final Widget? groupToggle;

  /// Tree depth of this row. Used to render an integrated indent guide
  /// (vertical bar + L-stub) on the leading edge of the tile.
  final int depth;

  const ListTabPreview({
    required this.tabId,
    required this.isActive,
    this.onTap,
    this.onDelete,
    this.onDeleteAll,
    this.onCloseSubtree,
    this.showPinBadge = false,
    this.trailingChild,
    this.groupToggle,
    this.depth = 0,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final appColors = AppColors.of(context);

    final tabState =
        ref.watch(
          tabStateWithFallbackProvider(
            tabId,
          ).select((asyncValue) => asyncValue.value),
        ) ??
        TabState.$default(tabId);

    final sandboxSourceUri = ref.watch(
      sandboxSourceUriForTabProvider(tabId: tabId),
    );
    final displayUrl = sandboxSourceUri ?? tabState.url;
    final displayTitle = sandboxSourceUri != null && tabState.title.isEmpty
        ? sandboxSourceUri.authority
        : tabState.titleOrAuthority;

    final tabListShowFavicons = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.tabListShowFavicons),
    );

    // Only the leading tile renders the thumbnail, and only when favicons are
    // off — don't subscribe to screenshot churn otherwise (no tab, no
    // thumbnail).
    final thumbnail = ref.watch(
      tabThumbnailProvider(tabListShowFavicons ? null : tabId),
    );

    final extendedDeleteMenuController = useMenuController();

    final isPinned = ref.watch(
      tabPinBadgeShownProvider(tabId, enabled: showPinBadge),
    );
    final isLocked = ref.watch(isTabLockedProvider(tabId));
    final unlockIncomplete = ref.watch(isTabUnlockIncompleteProvider(tabId));
    final hasCloseButton =
        onDelete != null || onDeleteAll != null || onCloseSubtree != null;

    final leadingWidget = switch ((tabListShowFavicons, thumbnail)) {
      (false, final thumbnail?) when !thumbnail.isDisposed => ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        child: RepaintBoundary(
          child: SafeRawImage(image: thumbnail, fit: BoxFit.fitHeight),
        ),
      ),
      _ => TabIcon(tabState: tabState, iconSize: 32),
    };

    final listBgColor = switch (tabState.tabMode) {
      PrivateTabMode() => appColors.privateTabBackground.withAlpha(80),
      IsolatedTabMode() => appColors.isolatedTabBackground.withAlpha(80),
      RegularTabMode() when isActive => colorScheme.primary.withAlpha(20),
      RegularTabMode() => Colors.transparent,
    };
    final listTextColor = switch (tabState.tabMode) {
      PrivateTabMode() => appColors.privateTabForeground,
      IsolatedTabMode() => appColors.isolatedTabForeground,
      RegularTabMode() => null,
    };
    final (modeBadgeIcon, modeBadgeColor) = switch (tabState.tabMode) {
      PrivateTabMode() => (MdiIcons.dominoMask, appColors.privateTabPurple),
      IsolatedTabMode() => (MdiIcons.snowflake, appColors.isolatedTabTeal),
      RegularTabMode() => (null, null),
    };

    final subtitleColor = switch (tabState.tabMode) {
      PrivateTabMode() => Color.lerp(
        appColors.privateTabPurple,
        Colors.white,
        0.4,
      )!,
      IsolatedTabMode() => Color.lerp(
        appColors.isolatedTabTeal,
        Colors.white,
        0.4,
      )!,
      RegularTabMode() => colorScheme.onSurfaceVariant,
    };

    const borderRadius = BorderRadius.all(Radius.circular(12.0));

    final card = Container(
      margin: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 4.0),
      decoration: BoxDecoration(
        color: listBgColor,
        borderRadius: borderRadius,
        border: isActive
            ? Border(left: BorderSide(color: colorScheme.primary, width: 4.0))
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        // The active tab is only told apart by its edge otherwise.
        child: Semantics(
          selected: isActive,
          child: InkWell(
            borderRadius: borderRadius,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 12.0,
                top: 10.0,
                bottom: 10.0,
              ),
              child: Row(
                children: [
                  leadingWidget,
                  const SizedBox(width: 14.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          displayTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: listTextColor,
                          ),
                        ),
                        const SizedBox(height: 3.0),
                        Row(
                          children: [
                            if (isPinned) ...[
                              Icon(
                                MdiIcons.pin,
                                color: colorScheme.primary,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                            ],
                            // The close button shows the lock instead.
                            ..._stateBadges(tabId, withLock: !hasCloseButton),
                            SplitMemberMark(
                              tabId: tabId,
                              padding: const EdgeInsets.only(right: 4),
                            ),
                            if (modeBadgeIcon != null) ...[
                              Icon(
                                modeBadgeIcon,
                                color: modeBadgeColor,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Expanded(
                              child: UriBreadcrumb(
                                uri: displayUrl,
                                showHttpScheme: false,
                                style: textTheme.bodySmall?.copyWith(
                                  color: subtitleColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ?groupToggle,
                  if (hasCloseButton)
                    MenuAnchor(
                      controller: extendedDeleteMenuController,
                      builder: (context, controller, child) {
                        return child!;
                      },
                      menuChildren: [
                        MenuItemButton(
                          onPressed: () {
                            onDeleteAll?.call(displayUrl.host);
                          },
                          leadingIcon: const Icon(Icons.language),
                          child: Text(l10n.browser_closeFromSameHost),
                        ),
                        if (onCloseSubtree != null)
                          MenuItemButton(
                            onPressed: onCloseSubtree,
                            leadingIcon: const Icon(Icons.account_tree),
                            child: Text(l10n.browser_closeTabAndDescendants),
                          ),
                      ],
                      child: IconButton(
                        tooltip: isLocked
                            ? l10n.browser_tabIsLocked
                            : l10n.browser_tooltipCloseTab,
                        onPressed: onDelete,
                        onLongPress:
                            onDeleteAll != null || onCloseSubtree != null
                            ? () {
                                if (extendedDeleteMenuController.isOpen) {
                                  extendedDeleteMenuController.close();
                                } else {
                                  extendedDeleteMenuController.open();
                                }
                              }
                            : null,
                        // A locked tab does not close: its lock takes the
                        // close button's place, the tap says so and offers
                        // Unlock, and closing by host or subtree stays.
                        icon: Icon(
                          _closeSlotIcon(
                            locked: isLocked,
                            unlockIncomplete: unlockIncomplete,
                          ),
                          size: 20,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ?trailingChild,
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (depth <= 0) {
      return card;
    }

    final levels = math.min(depth, _listMaxIndentLevels);
    final indentWidth = levels * _listIndentStep;
    final guideColor = colorScheme.outlineVariant.withAlpha(150);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: indentWidth,
          child: CustomPaint(
            painter: _IndentGuidePainter(
              color: guideColor,
              stubInsetFromRight: 8.0,
            ),
          ),
        ),
        Expanded(child: card),
      ],
    );
  }
}

const double _listIndentStep = 16.0;
const int _listMaxIndentLevels = 3;

class _IndentGuidePainter extends CustomPainter {
  final Color color;
  final double stubInsetFromRight;

  _IndentGuidePainter({required this.color, required this.stubInsetFromRight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final guideX = size.width - stubInsetFromRight;
    // L-stub is centred vertically in the row so it tracks the tile's
    // mid-line regardless of itemExtent changes.
    final stubY = size.height / 2;

    canvas.drawLine(Offset(guideX, 0), Offset(guideX, size.height), paint);
    canvas.drawLine(Offset(guideX, stubY), Offset(size.width, stubY), paint);
  }

  @override
  bool shouldRepaint(covariant _IndentGuidePainter old) =>
      old.color != color || old.stubInsetFromRight != stubInsetFromRight;
}

class SyncedListTabPreview extends StatelessWidget {
  const SyncedListTabPreview({
    super.key,
    required this.title,
    required this.url,
    required this.deviceName,
    required this.onTap,
  });

  final String title;
  final Uri url;
  final String deviceName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.only(left: 8, right: 6),
      leading: UrlIcon([url], iconSize: 20),
      title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.devices, size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  deviceName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          UriBreadcrumb(uri: url, showHttpScheme: false),
        ],
      ),
      trailing: const Icon(Icons.open_in_new),
    );
  }
}

class SingleGridTabPreview extends HookConsumerWidget {
  final String tabId;
  final String? activeTabId;
  final String? sourceSearchQuery;
  final double deleteThreshold;

  final void Function() onClose;
  final void Function()? onDeleted;

  final Widget? groupToggle;
  final int depth;

  const SingleGridTabPreview({
    required this.tabId,
    required this.activeTabId,
    required this.onClose,
    required this.sourceSearchQuery,
    this.deleteThreshold = 100,
    this.onDeleted,
    this.groupToggle,
    this.depth = 0,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Built once per rebuild of *this* widget and handed to [TabSwipeActions]
    // as its child, so the drag never reconstructs it.
    final preview = RepaintBoundary(
      child: GridTabPreview(
        tabId: tabId,
        isActive: tabId == activeTabId,
        showPinBadge: true,
        groupToggle: groupToggle,
        depth: depth,
        onTap: () async {
          // Shown before onClose so it surfaces on the root messenger and
          // survives the tray closing.
          if (tabId != activeTabId) {
            offerFindInPage(
              context,
              ref.read,
              tabId: tabId,
              query: sourceSearchQuery,
            );
          }

          //Close first to avoid rebuilds
          onClose();
          // The active tab included: home can be drawn over it, and selecting
          // it again is what takes home down (#667).
          await ref.read(tabRepositoryProvider.notifier).selectTab(tabId);
        },
        onDeleteAll: (host) async {
          final containerId = await ref
              .read(tabDataRepositoryProvider.notifier)
              .getTabContainerId(tabId);

          final result = await ref
              .read(tabDataRepositoryProvider.notifier)
              .closeAllTabsByHost(containerId, host);

          if (context.mounted) {
            showTabCloseResult(
              context,
              result,
              ref.read(tabRepositoryProvider.notifier).undoClose,
            );
          }
        },
        onCloseSubtree: () async {
          final subtreeIds = await ref
              .read(tabDataRepositoryProvider.notifier)
              .getContainerTabDescendants(tabId)
              .then((descendants) => descendants.keys.toList());
          if (!context.mounted) return;

          final result = await closeTabsWithConfirmation(
            context,
            ref,
            subtreeIds,
          );

          if (context.mounted && result != null) {
            showTabCloseResult(
              context,
              result,
              ref.read(tabRepositoryProvider.notifier).undoClose,
            );
          }
        },
        onDelete: () => closeTabWithConfirmationAndUndoUsing(
          context,
          ref.read,
          tabId,
          onRemoved: onDeleted,
        ),
      ),
    );

    return TabSwipeActions(
      tabId: tabId,
      threshold: deleteThreshold,
      child: preview,
    );
  }
}

class SingleListTabPreview extends HookConsumerWidget {
  final String tabId;
  final String? activeTabId;
  final String? sourceSearchQuery;
  final double deleteThreshold;

  final void Function() onClose;
  final void Function()? onDeleted;

  final Widget? groupToggle;
  final int depth;

  const SingleListTabPreview({
    required this.tabId,
    required this.activeTabId,
    required this.onClose,
    required this.sourceSearchQuery,
    this.deleteThreshold = 100,
    this.onDeleted,
    this.groupToggle,
    this.depth = 0,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preview = RepaintBoundary(
      child: ListTabPreview(
        tabId: tabId,
        isActive: tabId == activeTabId,
        showPinBadge: true,
        groupToggle: groupToggle,
        depth: depth,
        onTap: () async {
          // Shown before onClose so it surfaces on the root messenger and
          // survives the tray closing.
          if (tabId != activeTabId) {
            offerFindInPage(
              context,
              ref.read,
              tabId: tabId,
              query: sourceSearchQuery,
            );
          }

          //Close first to avoid rebuilds
          onClose();
          // The active tab included: home can be drawn over it, and selecting
          // it again is what takes home down (#667).
          await ref.read(tabRepositoryProvider.notifier).selectTab(tabId);
        },
        onDeleteAll: (host) async {
          final containerId = await ref
              .read(tabDataRepositoryProvider.notifier)
              .getTabContainerId(tabId);

          final result = await ref
              .read(tabDataRepositoryProvider.notifier)
              .closeAllTabsByHost(containerId, host);

          if (context.mounted) {
            showTabCloseResult(
              context,
              result,
              ref.read(tabRepositoryProvider.notifier).undoClose,
            );
          }
        },
        onCloseSubtree: () async {
          final subtreeIds = await ref
              .read(tabDataRepositoryProvider.notifier)
              .getContainerTabDescendants(tabId)
              .then((descendants) => descendants.keys.toList());
          if (!context.mounted) return;

          final result = await closeTabsWithConfirmation(
            context,
            ref,
            subtreeIds,
          );

          if (context.mounted && result != null) {
            showTabCloseResult(
              context,
              result,
              ref.read(tabRepositoryProvider.notifier).undoClose,
            );
          }
        },
        onDelete: () => closeTabWithConfirmationAndUndoUsing(
          context,
          ref.read,
          tabId,
          onRemoved: onDeleted,
        ),
      ),
    );

    return TabSwipeActions(
      tabId: tabId,
      threshold: deleteThreshold,
      child: preview,
    );
  }
}

class SuggestedSingleGridTabPreview extends StatelessWidget {
  final String tabId;

  final String? activeTabId;

  final void Function()? onTap;

  const SuggestedSingleGridTabPreview({
    required this.tabId,
    required this.activeTabId,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.5,
      child: GridTabPreview(
        tabId: tabId,
        isActive: tabId == activeTabId,
        onTap: onTap,
        trailingChild: SizedBox(
          width: 28,
          height: 28,
          child: Material(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withAlpha(200),
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            child: const Icon(MdiIcons.creation, size: 16),
          ),
        ),
      ),
    );
  }
}

class SuggestedSingleListTabPreview extends StatelessWidget {
  final String tabId;

  final String? activeTabId;

  final void Function()? onTap;

  const SuggestedSingleListTabPreview({
    required this.tabId,
    required this.activeTabId,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.5,
      child: ListTabPreview(
        tabId: tabId,
        isActive: tabId == activeTabId,
        onTap: onTap,
        trailingChild: const IconButton(
          visualDensity: VisualDensity(horizontal: -4.0, vertical: -4.0),
          icon: Icon(MdiIcons.creation),
          onPressed: null,
        ),
      ),
    );
  }
}

/// The close button in a grid tile's corner: 28dp to look at, with a 48dp
/// touch target reaching into the tile from that corner.
class _GridCloseButton extends StatelessWidget {
  final VoidCallback? onTap;

  /// Opens the menu of wider close actions.
  final VoidCallback? onLongPress;

  /// The tab is locked: its lock takes the close icon's place. The tap says
  /// so and offers Unlock, and the menu of wider close actions stays.
  final bool locked;

  /// The tab's unlock did not finish: the lock is drawn with an alert.
  final bool unlockIncomplete;

  const _GridCloseButton({
    required this.onTap,
    required this.onLongPress,
    this.locked = false,
    this.unlockIncomplete = false,
  });

  static const _inset = 6.0;
  static const _visualSize = 28.0;
  static const _borderRadius = BorderRadius.all(Radius.circular(8.0));

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: locked
          ? AppLocalizations.of(context).browser_tabIsLocked
          : AppLocalizations.of(context).browser_tooltipCloseTab,
      onTap: onTap,
      onLongPress: onLongPress,
      excludeSemantics: true,
      child: GestureDetector(
        // Takes the taps around the visible button; a tap on it reaches its
        // own InkWell first, which shows the ripple.
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        onLongPress: onLongPress,
        child: SizedBox.square(
          dimension: kMinInteractiveDimension,
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: _inset, right: _inset),
              child: SizedBox.square(
                dimension: _visualSize,
                child: Material(
                  color: colorScheme.surfaceContainerHighest.withAlpha(200),
                  borderRadius: _borderRadius,
                  child: InkWell(
                    borderRadius: _borderRadius,
                    onTap: onTap,
                    onLongPress: onLongPress,
                    child: Icon(
                      _closeSlotIcon(
                        locked: locked,
                        unlockIncomplete: unlockIncomplete,
                      ),
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The close button's icon: the tab's lock instead while it is locked, as
/// its lock badge draws it.
IconData _closeSlotIcon({
  required bool locked,
  required bool unlockIncomplete,
}) => unlockIncomplete
    ? MdiIcons.lockAlertOutline
    : locked
    ? MdiIcons.lockOutline
    : Icons.close;

/// The lock, sleep and keep-awake badges of [tabId], in that order; each
/// takes no space when it does not apply. Without [withLock] when the card's
/// close button shows the lock in its place.
List<Widget> _stateBadges(
  String tabId, {
  double size = 14,
  bool withBackground = false,
  bool withLock = true,
}) {
  const padding = EdgeInsets.only(right: 4);
  return [
    if (withLock)
      TabLockBadge(
        tabId: tabId,
        size: size,
        withBackground: withBackground,
        padding: padding,
      ),
    TabSleepBadge(
      tabId: tabId,
      size: size,
      withBackground: withBackground,
      padding: padding,
    ),
    TabKeepAwakeBadge(
      tabId: tabId,
      size: size,
      withBackground: withBackground,
      padding: padding,
    ),
  ];
}
