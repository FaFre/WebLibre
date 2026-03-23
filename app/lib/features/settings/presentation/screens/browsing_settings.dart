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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/sections.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

class BrowsingSettingsScreen extends StatelessWidget {
  const BrowsingSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Browsing')),
      body: SafeArea(
        child: FadingScroll(
          fadingSize: 25,
          builder: (context, controller) {
            return ListView(
              controller: controller,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              children: const [
                _TabsSection(),
                _NavigationSection(),
                _ExternalLinksSection(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TabsSection extends StatelessWidget {
  const _TabsSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SettingSection(name: 'Tabs'),
        _NewTabDefaultSection(),
        _SmallWebTabDefaultSection(),
        _NewTabPositionSection(),
        _ShowContainerUiTile(),
        _ShowIsolatedTabUiTile(),
        _CreateChildTabsTile(),
      ],
    );
  }
}

class _NavigationSection extends StatelessWidget {
  const _NavigationSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SettingSection(name: 'Navigation'),
        _PullToRefreshTile(),
        _DoubleBackCloseTabTile(),
        _TabBarSwipeBehaviorSection(),
        _AppLinksModeSection(),
      ],
    );
  }
}

class _ExternalLinksSection extends StatelessWidget {
  const _ExternalLinksSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SettingSection(name: 'External Links'),
        _ExternalLinkHandlingSection(),
        _UrlCleanerSettingsTile(),
        _UnshortenerSettingsTile(),
      ],
    );
  }
}

