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
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/sections.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

class AppearanceDisplaySettingsScreen extends StatelessWidget {
  const AppearanceDisplaySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appearance & Display')),
      body: SafeArea(
        child: FadingScroll(
          fadingSize: 25,
          builder: (context, controller) {
            return ListView(
              controller: controller,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              children: const [
                _VisualSection(),
                _TabBarSection(),
                _TabViewSection(),
                _GesturesSection(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _VisualSection extends StatelessWidget {
  const _VisualSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SettingSection(name: 'Visual'),
        _ThemeSection(),
      ],
    );
  }
}

class _TabBarSection extends StatelessWidget {
  const _TabBarSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SettingSection(name: 'Tab Bar'),
        _TabBarSettingsTile(),
      ],
    );
  }
}

class _TabViewSection extends StatelessWidget {
  const _TabViewSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SettingSection(name: 'Tab View'),
        _BottomSheetTabViewTile(),
        _TabListShowFaviconsTile(),
      ],
    );
  }
}

class _TabBarSettingsTile extends StatelessWidget {
  const _TabBarSettingsTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Customize Tab Bar'),
      subtitle: const Text(
        'Layout, contextual bar, quick switcher, and preview',
      ),
      leading: const Icon(MdiIcons.tabUnselected),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await TabBarSettingsRoute().push(context);
      },
    );
  }
}

class _GesturesSection extends StatelessWidget {
  const _GesturesSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SettingSection(name: 'Gestures'),
        _PullToRefreshTile(),
        _DoubleBackCloseTabTile(),
      ],
    );
  }
}

class _ThemeSection extends HookConsumerWidget {
  const _ThemeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.themeMode),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            title: Text('Theme'),
            leading: Icon(Icons.palette),
            contentPadding: EdgeInsets.zero,
          ),
          Center(
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto),
                  label: Text('System'),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode),
                  label: Text('Light'),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode),
                  label: Text('Dark'),
                ),
              ],
              selected: {themeMode},
              onSelectionChanged: (value) async {
                await ref
                    .read(saveGeneralSettingsControllerProvider.notifier)
                    .save(
                      (currentSettings) =>
                          currentSettings.copyWith.themeMode(value.first),
                    );
              },
            ),
          ),
        ],
      ),
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

class _PullToRefreshTile extends HookConsumerWidget {
  const _PullToRefreshTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pullToRefreshEnabled = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.pullToRefreshEnabled),
    );

    return SwitchListTile.adaptive(
      title: const Text('Pull to Refresh'),
      subtitle: const Text('Swipe down on pages to reload them'),
      secondary: const Icon(MdiIcons.gestureSwipeDown),
      value: pullToRefreshEnabled,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.pullToRefreshEnabled(value),
            );
      },
    );
  }
}

class _DoubleBackCloseTabTile extends HookConsumerWidget {
  const _DoubleBackCloseTabTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doubleBackCloseTab = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.doubleBackCloseTab),
    );

    return SwitchListTile.adaptive(
      title: const Text('Double Back to Close Tab'),
      subtitle: const Text(
        'When enabled, press back twice to close the tab. When disabled, back button only navigates page history.',
      ),
      secondary: const Icon(MdiIcons.gestureDoubleTap),
      value: doubleBackCloseTab,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.doubleBackCloseTab(value),
            );
      },
    );
  }
}
