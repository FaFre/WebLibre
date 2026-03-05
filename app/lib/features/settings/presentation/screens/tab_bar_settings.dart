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
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/security.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/app_bar_title.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/bottom_app_bar.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/navigation_buttons.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tabs_action_button.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

class TabBarSettingsScreen extends HookConsumerWidget {
  const TabBarSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(generalSettingsWithDefaultsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tab Bar')),
      body: SafeArea(
        child: FadingScroll(
          fadingSize: 25,
          builder: (context, controller) {
            return CustomScrollView(
              controller: controller,
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarPreviewHeaderDelegate(settings: settings),
                ),
                const SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  sliver: SliverToBoxAdapter(child: _TabBarLayoutSection()),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TabBarLayoutSection extends StatelessWidget {
  const _TabBarLayoutSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _TabBarPositionSection(),
        _TabBarLayoutModeSection(),
        _ShowExtensionShortcutTile(),
        _ShowContextualTabBarTile(),
        _AutoHideTabBarTile(),
        _ShowQuickTabSwitcherBarTile(),
        _QuickTabSwitcherModeSection(),
        _QuickTabSwitcherHistorySuggestionsTile(),
        _QuickTabSwitcherShowTitlesTile(),
      ],
    );
  }
}

class _TabBarPreviewHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _TabBarPreviewHeaderDelegate({required this.settings});

  static const _kPreviewBaseHeight = 160.0;

  final GeneralSettings settings;

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

  @override
  double get minExtent => _kPreviewBaseHeight + _toolbarHeight;

  @override
  double get maxExtent => _kPreviewBaseHeight + _toolbarHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: _TabBarPreviewCard(settings: settings),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarPreviewHeaderDelegate oldDelegate) {
    return oldDelegate.settings != settings;
  }
}

class _TabBarPreviewCard extends HookWidget {
  const _TabBarPreviewCard({required this.settings});

  final GeneralSettings settings;

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
        scrollController: quickTabsController,
        showTitles: settings.quickTabSwitcherShowTitles,
        showIsolatedTabUi: settings.showIsolatedTabUi,
        onSelected: (_) async {},
        itemWrapBuilder: (child, _) => child,
      );
    }

    Widget buildContextualToolbar() {
      return ContextualToolbarView(
        canGoBack: true,
        canGoForward: false,
        onBookmarksTap: () {},
        backButton: NavigateBackButtonView(
          canGoBack: true,
          isLoading: false,
          onPressed: () {},
          onLongPress: () {},
        ),
        forwardButton: NavigateForwardButtonView(
          canGoForward: true,
          onPressed: () {},
          onLongPress: () {},
        ),
        shareButton: ShareMenuButtonView(onPressed: () {}),
        addTabButton: AddTabButtonView(onPressed: () {}, onLongPress: () {}),
        tabsCountButton: tabCountButton,
        navigationButton: NavigationMenuButtonView(onTap: () {}),
      );
    }

    final mainToolbarActions = <Widget>[
      if (settings.showExtensionShortcut)
        IconButton(
          onPressed: () {},
          icon: const Icon(MdiIcons.puzzle),
          tooltip: 'Extensions',
        ),
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
              subtitle: Text('Reflects your current tab bar settings'),
              leading: Icon(MdiIcons.televisionGuide),
              contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
            ),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border.all(color: colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  if (settings.tabBarPosition == TabBarPosition.top)
                    topMainToolbar,
                  Container(
                    height: 72,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      border: Border.symmetric(
                        horizontal: BorderSide(
                          color: colorScheme.outlineVariant,
                        ),
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
            ),
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

class _QuickTabSwitcherShowTitlesTile extends HookConsumerWidget {
  const _QuickTabSwitcherShowTitlesTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quickTabSwitcherShowTitles = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.quickTabSwitcherShowTitles,
      ),
    );
    final tabBarShowQuickTabSwitcherBar = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.tabBarShowQuickTabSwitcherBar,
      ),
    );

    return SwitchListTile.adaptive(
      title: const Text('Show Titles in Quick Tab Switcher'),
      subtitle: const Text(
        'Display tab titles alongside icons in the quick tab switcher bar',
      ),
      secondary: const Icon(MdiIcons.textRecognition),
      value: quickTabSwitcherShowTitles,
      onChanged: tabBarShowQuickTabSwitcherBar
          ? (value) async {
              await ref
                  .read(saveGeneralSettingsControllerProvider.notifier)
                  .save(
                    (currentSettings) => currentSettings.copyWith
                        .quickTabSwitcherShowTitles(value),
                  );
            }
          : null,
    );
  }
}

class _QuickTabSwitcherHistorySuggestionsTile extends HookConsumerWidget {
  const _QuickTabSwitcherHistorySuggestionsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showHistorySuggestions = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.quickTabSwitcherShowHistorySuggestions,
      ),
    );
    final tabBarShowQuickTabSwitcherBar = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.tabBarShowQuickTabSwitcherBar,
      ),
    );

    return SwitchListTile.adaptive(
      title: const Text('History Fallback in Quick Tab Switcher'),
      subtitle: const Text(
        'Use browsing history suggestions when no tab chips are available',
      ),
      secondary: const Icon(MdiIcons.history),
      value: showHistorySuggestions,
      onChanged: tabBarShowQuickTabSwitcherBar
          ? (value) async {
              await ref
                  .read(saveGeneralSettingsControllerProvider.notifier)
                  .save(
                    (currentSettings) => currentSettings.copyWith
                        .quickTabSwitcherShowHistorySuggestions(value),
                  );
            }
          : null,
    );
  }
}

