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
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/security.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/widgets/contextual_bar_buttons.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/widgets/contextual_toolbar.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/app_bar_title.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/bottom_app_bar.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/navigation_buttons.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tabs_action_button.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';

class TabBarPreviewHeaderDelegate extends SliverPersistentHeaderDelegate {
  const TabBarPreviewHeaderDelegate({
    required this.settings,
    this.backgroundColor,
    this.compact = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 12.0),
  });

  static const _kPreviewBaseHeight = 90.0;
  static const _kCompactPreviewBaseHeight = 42.0;
  static const _kHeaderHeight = 72.0;

  final GeneralSettings settings;
  final Color? backgroundColor;
  final bool compact;
  final EdgeInsets padding;

  double get _toolbarHeight {
    var height = kToolbarHeight;

    if (settings.tabBarShowContextualBar) {
      height += BrowserTabBar.contextualToolabarHeight;
    }

    if (settings.tabBarShowQuickTabSwitcherBar) {
      height += BrowserTabBar.quickTabSwitcherHeight;
    }

    return height;
  }

  double get _baseHeight =>
      compact ? _kCompactPreviewBaseHeight : _kPreviewBaseHeight;

  double get _headerHeight => compact ? 0.0 : _kHeaderHeight;

  @override
  double get minExtent =>
      _baseHeight + _toolbarHeight + _headerHeight + padding.vertical;

  @override
  double get maxExtent =>
      _baseHeight + _toolbarHeight + _headerHeight + padding.vertical;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: padding,
        child: TabBarPreviewCard(settings: settings, compact: compact),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant TabBarPreviewHeaderDelegate oldDelegate) {
    return oldDelegate.settings != settings ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.compact != compact;
  }
}

class TabBarPreviewCard extends HookWidget {
  const TabBarPreviewCard({
    super.key,
    required this.settings,
    this.compact = false,
  });

  final GeneralSettings settings;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final quickTabsController = useScrollController();
    final showMainToolbarActionButtons = !settings.tabBarShowContextualBar;

    final previewTabState = TabState.$default('preview-tab').copyWith(
      url: Uri.parse('https://weblibre.eu/docs'),
      title: 'WebLibre Preview',
      securityInfoState: SecurityState(
        secure: true,
        host: 'weblibre.eu',
        issuer: 'WebLibre',
      ),
    );

    final previewQuickItems = <QuickTabSwitcherItem>[
      QuickTabSwitcherItem(
        id: 'regular-preview-tab',
        isActive: true,
        title: 'News',
        tabMode: TabMode.regular,
        isHistory: false,
        isPinned:
            settings.effectiveUiQuickTabSwitcherMode() ==
            QuickTabSwitcherMode.containerTabs,
        url: Uri.parse('https://example.com/news'),
        color: settings.showContainerUi
            ? colorScheme.primary.withValues(alpha: 0.18)
            : null,
        avatar: const Icon(MdiIcons.web, size: 20),
      ),
      QuickTabSwitcherItem(
        id: 'private-preview-tab',
        isActive: false,
        title: 'Private',
        tabMode: TabMode.private,
        isHistory: false,
        isPinned: false,
        url: Uri.parse('https://example.com/private'),
        color: null,
        avatar: const Icon(MdiIcons.web, size: 20),
      ),
      if (settings.showIsolatedTabUi)
        QuickTabSwitcherItem(
          id: 'isolated-preview-tab',
          isActive: false,
          title: 'Bank',
          tabMode: TabMode.isolated('preview-isolated-context'),
          isHistory: false,
          isPinned: false,
          url: Uri.parse('https://example.com/bank'),
          color: null,
          avatar: const Icon(MdiIcons.web, size: 20),
        ),
      if (settings.quickTabSwitcherShowHistorySuggestions)
        QuickTabSwitcherItem(
          id: 'history-preview-tab',
          isActive: false,
          title: 'Search',
          tabMode: TabMode.regular,
          isHistory: true,
          isPinned: false,
          url: Uri.parse('https://search.example.com'),
          color: null,
          avatar: const Icon(MdiIcons.web, size: 20),
        ),
    ];

    final tabCountButton = TabsCountButtonView(
      isActive: false,
      onTap: () {},
      onLongPress: () {},
      buttonBuilder: (isActive, onTap, onLongPress) {
        return TabsActionButtonView(
          isActive: isActive,
          tabCountText: '5',
          onTap: onTap,
          onLongPress: onLongPress,
        );
      },
    );

    Widget buildQuickTabSwitcher() {
      return QuickTabSwitcherView(
        availableItems: previewQuickItems,
        activeItem: previewQuickItems.firstWhere((item) => item.isActive),
        scrollController: quickTabsController,
        showTitles: settings.quickTabSwitcherShowTitles,
        showIsolatedTabUi: settings.showIsolatedTabUi,
        onSelected: (_) async {},
        itemWrapBuilder: (child, _) => child,
      );
    }

