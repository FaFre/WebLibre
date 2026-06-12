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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

const List<SettingsSectionDefinition> browsingSettingsSections = [
  SettingsSectionDefinition(
    title: 'Tabs',
    entries: [
      SettingsEntryDefinition(
        title: 'New Tab Default',
        subtitle: 'Choose the default type for manually created tabs',
        keywords: ['regular', 'private', 'isolated'],
        child: _NewTabDefaultSection(),
      ),
      SettingsEntryDefinition(
        title: 'Small Web Tab Default',
        subtitle: 'Choose the tab type used when entering Small Web',
        keywords: ['regular', 'private', 'isolated'],
        child: _SmallWebTabDefaultSection(),
      ),
      SettingsEntryDefinition(
        title: 'Tab List Direction',
        subtitle: 'Choose how tabs are ordered in the list view',
        keywords: ['sorting', 'order'],
        child: _TabListDirectionSection(),
      ),
      SettingsEntryDefinition(
        title: 'Tab Bar Direction',
        subtitle: 'Choose how tabs are ordered in the tab bar',
        keywords: ['sorting', 'order'],
        child: _TabBarDirectionSection(),
      ),
      SettingsEntryDefinition(
        title: 'Show Container UI',
        subtitle: 'Show container selectors, menus, and management',
        keywords: ['containers'],
        child: _ShowContainerUiTile(),
      ),
      SettingsEntryDefinition(
        title: 'Show Isolated Tab UI',
        subtitle: 'Show isolated-tab creation options in the UI',
        keywords: ['isolated tabs'],
        child: _ShowIsolatedTabUiTile(),
      ),
      SettingsEntryDefinition(
        title: 'Create Child Tabs',
        subtitle: 'Open links from tabs in the same container context',
        keywords: ['child tabs'],
        child: _CreateChildTabsTile(),
      ),
    ],
  ),
  SettingsSectionDefinition(
    title: 'Navigation',
    entries: [
      SettingsEntryDefinition(
        title: 'Pull to Refresh',
        subtitle: 'Swipe down on pages to reload them',
        keywords: ['reload'],
        child: _PullToRefreshTile(),
      ),
      SettingsEntryDefinition(
        title: 'Double Back to Close Tab',
        subtitle: 'Require double back press before closing the current tab',
        keywords: ['back button'],
        child: _DoubleBackCloseTabTile(),
      ),
      SettingsEntryDefinition(
        title: 'Tab Bar Swipe Behavior',
        subtitle: 'Choose what horizontal swipes on the tab bar do',
        keywords: ['gestures', 'swipe'],
        child: _TabBarSwipeBehaviorSection(),
      ),
      SettingsEntryDefinition(
        title: 'Open Links in Apps',
        subtitle: 'Choose how external app links open',
        keywords: ['app links', 'external apps'],
        child: _AppLinksModeSection(),
      ),
    ],
  ),
  SettingsSectionDefinition(
    title: 'Desktop Mode',
    entries: [
      SettingsEntryDefinition(
        title: 'Always Request Desktop Site',
        subtitle: 'Open new tabs in desktop mode by default',
        keywords: ['desktop mode', 'user agent', 'mobile site', 'tablet'],
        child: _GlobalDesktopModeTile(),
      ),
      SettingsEntryDefinition(
        title: 'Desktop Mode Sites',
        subtitle: 'Sites that always load in desktop mode',
        keywords: ['desktop mode', 'per-site', 'user agent', 'exceptions'],
        child: _DesktopModeSitesTile(),
      ),
    ],
  ),
  SettingsSectionDefinition(
    title: 'Home Screen',
    entries: [
      SettingsEntryDefinition(
        title: 'Install Sites as Apps',
        subtitle: 'Allow websites without a manifest to be installed as apps',
        keywords: ['pwa', 'web apps'],
        child: _AllowNonManifestPwaInstallTile(),
      ),
    ],
  ),
  SettingsSectionDefinition(
    title: 'External Links',
    entries: [
      SettingsEntryDefinition(
        title: 'External Link Handling',
        subtitle: 'Choose how external links open in WebLibre',
        keywords: ['intents'],
        child: _ExternalLinkHandlingSection(),
      ),
      SettingsEntryDefinition(
        title: 'URL Cleaner',
        subtitle: 'Tracking removal rules and catalog updates',
        keywords: ['utm', 'tracking parameters'],
        child: _UrlCleanerSettingsTile(),
      ),
      SettingsEntryDefinition(
        title: 'Unshortener',
        subtitle: 'Short link resolver and API token',
        keywords: ['short links', 'redirects'],
        child: _UnshortenerSettingsTile(),
      ),
    ],
  ),
];

