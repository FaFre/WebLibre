/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/sections.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/icons/weblibre_icons.dart';

class TabsBehaviorSettingsScreen extends StatelessWidget {
  const TabsBehaviorSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tabs & Behavior')),
      body: SafeArea(
        child: FadingScroll(
          fadingSize: 25,
          builder: (context, controller) {
            return ListView(
              controller: controller,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              children: const [
                _TabCreationSection(),
                _TabOrganizationSection(),
                _TabInteractionSection(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TabCreationSection extends StatelessWidget {
  const _TabCreationSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SettingSection(name: 'Tab Creation'),
        _NewTabDefaultSection(),
        _ExternalLinkHandlingSection(),
        _AppLinksModeSection(),
      ],
    );
  }
}

class _TabOrganizationSection extends StatelessWidget {
  const _TabOrganizationSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SettingSection(name: 'Tab Organization'),
        _CreateChildTabsTile(),
      ],
    );
  }
}

class _TabInteractionSection extends StatelessWidget {
  const _TabInteractionSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SettingSection(name: 'Tab Interaction'),
        _TabBarSwipeBehaviorSection(),
        _ShowExtensionShortcutTile(),
      ],
    );
  }
}

class _NewTabDefaultSection extends HookConsumerWidget {
  const _NewTabDefaultSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = AppColors.of(context);
    final defaultCreateTabType = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.defaultCreateTabType),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            title: Text('New Tab Default'),
            subtitle: Text('Choose the default type for manually created tabs'),
            leading: Icon(MdiIcons.tab),
            contentPadding: EdgeInsets.zero,
          ),
          Center(
            child: SegmentedButton(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: TabType.regular,
                  label: Text('Regular'),
                  icon: Icon(MdiIcons.tab),
                ),
                ButtonSegment(
                  value: TabType.private,
                  label: Text('Private'),
                  icon: Icon(WebLibreIcons.privateTab),
                ),
              ],
              selected: {defaultCreateTabType},
              onSelectionChanged: (value) async {
                await ref
                    .read(saveGeneralSettingsControllerProvider.notifier)
                    .save(
                      (currentSettings) => currentSettings.copyWith
                          .defaultCreateTabType(value.first),
                    );
              },
              style: switch (defaultCreateTabType) {
                TabType.regular => null,
                TabType.private => SegmentedButton.styleFrom(
                  selectedBackgroundColor: appColors.privateSelectionOverlay,
                ),
                TabType.child => null,
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ExternalLinkHandlingSection extends HookConsumerWidget {
  const _ExternalLinkHandlingSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = AppColors.of(context);
    final tabIntentOpenSetting = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.tabIntentOpenSetting),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            title: Text('External Link Handling'),
            subtitle: Text('Choose how external links open in WebLibre'),
            leading: Icon(MdiIcons.tabPlus),
            contentPadding: EdgeInsets.zero,
          ),
          Center(
            child: SegmentedButton(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: TabIntentOpenSetting.ask,
                  label: Text('Prompt'),
                  icon: Icon(MdiIcons.messageQuestion),
                ),
                ButtonSegment(
                  value: TabIntentOpenSetting.regular,
                  label: Text('Regular'),
                  icon: Icon(MdiIcons.tab),
                ),
                ButtonSegment(
                  value: TabIntentOpenSetting.private,
                  label: Text('Private'),
                  icon: Icon(WebLibreIcons.privateTab),
                ),
              ],
              selected: {tabIntentOpenSetting},
              onSelectionChanged: (value) async {
                await ref
                    .read(saveGeneralSettingsControllerProvider.notifier)
                    .save(
                      (currentSettings) => currentSettings.copyWith
                          .tabIntentOpenSetting(value.first),
                    );
              },
              style: switch (tabIntentOpenSetting) {
                TabIntentOpenSetting.regular => null,
                TabIntentOpenSetting.private => SegmentedButton.styleFrom(
                  selectedBackgroundColor: appColors.privateSelectionOverlay,
                ),
                TabIntentOpenSetting.ask => null,
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateChildTabsTile extends HookConsumerWidget {
  const _CreateChildTabsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final createChildTabsOption = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.createChildTabsOption,
      ),
    );

    return SwitchListTile.adaptive(
      title: const Text('Create Child Tabs'),
      subtitle: const Text(
        'Display a button to create a child tab under the current tab (tree view only)',
      ),
      secondary: const Icon(MdiIcons.fileTree),
      value: createChildTabsOption,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.createChildTabsOption(value),
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

class _TabBarSwipeBehaviorSection extends HookConsumerWidget {
  const _TabBarSwipeBehaviorSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabBarSwipeAction = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.tabBarSwipeAction),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            title: Text('Tab Bar Swipe Behavior'),
            leading: Icon(MdiIcons.gestureSwipeHorizontal),
            contentPadding: EdgeInsets.zero,
          ),
          RadioGroup(
            groupValue: tabBarSwipeAction,
            onChanged: (value) async {
              if (value != null) {
                await ref
                    .read(saveGeneralSettingsControllerProvider.notifier)
                    .save(
                      (currentSettings) =>
                          currentSettings.copyWith.tabBarSwipeAction(value),
                    );
              }
            },
            child: const Column(
              children: [
                RadioListTile.adaptive(
                  value: TabBarSwipeAction.switchLastOpened,
                  title: Text('Switch to Last Used Tab'),
                  subtitle: Text(
                    'Swipe to toggle between current and previously opened tab',
                  ),
                ),
                RadioListTile.adaptive(
                  value: TabBarSwipeAction.navigateOrderedTabs,
                  title: Text('Navigate Sequential Tabs'),
                  subtitle: Text(
                    'Swipe left/right to move through tabs in order',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppLinksModeSection extends HookConsumerWidget {
  const _AppLinksModeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLinksMode = ref.watch(
      appLinksModeProvider.select((value) => value.value),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            title: Text('Open Links in Apps'),
            subtitle: Text(
              'Choose how links that can be opened in other apps are handled',
            ),
            leading: Icon(MdiIcons.openInApp),
            contentPadding: EdgeInsets.zero,
          ),
          RadioGroup(
            groupValue: appLinksMode,
            onChanged: (value) async {
              if (value != null) {
                await ref.read(appLinksModeProvider.notifier).setMode(value);
              }
            },
            child: const Column(
              children: [
                RadioListTile.adaptive(
                  value: AppLinksMode.always,
                  title: Text('Always'),
                  subtitle: Text(
                    'Always open links in their native apps without asking',
                  ),
                ),
                RadioListTile.adaptive(
                  value: AppLinksMode.ask,
                  title: Text('Ask before opening'),
                  subtitle: Text('Show a prompt before opening links in apps'),
                ),
                RadioListTile.adaptive(
                  value: AppLinksMode.never,
                  title: Text('Never'),
                  subtitle: Text(
                    'Always open links in the browser instead of apps',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