    Widget buildContextualToolbar() {
      return ContextualToolbarView(
        buttons: [
          NavigateBackButtonView(
            canGoBack: true,
            isLoading: false,
            onPressed: () {},
            onLongPress: () {},
          ),
          NavigateForwardButtonView(
            canGoForward: true,
            onPressed: () {},
            onLongPress: () {},
          ),
          AddTabButtonView(onPressed: () {}, onLongPress: () {}),
          tabCountButton,
          NavigationMenuButtonView(onTap: () {}),
        ],
      );
    }

    final mainToolbarActions = <Widget>[
      if (showMainToolbarActionButtons) tabCountButton,
      if (showMainToolbarActionButtons) NavigationMenuButtonView(onTap: () {}),
    ];

    final bottomCombinedToolbar = BrowserTabBarView(
      showMainToolbar: true,
      showContextualToolbar: settings.tabBarShowContextualBar,
      showQuickTabSwitcherBar: settings.tabBarShowQuickTabSwitcherBar,
      displayAppBar: true,
      displayQuickTabSwitcher: true,
      backgroundColor: settings.showContainerUi
          ? colorScheme.primaryContainer.withValues(alpha: 0.55)
          : colorScheme.surfaceContainer,
      title: settings.tabBarLayout == TabBarLayout.compact
          ? _CompactPreviewTitle(tabState: previewTabState)
          : _RegularPreviewTitle(tabState: previewTabState),
      actions: mainToolbarActions,
      quickTabSwitcher: buildQuickTabSwitcher(),
      contextualToolbar: buildContextualToolbar(),
    );

    final topMainToolbar = BrowserTabBarView(
      showMainToolbar: true,
      showContextualToolbar: false,
      showQuickTabSwitcherBar: false,
      displayAppBar: true,
      displayQuickTabSwitcher: false,
      backgroundColor: settings.showContainerUi
          ? colorScheme.primaryContainer.withValues(alpha: 0.55)
          : colorScheme.surfaceContainer,
      title: settings.tabBarLayout == TabBarLayout.compact
          ? _CompactPreviewTitle(tabState: previewTabState)
          : _RegularPreviewTitle(tabState: previewTabState),
      actions: mainToolbarActions,
      quickTabSwitcher: const SizedBox.shrink(),
      contextualToolbar: const SizedBox.shrink(),
    );

    final topBottomToolbar = BrowserTabBarView(
      showMainToolbar: false,
      showContextualToolbar: settings.tabBarShowContextualBar,
      showQuickTabSwitcherBar: settings.tabBarShowQuickTabSwitcherBar,
      displayAppBar: false,
      displayQuickTabSwitcher: true,
      backgroundColor: colorScheme.surfaceContainer,
      title: null,
      actions: const [],
      quickTabSwitcher: buildQuickTabSwitcher(),
      contextualToolbar: buildContextualToolbar(),
    );

    final previewContent = Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: compact
            ? colorScheme.surface.withValues(alpha: 0.7)
            : colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          if (settings.tabBarPosition == TabBarPosition.top) topMainToolbar,
          Container(
            height: compact ? 40 : 72,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: compact
                  ? colorScheme.surfaceContainerLowest.withValues(alpha: 0.7)
                  : colorScheme.surfaceContainerLowest,
              border: Border.symmetric(
                horizontal: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: Text(
              'Page Content',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          if (settings.tabBarPosition == TabBarPosition.top)
            topBottomToolbar
          else
            bottomCombinedToolbar,
        ],
      ),
    );

    if (compact) {
      return previewContent;
    }

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ListTile(
              title: Text('Live Preview'),
              subtitle: Text(
                'Reflects your current toolbar and layout settings',
              ),
              leading: Icon(MdiIcons.televisionGuide),
              contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
            ),
            previewContent,
          ],
        ),
      ),
    );
  }
}

class _RegularPreviewTitle extends StatelessWidget {
  const _RegularPreviewTitle({required this.tabState});

  final TabState tabState;

  @override
  Widget build(BuildContext context) {
    return AppBarTitleView(
      tabState: tabState,
      isTabTunneled: false,
      showSiteSettingsBadge: false,
      onSiteSettingsTap: _noop,
      onTitleTap: _noop,
      tabIcon: const Icon(MdiIcons.web, size: 24),
    );
  }
}

class _CompactPreviewTitle extends StatelessWidget {
  const _CompactPreviewTitle({required this.tabState});

  final TabState tabState;

  @override
  Widget build(BuildContext context) {
    return CompactAppBarTitleView(
      tabState: tabState,
      isTabTunneled: false,
      showSiteSettingsBadge: false,
      onSiteSettingsTap: _noop,
      onTitleTap: _noop,
      tabIcon: const Icon(MdiIcons.web, size: 24),
    );
  }
}

void _noop() {}