class _NewTabDefaultSection extends HookConsumerWidget {
  const _NewTabDefaultSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = AppColors.of(context);
    final settings = ref.watch(generalSettingsWithDefaultsProvider);
    final defaultCreateTabType = settings.effectiveDefaultCreateTabType;

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
              segments: [
                const ButtonSegment(
                  value: TabType.regular,
                  label: Text('Regular'),
                  icon: Icon(MdiIcons.tab),
                ),
                ButtonSegment(
                  value: TabType.private,
                  label: const Text('Private'),
                  icon: Icon(
                    MdiIcons.dominoMask,
                    color: defaultCreateTabType == TabType.private
                        ? null
                        : appColors.privateTabPurple,
                  ),
                ),
                if (settings.showIsolatedTabUi)
                  ButtonSegment(
                    value: TabType.isolated,
                    label: const Text('Isolated'),
                    icon: Icon(
                      MdiIcons.snowflake,
                      color: defaultCreateTabType == TabType.isolated
                          ? null
                          : appColors.isolatedTabTeal,
                    ),
                  ),
              ],
              selected: {defaultCreateTabType},
              onSelectionChanged: (value) async {
                await ref
                    .read(saveGeneralSettingsControllerProvider.notifier)
                    .save(
                      (currentSettings) => currentSettings.copyWith
                          .storedDefaultCreateTabType(value.first),
                    );
              },
              style: switch (defaultCreateTabType) {
                TabType.regular => null,
                TabType.private => SegmentedButton.styleFrom(
                  selectedBackgroundColor: appColors.privateSelectionOverlay,
                ),
                TabType.child => null,
                TabType.isolated => SegmentedButton.styleFrom(
                  selectedBackgroundColor: appColors.isolatedSelectionOverlay,
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallWebTabDefaultSection extends HookConsumerWidget {
  const _SmallWebTabDefaultSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = AppColors.of(context);
    final settings = ref.watch(generalSettingsWithDefaultsProvider);
    final smallWebTabType = settings.smallWebTabType;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            title: Text('Small Web Tab Default'),
            subtitle: Text('Choose the tab type used when entering Small Web'),
            leading: Icon(Icons.explore),
            contentPadding: EdgeInsets.zero,
          ),
          Center(
            child: SegmentedButton(
              showSelectedIcon: false,
              segments: [
                const ButtonSegment(
                  value: TabType.regular,
                  label: Text('Regular'),
                  icon: Icon(MdiIcons.tab),
                ),
                ButtonSegment(
                  value: TabType.private,
                  label: const Text('Private'),
                  icon: Icon(
                    MdiIcons.dominoMask,
                    color: smallWebTabType == TabType.private
                        ? null
                        : appColors.privateTabPurple,
                  ),
                ),
                if (settings.showIsolatedTabUi)
                  ButtonSegment(
                    value: TabType.isolated,
                    label: const Text('Isolated'),
                    icon: Icon(
                      MdiIcons.snowflake,
                      color: smallWebTabType == TabType.isolated
                          ? null
                          : appColors.isolatedTabTeal,
                    ),
                  ),
              ],
              selected: {smallWebTabType},
              onSelectionChanged: (value) async {
                await ref
                    .read(saveGeneralSettingsControllerProvider.notifier)
                    .save(
                      (currentSettings) =>
                          currentSettings.copyWith.smallWebTabType(value.first),
                    );
              },
              style: switch (smallWebTabType) {
                TabType.regular => null,
                TabType.private => SegmentedButton.styleFrom(
                  selectedBackgroundColor: appColors.privateSelectionOverlay,
                ),
                TabType.child => null,
                TabType.isolated => SegmentedButton.styleFrom(
                  selectedBackgroundColor: appColors.isolatedSelectionOverlay,
                ),
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
              segments: [
                const ButtonSegment(
                  value: TabIntentOpenSetting.ask,
                  label: Text('Prompt'),
                  icon: Icon(MdiIcons.messageQuestion),
                ),
                const ButtonSegment(
                  value: TabIntentOpenSetting.regular,
                  label: Text('Regular'),
                  icon: Icon(MdiIcons.tab),
                ),
                ButtonSegment(
                  value: TabIntentOpenSetting.private,
                  label: const Text('Private'),
                  icon: Icon(
                    MdiIcons.dominoMask,
                    color: tabIntentOpenSetting == TabIntentOpenSetting.private
                        ? null
                        : appColors.privateTabPurple,
                  ),
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

class _NewTabPositionSection extends HookConsumerWidget {
  const _NewTabPositionSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newTabPosition = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.newTabPosition),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            title: Text('New Tab Position'),
            subtitle: Text('Choose where newly created tabs appear by default'),
            leading: Icon(MdiIcons.reorderHorizontal),
            contentPadding: EdgeInsets.zero,
          ),
          Center(
            child: SegmentedButton(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: NewTabPosition.first,
                  label: Text('First'),
                  icon: Icon(MdiIcons.arrowCollapseLeft),
                ),
                ButtonSegment(
                  value: NewTabPosition.end,
                  label: Text('End'),
                  icon: Icon(MdiIcons.arrowCollapseRight),
                ),
              ],
              selected: {newTabPosition},
              onSelectionChanged: (value) async {
                await ref
                    .read(saveGeneralSettingsControllerProvider.notifier)
                    .save(
                      (currentSettings) =>
                          currentSettings.copyWith.newTabPosition(value.first),
                    );
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

class _ShowContainerUiTile extends HookConsumerWidget {
  const _ShowContainerUiTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showContainerUi = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.showContainerUi),
    );

    return SwitchListTile.adaptive(
      title: const Text('Show Container UI'),
      subtitle: const Text('Show container selectors, menus, and management'),
      secondary: const Icon(MdiIcons.folder),
      value: showContainerUi,
      onChanged: (value) async {
        await ref.read(saveGeneralSettingsControllerProvider.notifier).save((
          currentSettings,
        ) {
          var updated = currentSettings.copyWith.showContainerUi(value);
          if (!value &&
              updated.quickTabSwitcherMode ==
                  QuickTabSwitcherMode.containerTabs) {
            updated = updated.copyWith.quickTabSwitcherMode(
              QuickTabSwitcherMode.lastUsedTabs,
            );
          }
          return updated;
        });

        if (!value) {
          ref.read(selectedContainerProvider.notifier).clearContainer();
        }
      },
    );
  }
}

class _ShowIsolatedTabUiTile extends HookConsumerWidget {
  const _ShowIsolatedTabUiTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showIsolatedTabUi = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.showIsolatedTabUi),
    );

    return SwitchListTile.adaptive(
      title: const Text('Show Isolated Tab UI'),
      subtitle: const Text('Show isolated-tab creation options in the UI'),
      secondary: Icon(
        MdiIcons.snowflake,
        color: AppColors.of(context).isolatedTabTeal,
      ),
      value: showIsolatedTabUi,
      onChanged: (value) async {
        await ref.read(saveGeneralSettingsControllerProvider.notifier).save((
          currentSettings,
        ) {
          var updated = currentSettings.copyWith.showIsolatedTabUi(value);
          if (!value &&
              updated.storedDefaultCreateTabType == TabType.isolated) {
            updated = updated.copyWith.storedDefaultCreateTabType(
              TabType.regular,
            );
          }
          return updated;
        });
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

class _UrlCleanerSettingsTile extends StatelessWidget {
  const _UrlCleanerSettingsTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(MdiIcons.broom),
      title: const Text('URL Cleaner'),
      subtitle: const Text('Tracking removal rules and catalog updates'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await UrlCleanerSettingsRoute().push(context);
      },
    );
  }
}

class _UnshortenerSettingsTile extends StatelessWidget {
  const _UnshortenerSettingsTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(MdiIcons.linkVariant),
      title: const Text('Unshortener'),
      subtitle: const Text('Short link resolver and API token'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await UnshortenerSettingsRoute().push(context);
      },
    );
  }
}