class _TabBarPositionSection extends HookConsumerWidget {
  const _TabBarPositionSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabBarPosition = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.tabBarPosition),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            title: Text('Tab Bar Position'),
            leading: Icon(MdiIcons.dockWindow),
            contentPadding: EdgeInsets.zero,
          ),
          RadioGroup(
            groupValue: tabBarPosition,
            onChanged: (value) async {
              if (value != null) {
                await ref
                    .read(saveGeneralSettingsControllerProvider.notifier)
                    .save(
                      (currentSettings) =>
                          currentSettings.copyWith.tabBarPosition(value),
                    );
              }
            },
            child: const Column(
              children: [
                RadioListTile.adaptive(
                  value: TabBarPosition.top,
                  title: Text('Top'),
                  subtitle: Text('Persistent tab bar without auto-hide'),
                ),
                RadioListTile.adaptive(
                  value: TabBarPosition.bottom,
                  title: Text('Bottom'),
                  subtitle: Text('Tab bar with auto-hide support'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBarLayoutModeSection extends HookConsumerWidget {
  const _TabBarLayoutModeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabBarLayout = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.tabBarLayout),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            title: Text('Tab Bar Style'),
            leading: Icon(MdiIcons.tabUnselected),
            contentPadding: EdgeInsets.zero,
          ),
          RadioGroup(
            groupValue: tabBarLayout,
            onChanged: (value) async {
              if (value != null) {
                await ref
                    .read(saveGeneralSettingsControllerProvider.notifier)
                    .save(
                      (currentSettings) =>
                          currentSettings.copyWith.tabBarLayout(value),
                    );
              }
            },
            child: const Column(
              children: [
                RadioListTile.adaptive(
                  value: TabBarLayout.withTitle,
                  title: Text('With Title'),
                  subtitle: Text('Shows page title and URL breadcrumb'),
                ),
                RadioListTile.adaptive(
                  value: TabBarLayout.compact,
                  title: Text('Compact'),
                  subtitle: Text('Centered URL pill without page title'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShowContextualTabBarTile extends HookConsumerWidget {
  const _ShowContextualTabBarTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabBarShowContextualBar = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.tabBarShowContextualBar,
      ),
    );

    return SwitchListTile.adaptive(
      title: const Text('Show Contextual Tab Bar'),
      subtitle: const Text(
        'Show additional bottom toolbar for navigation and actions',
      ),
      secondary: const Icon(MdiIcons.dockBottom),
      value: tabBarShowContextualBar,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.tabBarShowContextualBar(value),
            );
      },
    );
  }
}

class _ShowExtensionShortcutTile extends HookConsumerWidget {
  const _ShowExtensionShortcutTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showExtensionShortcut = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.showExtensionShortcut,
      ),
    );

    return SwitchListTile.adaptive(
      title: const Text('Show Extension Shortcut'),
      subtitle: const Text('Display an extension menu directly on the tab bar'),
      secondary: const Icon(MdiIcons.puzzleHeart),
      value: showExtensionShortcut,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.showExtensionShortcut(value),
            );
      },
    );
  }
}

class _ShowQuickTabSwitcherBarTile extends HookConsumerWidget {
  const _ShowQuickTabSwitcherBarTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabBarShowQuickTabSwitcherBar = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.tabBarShowQuickTabSwitcherBar,
      ),
    );

    return SwitchListTile.adaptive(
      title: const Text('Show Quick Tab Switcher Bar'),
      subtitle: const Text(
        'Show additional toolbar to quickly switch to recently used tabs',
      ),
      secondary: const Icon(MdiIcons.dockBottom),
      value: tabBarShowQuickTabSwitcherBar,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.tabBarShowQuickTabSwitcherBar(value),
            );
      },
    );
  }
}

class _QuickTabSwitcherModeSection extends HookConsumerWidget {
  const _QuickTabSwitcherModeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(generalSettingsWithDefaultsProvider);
    final quickTabSwitcherMode = settings.effectiveUiQuickTabSwitcherMode();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            title: Text('Quick Tab Switcher Mode'),
            leading: Icon(MdiIcons.folderSettings),
            contentPadding: EdgeInsets.zero,
          ),
          RadioGroup(
            groupValue: quickTabSwitcherMode,
            onChanged: (value) async {
              if (value != null) {
                await ref
                    .read(saveGeneralSettingsControllerProvider.notifier)
                    .save(
                      (currentSettings) =>
                          currentSettings.copyWith.quickTabSwitcherMode(value),
                    );
              }
            },
            child: Column(
              children: [
                const RadioListTile.adaptive(
                  value: QuickTabSwitcherMode.lastUsedTabs,
                  title: Text('Recently Used Tabs'),
                  subtitle: Text('Recently used tabs across all containers'),
                ),
                if (settings.showContainerUi)
                  const RadioListTile.adaptive(
                    value: QuickTabSwitcherMode.containerTabs,
                    title: Text('Container Tabs'),
                    subtitle: Text('Ordered tabs of the selected container'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AutoHideTabBarTile extends HookConsumerWidget {
  const _AutoHideTabBarTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoHideTabBar = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.autoHideTabBar),
    );

    return SwitchListTile.adaptive(
      title: const Text('Auto Hide Tab Bar'),
      subtitle: const Text('Hide tab bar when scrolling'),
      secondary: const Icon(MdiIcons.folderHidden),
      value: autoHideTabBar,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.autoHideTabBar(value),
            );
      },
    );
  }
}
