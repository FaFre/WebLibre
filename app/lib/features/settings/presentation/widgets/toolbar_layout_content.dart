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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/sections.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

class ToolbarLayoutContent extends StatelessWidget {
  const ToolbarLayoutContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SettingSection(name: 'Tab Bar'),
        _TabBarPositionSection(),
        _TabBarLayoutModeSection(),
        _AutoHideTabBarTile(),
        SettingSection(name: 'Contextual Toolbar'),
        _ShowContextualTabBarTile(),
        _CustomizeToolbarButtonsTile(),
        SettingSection(name: 'Quick Tab Switcher'),
        _ShowQuickTabSwitcherBarTile(),
        _QuickTabSwitcherModeSection(),
        _QuickTabSwitcherHistorySuggestionsTile(),
        _QuickTabSwitcherShowTitlesTile(),
        SettingSection(name: 'Tab View'),
        _BottomSheetTabViewTile(),
        _TabListShowFaviconsTile(),
      ],
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
      title: const Text('Show Contextual Toolbar'),
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

class _CustomizeToolbarButtonsTile extends HookConsumerWidget {
  const _CustomizeToolbarButtonsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabBarShowContextualBar = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.tabBarShowContextualBar,
      ),
    );

    return ListTile(
      leading: const Icon(Icons.tune),
      title: const Text('Customize Toolbar Buttons'),
      trailing: const Icon(Icons.chevron_right),
      enabled: tabBarShowContextualBar,
      onTap: () async {
        await const ContextualToolbarSettingsRoute().push(context);
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

class _BottomSheetTabViewTile extends HookConsumerWidget {
  const _BottomSheetTabViewTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabViewBottomSheet = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.tabViewBottomSheet),
    );

    return SwitchListTile.adaptive(
      title: const Text('Bottom Sheet Tab View'),
      subtitle: const Text(
        'Display tabs in a bottom sheet instead of fullscreen',
      ),
      secondary: const Icon(MdiIcons.dockBottom),
      value: tabViewBottomSheet,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.tabViewBottomSheet(value),
            );
      },
    );
  }
}

class _TabListShowFaviconsTile extends HookConsumerWidget {
  const _TabListShowFaviconsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabListShowFavicons = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.tabListShowFavicons),
    );

    return SwitchListTile.adaptive(
      title: const Text('Show Favicons in List View'),
      subtitle: const Text(
        'Display website icons instead of page thumbnails in tab list view',
      ),
      secondary: const Icon(MdiIcons.web),
      value: tabListShowFavicons,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.tabListShowFavicons(value),
            );
      },
    );
  }
}
