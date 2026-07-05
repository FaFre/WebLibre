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
import 'package:flutter/services.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/extensions/uri.dart';
import 'package:weblibre/features/geckoview/domain/controllers/bottom_sheet.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/sheet.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/providers/site_settings_badge_provider.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_icon.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/toolbar_button.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/container_colors.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/web_search/domain/controllers/sandbox_capture_controller.dart';
import 'package:weblibre/presentation/widgets/uri_breadcrumb.dart';

class CompactAppBarTitle extends ConsumerWidget {
  const CompactAppBarTitle({
    super.key,
    this.containerColor,
    this.useCustomColor = false,
  });

  final Color? containerColor;
  final bool useCustomColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabState = ref.watch(selectedTabStateProvider);
    final selectedTabType = ref.watch(selectedTabTypeProvider);
    final settings = ref.watch(generalSettingsWithDefaultsProvider);
    final isTabTuneledAsync = ref.watch(isTabTunneledProvider(tabState?.id));
    final siteSettingsBadgeState = ref.watch(
      showSiteSettingsBadgeProvider.select(
        (value) => value.value ?? SiteSettingsBadgeState.hidden,
      ),
    );

    if (tabState == null) {
      return _EmptyAppBarAddressField(
        onTap: () async {
          await SearchRoute(
            tabType: selectedTabType ?? settings.effectiveDefaultCreateTabType,
          ).push(context);
        },
      );
    }

    final sandboxSourceUri = ref.watch(
      sandboxSourceUriForTabProvider(tabId: tabState.id),
    );

    return CompactAppBarTitleView(
      tabState: tabState,
      isTabTunneled:
          isTabTuneledAsync.hasValue && isTabTuneledAsync.value == true,
      siteSettingsBadgeState: siteSettingsBadgeState,
      longPressUrlCopy: settings.tabBarLongPressUrlCopy,
      containerColor: containerColor,
      useCustomColor: useCustomColor,
      sandboxSourceUri: sandboxSourceUri,
      onSiteSettingsTap: () {
        ref
            .read(bottomSheetControllerProvider.notifier)
            .show(SiteSettingsSheet(tabState: tabState));
      },
      onTitleTap: () async {
        await SearchRoute(
          tabId: tabState.id,
          searchText: searchTextForTab(tabState, sandboxSourceUri),
          tabType: tabState.tabMode.toTabType(),
        ).push(context);
      },
    );
  }
}

class CompactAppBarTitleView extends StatelessWidget {
  const CompactAppBarTitleView({
    super.key,
    required this.tabState,
    required this.isTabTunneled,
    required this.siteSettingsBadgeState,
    required this.onSiteSettingsTap,
    required this.onTitleTap,
    this.tabIcon,
    this.longPressUrlCopy = true,
    this.containerColor,
    this.useCustomColor = false,
    this.sandboxSourceUri,
  });

  final TabState tabState;
  final bool isTabTunneled;
  final SiteSettingsBadgeState siteSettingsBadgeState;
  final VoidCallback onSiteSettingsTap;
  final VoidCallback onTitleTap;
  final Widget? tabIcon;
  final bool longPressUrlCopy;
  final Color? containerColor;
  final bool useCustomColor;
  final Uri? sandboxSourceUri;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = AppColors.of(context);
    final containerColor = this.containerColor;
    final containerPalette = containerColor != null
        ? ContainerColors.palette(
            context,
            containerColor,
            useCustomColor: useCustomColor,
          )
        : null;

