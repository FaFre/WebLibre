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
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/account/presentation/widgets/supporter_home_banner.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_container_selection.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/providers/browser_viewport_toolbar_insets.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/home/home_search_pill.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_modules_view.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/module_surface_scope.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/module_surface_slivers.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/container_colors.dart';
import 'package:weblibre/features/proxy/presentation/controllers/ensure_proxy_started.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/wallpaper/presentation/widgets/wallpaper_backdrop.dart';
import 'package:weblibre/presentation/widgets/browser_page.dart';

/// The home surface creates tabs of the user's configured default type; the
/// child type is meaningless here because there is no tab to be a child of.
TabMode _tabModeFor(TabType tabType) => switch (tabType) {
  TabType.regular || TabType.child => TabMode.regular,
  TabType.private => TabMode.private,
  TabType.isolated => TabMode.newIsolated(),
};

/// The browser home: what fills the viewport when no tab is selected, or when
/// the selected tab belongs to a different container than the selected one.
///
/// Renders the same configurable module list as the new-tab page, under
/// [ModuleSurface.home] so the two keep separate layouts. Everything below the
/// header is user-arrangeable; only the brand/container header, the search pill
/// and the supporter banner are fixed chrome.
///
/// Each piece owns its own provider subscriptions rather than watching
/// everything at the root, so a settings write or a toolbar-inset animation
/// does not rebuild the module list underneath.
class BrowserHome extends ConsumerWidget {
  const BrowserHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> openNewTab() {
      final tabType = ref
          .read(generalSettingsWithDefaultsProvider)
          .effectiveDefaultCreateTabType;
      return SearchRoute(tabType: tabType).push(context);
    }

    Future<void> viewTabs() => const TabViewRoute().push(context);

    Future<void> resumeLastTab() async {
      final containerId = ref.read(selectedContainerProvider);
      final repository = ref.read(tabRepositoryProvider.notifier);

      // Resume within the container in scope; falling back to the global
      // "latest tab" would silently jump the user into another container.
      if (containerId != null) {
        await repository.resumeLatestContainerTab(containerId);
      } else {
        await repository.resumeLatestTab();
      }
    }

    final callbacks = ModuleSurfaceCallbacks(
      onUriSelected: (uri) async {
        final container = ref.read(selectedContainerDataProvider).value;

        await ref
            .read(tabRepositoryProvider.notifier)
            .addTab(
              url: uri,
              tabMode: _tabModeFor(
                ref
                    .read(generalSettingsWithDefaultsProvider)
                    .effectiveDefaultCreateTabType,
              ),
              selectTab: true,
              containerSelection: container == null
                  ? const TabContainerSelection.unassigned()
                  : TabContainerSelection.specific(container),
            );
      },
      onTabSelected: (tabId) async {
        await ref.read(tabRepositoryProvider.notifier).selectTab(tabId);
      },
      onArticleSelected: (article) {
        unawaited(FeedArticleRoute(articleId: article.id).push(context));
      },
      onContainerSelected: (container) async {
        final result = await ref
            .read(selectedContainerProvider.notifier)
            .setContainerId(container.id);

        if (!context.mounted) return;

        if (result == SetContainerResult.success) {
          await ensureProxyStartedForContainer(context, ref, container);
        }
      },
      onNewTab: openNewTab,
      onViewTabs: viewTabs,
      onResumeLastTab: resumeLastTab,
    );

    return BrowserPage(
      // The wallpaper sits over the aura backdrop and under everything else.
      // The aura keeps painting beneath it rather than being switched off:
      // an image that has gone missing (a profile restored from an older
      // archive, storage cleared underneath us) then degrades to the plain
      // home surface instead of a blank one, and the aura is a raster-cached
      // static picture, so the cost of it being covered is a single fill.
      child: HomeWallpaperBackdrop(
        // The viewport, not just its first sliver, has to clear the status bar:
        // BrowserSystemBars fills that inset with an opaque strip painted over
        // this surface, and the pinned pill below would scroll underneath it
        // and disappear. Bottom stays excluded — [_HomeBottomInsetSpacer] owns
        // it, because that inset animates with the toolbar.
        child: SafeArea(
          bottom: false,
          child: RepaintBoundary(
            child: ModuleSurfaceScope(
              surface: ModuleSurface.home,
              // Unpinned: the sections here are short, and the pinned search pill
              // above already holds the top of the viewport. Backing each header
              // so it could pin would lay opaque bands across the aura gradient.
              pinnedHeaderBackgroundColor: null,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  const SliverToBoxAdapter(child: _HomeHeader()),
                  // Pinned, because under [HomeSearchBarPlacement.top] the
                  // browser toolbar's address field is suppressed while home is
                  // showing: this is then the only way into search, so it has to
                  // survive scrolling. Pinning it above the section headers also
                  // gives them something to slide under.
                  const _HomeSearchPillSliver(),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: SupporterHomeBanner(),
                    ),
                  ),
                  ModuleSurfaceSliverList(
                    surface: ModuleSurface.home,
                    callbacks: callbacks,
                  ),
                  const _HomeBottomInsetSpacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The pinned search pill, present only when the search entry is placed here
/// rather than in the tab bar.
///
/// Its own widget so the placement watch does not rebuild [BrowserHome] — and
/// so the sliver disappears entirely rather than collapsing to a zero-height
/// pinned header, which would still hold a scroll offset the section headers
/// slide under.
class _HomeSearchPillSliver extends ConsumerWidget {
  const _HomeSearchPillSliver();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placement = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (settings) => settings.effectiveHomeSearchBarPlacement(),
      ),
    );

    if (placement == HomeSearchBarPlacement.tabBar) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return const SliverPinnedHeader(child: HomeSearchPill());
  }
}

/// Brand mark, or the selected container's identity when there is one.
class _HomeHeader extends ConsumerWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final container = ref.watch(
      selectedContainerDataProvider.select((value) => value.value),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        children: [
          if (container != null)
            _ContainerHeader(container: container)
          else
            BrandHeader(colorScheme: theme.colorScheme),
          if (container != null) ...[
            const SizedBox(height: 12),
            Text(
              container.name?.isNotEmpty == true
                  ? container.name!
                  : 'Container',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Trailing space so the last module clears the bottom app bar.
///
/// A spacer rather than a [SliverPadding] around the list: the inset animates
/// with the toolbar, and padding would relayout every module on each frame.
/// Owning the watch here also keeps those frames off the module list entirely.
class _HomeBottomInsetSpacer extends ConsumerWidget {
  const _HomeBottomInsetSpacer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insetPx = ref.watch(
      browserViewportToolbarInsetsControllerProvider.select(
        (state) => state.effectiveBottomInsetPx,
      ),
    );
    final inset = insetPx / MediaQuery.devicePixelRatioOf(context);

    return SliverToBoxAdapter(child: SizedBox(height: 24 + inset));
  }
}

class _ContainerHeader extends StatelessWidget {
  final ContainerData container;

  const _ContainerHeader({required this.container});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final containerPalette = ContainerColors.palette(
      context,
      container.color,
      useCustomColor: container.metadata.useCustomColor,
    );

    return Container(
      width: 96,
      height: 96,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            containerPalette.surfaceHighColor,
            containerPalette.surfaceColor,
          ],
        ),
        border: Border.all(color: containerPalette.outlineColor),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      // See [BrandHeader]: the mark needs room inside the tile, and 60 in a
      // 96 tile with 18 of padding leaves it none.
      child: Center(
        child: SvgPicture.asset('assets/icon/icon.svg', width: 48, height: 48),
      ),
    );
  }
}