class BrowsingSettingsScreen extends StatelessWidget {
  const BrowsingSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsDetailScaffold(
      title: 'Browsing',
      subtitle: 'Tabs, navigation, app links, and Small Web behavior.',
      icon: MdiIcons.compassOutline,
      sections: browsingSettingsSections,
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
    final smallWebTabType = settings.effectiveSmallWebTabType;

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
    final settings = ref.watch(generalSettingsWithDefaultsProvider);
    final tabIntentOpenSetting = settings.tabIntentOpenSetting;

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
          RadioGroup(
            groupValue: tabIntentOpenSetting,
            onChanged: (value) async {
              if (value != null) {
                await ref
                    .read(saveGeneralSettingsControllerProvider.notifier)
                    .save(
                      (currentSettings) =>
                          currentSettings.copyWith.tabIntentOpenSetting(value),
                    );
              }
            },
            child: Column(
              children: [
                const RadioListTile.adaptive(
                  value: TabIntentOpenSetting.ask,
                  title: Text('Prompt'),
                  subtitle: Text('Ask how external links should open'),
                  secondary: Icon(MdiIcons.messageQuestion),
                ),
                const RadioListTile.adaptive(
                  value: TabIntentOpenSetting.regular,
                  title: Text('Regular'),
                  subtitle: Text('Open external links in a regular tab'),
                  secondary: Icon(MdiIcons.tab),
                ),
                RadioListTile.adaptive(
                  value: TabIntentOpenSetting.private,
                  title: const Text('Private'),
                  subtitle: const Text('Open external links in a private tab'),
                  secondary: Icon(
                    MdiIcons.dominoMask,
                    color: AppColors.of(context).privateTabPurple,
                  ),
                ),
                if (settings.showIsolatedTabUi)
                  RadioListTile.adaptive(
                    value: TabIntentOpenSetting.isolated,
                    title: const Text('Isolated'),
                    subtitle: const Text(
                      'Open external links in an isolated tab',
                    ),
                    secondary: Icon(
                      MdiIcons.snowflake,
                      color: AppColors.of(context).isolatedTabTeal,
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

class _TabListDirectionSection extends HookConsumerWidget {
  const _TabListDirectionSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final direction = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.tabListDirection),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            title: Text('Tab List Direction'),
            subtitle: Text(
              'Choose whether the newest tab appears at the top or bottom of the tab list',
            ),
            leading: Icon(MdiIcons.formatListBulleted),
            contentPadding: EdgeInsets.zero,
          ),
          Center(
            child: SegmentedButton(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: TabDirection.newestFirst,
                  label: Text('Newest first'),
                  icon: Icon(MdiIcons.arrowCollapseUp),
                ),
                ButtonSegment(
                  value: TabDirection.oldestFirst,
                  label: Text('Oldest first'),
                  icon: Icon(MdiIcons.arrowCollapseDown),
                ),
              ],
              selected: {direction},
              onSelectionChanged: (value) async {
                await ref
                    .read(saveGeneralSettingsControllerProvider.notifier)
                    .save(
                      (currentSettings) => currentSettings.copyWith
                          .tabListDirection(value.first),
                    );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBarDirectionSection extends HookConsumerWidget {
  const _TabBarDirectionSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final direction = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.tabBarDirection),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            title: Text('Tab Bar Direction'),
            subtitle: Text(
              'Choose whether the newest tab appears on the left or right of the quick switcher',
            ),
            leading: Icon(MdiIcons.reorderHorizontal),
            contentPadding: EdgeInsets.zero,
          ),
          Center(
            child: SegmentedButton(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: TabDirection.newestFirst,
                  label: Text('Newest first'),
                  icon: Icon(MdiIcons.arrowCollapseLeft),
                ),
                ButtonSegment(
                  value: TabDirection.oldestFirst,
                  label: Text('Oldest first'),
                  icon: Icon(MdiIcons.arrowCollapseRight),
                ),
              ],
              selected: {direction},
              onSelectionChanged: (value) async {
                await ref
                    .read(saveGeneralSettingsControllerProvider.notifier)
                    .save(
                      (currentSettings) =>
                          currentSettings.copyWith.tabBarDirection(value.first),
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
              const {
                TabBarStackingMode.containerTabs,
                TabBarStackingMode.accordion,
                TabBarStackingMode.twoLevel,
              }.contains(updated.tabBarStackingMode)) {
            updated = updated.copyWith.tabBarStackingMode(
              TabBarStackingMode.lastUsedTabs,
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
          if (!value &&
              updated.tabIntentOpenSetting == TabIntentOpenSetting.isolated) {
            updated = updated.copyWith.tabIntentOpenSetting(
              TabIntentOpenSetting.ask,
            );
          }
          if (!value && updated.smallWebTabType == TabType.isolated) {
            updated = updated.copyWith.smallWebTabType(TabType.private);
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

class _GlobalDesktopModeTile extends HookConsumerWidget {
  const _GlobalDesktopModeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalDesktopMode = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.globalDesktopMode),
    );

    return SwitchListTile.adaptive(
      title: const Text('Always Request Desktop Site'),
      subtitle: const Text(
        'Open new tabs in desktop mode by default. You can still toggle desktop '
        'mode per tab from the page menu.',
      ),
      secondary: const Icon(MdiIcons.monitor),
      value: globalDesktopMode,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.globalDesktopMode(value),
            );
      },
    );
  }
}

class _DesktopModeSitesTile extends StatelessWidget {
  const _DesktopModeSitesTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.desktop_windows),
      title: const Text('Desktop Mode Sites'),
      subtitle: const Text('Sites that always load in desktop mode'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await const DesktopModeSitesRoute().push(context);
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

class _AllowNonManifestPwaInstallTile extends HookConsumerWidget {
  const _AllowNonManifestPwaInstallTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allowNonManifestPwaInstall = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.allowNonManifestPwaInstall,
      ),
    );

    return SwitchListTile.adaptive(
      title: const Text('Install Sites as Apps'),
      subtitle: const Text(
        'Allow installing websites without a PWA manifest as standalone apps',
      ),
      secondary: const Icon(Icons.add_to_home_screen),
      value: allowNonManifestPwaInstall,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.allowNonManifestPwaInstall(value),
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