    return Row(
      children: [
        ToolbarButton(
          onTap: onSiteSettingsTap,
          child: Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                tabIcon ?? TabIcon(tabState: tabState, iconSize: 24),
                if (siteSettingsBadgeState != SiteSettingsBadgeState.hidden)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Icon(
                      siteSettingsBadgeState == SiteSettingsBadgeState.improved
                          ? MdiIcons.shield
                          : MdiIcons.shieldAlert,
                      size: 10,
                      color:
                          siteSettingsBadgeState ==
                              SiteSettingsBadgeState.improved
                          ? Colors.green
                          : appColors.warningAmber,
                    ),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: onTitleTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: containerColor != null
                    ? containerPalette!.surfaceColor
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
                border: containerPalette != null
                    ? Border.all(color: containerPalette.outlineColor)
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (tabState.tabMode is PrivateTabMode) ...[
                    Icon(
                      MdiIcons.dominoMask,
                      color: appColors.privateTabPurple,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                  ] else if (tabState.tabMode is IsolatedTabMode) ...[
                    Icon(
                      MdiIcons.snowflake,
                      color: appColors.isolatedTabTeal,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                  ],
                  if (isTabTunneled) ...[
                    const Icon(MdiIcons.tunnelOutline, size: 16),
                    const SizedBox(width: 4),
                  ],
                  if (sandboxSourceUri != null) ...[
                    Icon(
                      MdiIcons.archiveLockOutline,
                      color: theme.colorScheme.tertiary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                  ] else
                    _SecurityStatusIcon(
                      tabState: tabState,
                      size: 16,
                      containerColor: containerPalette?.accentColor,
                    ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: UriBreadcrumb(
                      uri: sandboxSourceUri ?? tabState.url,
                      showHttpScheme: false,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      onTooltipTriggered: longPressUrlCopy
                          ? () async {
                              await Clipboard.setData(
                                ClipboardData(
                                  text: (sandboxSourceUri ?? tabState.url)
                                      .toString(),
                                ),
                              );
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8.0),
      ],
    );
  }
}

class AppBarTitle extends ConsumerWidget {
  const AppBarTitle({
    super.key,
    this.containerColor,
    this.useCustomColor = false,
  });

  final Color? containerColor;
  final bool useCustomColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabState = ref.watch(selectedTabStateProvider);
    final selectedTabType = ref.watch(selectedTabTypeProvider);
    final settings = ref.watch(generalSettingsWithDefaultsProvider);
    final isTabTuneledAsync = ref.watch(isTabTunneledProvider(tabState?.id));
    final siteSettingsBadgeState = ref.watch(
      showSiteSettingsBadgeProvider.select(
        (value) => value.value ?? SiteSettingsBadgeState.hidden,
      ),
    );

    if (tabState == null) {
      return _EmptyAppBarAddressField(
        onTap: () async {
          await SearchRoute(
            tabType: selectedTabType ?? settings.effectiveDefaultCreateTabType,
          ).push(context);
        },
      );
    }

    final sandboxSourceUri = ref.watch(
      sandboxSourceUriForTabProvider(tabId: tabState.id),
    );

    return AppBarTitleView(
      tabState: tabState,
      isTabTunneled:
          isTabTuneledAsync.hasValue && isTabTuneledAsync.value == true,
      siteSettingsBadgeState: siteSettingsBadgeState,
      longPressUrlCopy: settings.tabBarLongPressUrlCopy,
      containerColor: containerColor,
      useCustomColor: useCustomColor,
      sandboxSourceUri: sandboxSourceUri,
      onSiteSettingsTap: () {
        ref
            .read(bottomSheetControllerProvider.notifier)
            .show(SiteSettingsSheet(tabState: tabState));
      },
      onTitleTap: () async {
        await SearchRoute(
          tabId: tabState.id,
          searchText: searchTextForTab(tabState, sandboxSourceUri),
          tabType: tabState.tabMode.toTabType(),
        ).push(context);
      },
    );
  }
}

class AppBarTitleView extends StatelessWidget {
  const AppBarTitleView({
    super.key,
    required this.tabState,
    required this.isTabTunneled,
    required this.siteSettingsBadgeState,
    required this.onSiteSettingsTap,
    required this.onTitleTap,
    required this.longPressUrlCopy,
    this.tabIcon,
    this.containerColor,
    this.useCustomColor = false,
    this.sandboxSourceUri,
  });

  final TabState tabState;
  final bool isTabTunneled;
  final SiteSettingsBadgeState siteSettingsBadgeState;
  final VoidCallback onSiteSettingsTap;
  final VoidCallback onTitleTap;
  final Widget? tabIcon;
  final bool longPressUrlCopy;
  final Color? containerColor;
  final bool useCustomColor;
  final Uri? sandboxSourceUri;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = AppColors.of(context);
    final containerColor = this.containerColor;
    final containerPalette = containerColor != null
        ? ContainerColors.palette(
            context,
            containerColor,
            useCustomColor: useCustomColor,
          )
        : null;

    return Row(
      children: [
        ToolbarButton(
          onTap: onSiteSettingsTap,
          child: Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                tabIcon ?? TabIcon(tabState: tabState, iconSize: 24),
                if (siteSettingsBadgeState != SiteSettingsBadgeState.hidden)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Icon(
                      siteSettingsBadgeState == SiteSettingsBadgeState.improved
                          ? MdiIcons.shield
                          : MdiIcons.shieldAlert,
                      size: 10,
                      color:
                          siteSettingsBadgeState ==
                              SiteSettingsBadgeState.improved
                          ? Colors.green
                          : appColors.warningAmber,
                    ),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: onTitleTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Skeletonizer(
                  enabled: tabState.title.isEmpty,
                  child: Skeleton.replace(
                    replacement: const Padding(
                      padding: EdgeInsets.only(right: 4, top: 1, bottom: 1),
                      child: Bone.text(),
                    ),
                    child: TextScroll(
                      key: ValueKey(tabState.title),
                      tabState.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      velocity: const Velocity(pixelsPerSecond: Offset(75, 0)),
                      delayBefore: const Duration(milliseconds: 500),
                      pauseBetween: const Duration(milliseconds: 5000),
                      fadedBorder: true,
                      fadeBorderSide: FadeBorderSide.right,
                      fadedBorderWidth: 0.05,
                      intervalSpaces: 4,
                      numberOfReps: 2,
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: containerColor != null
                      ? const EdgeInsets.symmetric(vertical: 2, horizontal: 8)
                      : EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: containerColor != null
                        ? containerPalette!.surfaceColor
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    border: containerPalette != null
                        ? Border.all(color: containerPalette.outlineColor)
                        : null,
                  ),
                  child: Row(
                    children: [
                      if (tabState.tabMode is PrivateTabMode) ...[
                        Icon(
                          MdiIcons.dominoMask,
                          color: appColors.privateTabPurple,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                      ] else if (tabState.tabMode is IsolatedTabMode) ...[
                        Icon(
                          MdiIcons.snowflake,
                          color: appColors.isolatedTabTeal,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                      ],
                      if (isTabTunneled) ...[
                        const Icon(MdiIcons.tunnelOutline, size: 14),
                        const SizedBox(width: 4),
                      ],
                      if (sandboxSourceUri != null) ...[
                        Icon(
                          MdiIcons.archiveLockOutline,
                          color: theme.colorScheme.tertiary,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                      ] else
                        _SecurityStatusIcon(
                          tabState: tabState,
                          size: 14,
                          containerColor: containerPalette?.accentColor,
                        ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: UriBreadcrumb(
                          uri: sandboxSourceUri ?? tabState.url,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                          onTooltipTriggered: longPressUrlCopy
                              ? () async {
                                  await Clipboard.setData(
                                    ClipboardData(
                                      text: (sandboxSourceUri ?? tabState.url)
                                          .toString(),
                                    ),
                                  );
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8.0),
      ],
    );
  }
}

/// Side-rail variant of the address field: an upright site-settings favicon
/// button stacked above the URL, which is rendered as rotated ("vertical")
/// text like a bookshelf spine. Reuses all the same content/behaviour as
/// [AppBarTitle] — only the layout is rotated.
class RailAppBarTitle extends ConsumerWidget {
  const RailAppBarTitle({
    super.key,
    required this.quarterTurns,
    this.containerColor,
    this.useCustomColor = false,
  });

  /// Rotation applied to the URL text. 3 (bottom-to-top) reads best on a left
  /// rail; 1 (top-to-bottom) on a right rail.
  final int quarterTurns;
  final Color? containerColor;
  final bool useCustomColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabState = ref.watch(selectedTabStateProvider);
    final selectedTabType = ref.watch(selectedTabTypeProvider);
    final settings = ref.watch(generalSettingsWithDefaultsProvider);
    final isTabTuneledAsync = ref.watch(isTabTunneledProvider(tabState?.id));
    final siteSettingsBadgeState = ref.watch(
      showSiteSettingsBadgeProvider.select(
        (value) => value.value ?? SiteSettingsBadgeState.hidden,
      ),
    );

    if (tabState == null) {
      return _EmptyRailAddressField(
        quarterTurns: quarterTurns,
        onTap: () async {
          await SearchRoute(
            tabType: selectedTabType ?? settings.effectiveDefaultCreateTabType,
          ).push(context);
        },
      );
    }

    final sandboxSourceUri = ref.watch(
      sandboxSourceUriForTabProvider(tabId: tabState.id),
    );

    return RailAppBarTitleView(
      tabState: tabState,
      quarterTurns: quarterTurns,
      isTabTunneled:
          isTabTuneledAsync.hasValue && isTabTuneledAsync.value == true,
      siteSettingsBadgeState: siteSettingsBadgeState,
      longPressUrlCopy: settings.tabBarLongPressUrlCopy,
      containerColor: containerColor,
      useCustomColor: useCustomColor,
      sandboxSourceUri: sandboxSourceUri,
      onSiteSettingsTap: () {
        ref
            .read(bottomSheetControllerProvider.notifier)
            .show(SiteSettingsSheet(tabState: tabState));
      },
      onTitleTap: () async {
        await SearchRoute(
          tabId: tabState.id,
          searchText: searchTextForTab(tabState, sandboxSourceUri),
          tabType: tabState.tabMode.toTabType(),
        ).push(context);
      },
    );
  }
}

class RailAppBarTitleView extends StatelessWidget {
  const RailAppBarTitleView({
    super.key,
    required this.tabState,
    required this.quarterTurns,
    required this.isTabTunneled,
    required this.siteSettingsBadgeState,
    required this.onSiteSettingsTap,
    required this.onTitleTap,
    this.tabIcon,
    this.longPressUrlCopy = true,
    this.containerColor,
    this.useCustomColor = false,
    this.sandboxSourceUri,
  });

  final TabState tabState;
  final int quarterTurns;
  final bool isTabTunneled;
  final SiteSettingsBadgeState siteSettingsBadgeState;
  final VoidCallback onSiteSettingsTap;
  final VoidCallback onTitleTap;
  final Widget? tabIcon;
  final bool longPressUrlCopy;
  final Color? containerColor;
  final bool useCustomColor;
  final Uri? sandboxSourceUri;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = AppColors.of(context);
    final containerColor = this.containerColor;
    final containerPalette = containerColor != null
        ? ContainerColors.palette(
            context,
            containerColor,
            useCustomColor: useCustomColor,
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ToolbarButton(
          onTap: onSiteSettingsTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              tabIcon ?? TabIcon(tabState: tabState, iconSize: 24),
              if (siteSettingsBadgeState != SiteSettingsBadgeState.hidden)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Icon(
                    siteSettingsBadgeState == SiteSettingsBadgeState.improved
                        ? MdiIcons.shield
                        : MdiIcons.shieldAlert,
                    size: 10,
                    color:
                        siteSettingsBadgeState == SiteSettingsBadgeState.improved
                        ? Colors.green
                        : appColors.warningAmber,
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: onTitleTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              decoration: BoxDecoration(
                color: containerColor != null
                    ? containerPalette!.surfaceColor
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
                border: containerPalette != null
                    ? Border.all(color: containerPalette.outlineColor)
                    : null,
              ),
              child: RotatedBox(
                quarterTurns: quarterTurns,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (tabState.tabMode is PrivateTabMode) ...[
                      Icon(
                        MdiIcons.dominoMask,
                        color: appColors.privateTabPurple,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                    ] else if (tabState.tabMode is IsolatedTabMode) ...[
                      Icon(
                        MdiIcons.snowflake,
                        color: appColors.isolatedTabTeal,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                    ],
                    if (isTabTunneled) ...[
                      const Icon(MdiIcons.tunnelOutline, size: 16),
                      const SizedBox(width: 4),
                    ],
                    if (sandboxSourceUri != null) ...[
                      Icon(
                        MdiIcons.archiveLockOutline,
                        color: theme.colorScheme.tertiary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                    ] else
                      _SecurityStatusIcon(
                        tabState: tabState,
                        size: 16,
                        containerColor: containerPalette?.accentColor,
                      ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: UriBreadcrumb(
                        uri: sandboxSourceUri ?? tabState.url,
                        showHttpScheme: false,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                        onTooltipTriggered: longPressUrlCopy
                            ? () async {
                                await Clipboard.setData(
                                  ClipboardData(
                                    text: (sandboxSourceUri ?? tabState.url)
                                        .toString(),
                                  ),
                                );
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyRailAddressField extends StatelessWidget {
  const _EmptyRailAddressField({
    required this.onTap,
    required this.quarterTurns,
  });

  final VoidCallback onTap;
  final int quarterTurns;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.center,
        child: RotatedBox(
          quarterTurns: quarterTurns,
          child: Text(
            'Search or enter URL',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _SecurityStatusIcon extends StatelessWidget {
  const _SecurityStatusIcon({
    required this.tabState,
    required this.size,
    this.containerColor,
  });

  final TabState tabState;
  final double size;
  final Color? containerColor;

  @override
  Widget build(BuildContext context) {
    if (tabState.url.isHttp) {
      return Icon(
        MdiIcons.lockOff,
        color: Theme.of(context).colorScheme.error,
        size: size,
      );
    } else if (tabState.readerableState.active) {
      return Icon(MdiIcons.lockMinus, color: containerColor, size: size);
    } else if (!tabState.securityInfoState.secure) {
      return Icon(
        MdiIcons.lockAlert,
        color: Theme.of(context).colorScheme.errorContainer,
        size: size,
      );
    } else if (!tabState.isLoading) {
      return Icon(MdiIcons.lock, color: containerColor, size: size);
    }

    return Icon(MdiIcons.timerSand, color: containerColor, size: size);
  }
}

class _EmptyAppBarAddressField extends StatelessWidget {
  const _EmptyAppBarAddressField({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.center,
          child: Text(
            'Search or enter URL',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
