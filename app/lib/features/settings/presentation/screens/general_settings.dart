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
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/search/domain/entities/abstract/i_search_suggestion_provider.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/bang_icon.dart';
import 'package:weblibre/features/settings/presentation/widgets/custom_list_tile.dart';
import 'package:weblibre/features/settings/presentation/widgets/default_search_selector.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/providers.dart';
import 'package:weblibre/features/user/domain/repositories/cache.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

class GeneralSettingsScreen extends StatelessWidget {
  const GeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('General Settings')),
      body: FadingScroll(
        fadingSize: 25,
        builder: (context, controller) {
          return ListView(
            controller: controller,
            children: const [
              _ThemeSection(),
              _NewTabDefaultSection(),
              _ExternalLinkHandlingSection(),
              _DefaultSearchProviderSection(),
              _AutocompleteProviderSection(),
              _OnDeviceAiTile(),
              _EnableReaderModeTile(),
              _EnforceReaderModeTile(),
              _ReaderModeInTabBarTile(),
              _TabBarPositionSection(),
              _ShowContextualTabBarTile(),
              _ShowQuickTabSwitcherBarTile(),
              _QuickTabSwitcherModeSection(),
              _CreateChildTabsTile(),
              _ShowExtensionShortcutTile(),
              _AutoHideTabBarTile(),
              _BottomSheetTabViewTile(),
              _TabBarSwipeBehaviorSection(),
              _PullToRefreshTile(),
              _IconCacheTile(),
            ],
          );
        },
      ),
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
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8,
      ),
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
                    .read(
                      saveGeneralSettingsControllerProvider.notifier,
                    )
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

class _NewTabDefaultSection extends HookConsumerWidget {
  const _NewTabDefaultSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defaultCreateTabType = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.defaultCreateTabType),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            title: Text('New Tab Default'),
            subtitle: Text(
              'Choose the default type for manually created tabs',
            ),
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
                  icon: Icon(MdiIcons.tabUnselected),
                ),
              ],
              selected: {defaultCreateTabType},
              onSelectionChanged: (value) async {
                await ref
                    .read(
                      saveGeneralSettingsControllerProvider.notifier,
                    )
                    .save(
                      (currentSettings) => currentSettings.copyWith
                          .defaultCreateTabType(value.first),
                    );
              },
              style: switch (defaultCreateTabType) {
                TabType.regular => null,
                TabType.private => SegmentedButton.styleFrom(
                  selectedBackgroundColor: AppColors.privateSelectionOverlay,
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
    final tabIntentOpenSetting = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.tabIntentOpenSetting),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            title: Text('External Link Handling'),
            subtitle: Text(
              'Choose how external links open in WebLibre',
            ),
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
                  icon: Icon(MdiIcons.tabUnselected),
                ),
              ],
              selected: {tabIntentOpenSetting},
              onSelectionChanged: (value) async {
                await ref
                    .read(
                      saveGeneralSettingsControllerProvider.notifier,
                    )
                    .save(
                      (currentSettings) => currentSettings.copyWith
                          .tabIntentOpenSetting(value.first),
                    );
              },
              style: switch (tabIntentOpenSetting) {
                TabIntentOpenSetting.regular => null,
                TabIntentOpenSetting.private => SegmentedButton.styleFrom(
                  selectedBackgroundColor: AppColors.privateSelectionOverlay,
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

class _DefaultSearchProviderSection extends StatelessWidget {
  const _DefaultSearchProviderSection();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text('Default Search Provider'),
            leading: Icon(MdiIcons.cloudSearch),
            contentPadding: EdgeInsets.zero,
          ),
          Padding(
            padding: EdgeInsets.only(left: 40),
            child: DefaultSearchSelector(),
          ),
        ],
      ),
    );
  }
}

class _AutocompleteProviderSection extends HookConsumerWidget {
  const _AutocompleteProviderSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defaultSearchSuggestionsProvider = ref.watch(
      generalSettingsWithDefaultsProvider
          .select((s) => s.defaultSearchSuggestionsProvider),
    );
    final relatedBang = defaultSearchSuggestionsProvider.relatedBang;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            title: Text('Default Autocomplete Provider'),
            leading: Icon(MdiIcons.weatherCloudyArrowRight),
            contentPadding: EdgeInsets.zero,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: DropdownMenu<SearchSuggestionProviders>(
              initialSelection: defaultSearchSuggestionsProvider,
              inputDecorationTheme: InputDecorationTheme(
                prefixIconConstraints: BoxConstraints.tight(
                  const Size.square(24),
                ),
              ),
              width: double.infinity,
              leadingIcon:
                  relatedBang.mapNotNull((trigger) => BangIcon(trigger: trigger)),
              dropdownMenuEntries: SearchSuggestionProviders.values
                  .map((provider) {
                    return DropdownMenuEntry(
                      value: provider,
                      label: provider.label,
                      leadingIcon: provider.relatedBang.mapNotNull(
                        (trigger) => BangIcon(trigger: trigger),
                      ),
                    );
                  })
                  .toList(),
              onSelected: (value) async {
                if (value != null) {
                  await ref
                      .read(
                        saveGeneralSettingsControllerProvider.notifier,
                      )
                      .save(
                        (currentSettings) => currentSettings.copyWith
                            .defaultSearchSuggestionsProvider(value),
                      );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OnDeviceAiTile extends HookConsumerWidget {
  const _OnDeviceAiTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableLocalAiFeatures = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.enableLocalAiFeatures),
    );

    return SwitchListTile.adaptive(
      title: const Text('On Device AI'),
      subtitle: const Text(
        'Local on-device features including container topic and tab suggestions',
      ),
      secondary: const Icon(MdiIcons.creation),
      value: enableLocalAiFeatures,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.enableLocalAiFeatures(value),
            );
      },
    );
  }
}

class _EnableReaderModeTile extends HookConsumerWidget {
  const _EnableReaderModeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableReadability = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.enableReadability),
    );

    return SwitchListTile.adaptive(
      title: const Text('Enable Reader Mode'),
      subtitle: const Text(
        'Optional browser app bar tool that extracts and simplifies web pages for improved readability by removing ads, sidebars, and other non-essential elements.',
      ),
      secondary: const Icon(MdiIcons.bookOpen),
      value: enableReadability,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.enableReadability(value),
            );
      },
    );
  }
}

class _EnforceReaderModeTile extends HookConsumerWidget {
  const _EnforceReaderModeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableReadability = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.enableReadability),
    );
    final enforceReadability = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.enforceReadability),
    );

    return SwitchListTile.adaptive(
      title: const Text('Enforce Reader Mode'),
      subtitle: const Text(
        'Override readability probability of websites and always show Reader Mode capabilities even the site might not be compatible.',
      ),
      secondary: const Icon(MdiIcons.bookCheck),
      value: enableReadability && enforceReadability,
      onChanged: enableReadability
          ? (value) async {
              await ref
                  .read(
                    saveGeneralSettingsControllerProvider.notifier,
                  )
                  .save(
                    (currentSettings) =>
                        currentSettings.copyWith.enforceReadability(value),
                  );
            }
          : null,
    );
  }
}

class _ReaderModeInTabBarTile extends HookConsumerWidget {
  const _ReaderModeInTabBarTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabBarReaderView = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.tabBarReaderView),
    );

    return SwitchListTile.adaptive(
      title: const Text('Reader Mode in Tab Bar'),
      subtitle: const Text(
        'Show reader mode button in the tab bar instead of only in the tab menu',
      ),
      secondary: const Icon(MdiIcons.bookHeart),
      value: tabBarReaderView,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.tabBarReaderView(value),
            );
      },
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
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8,
      ),
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
                    .read(
                      saveGeneralSettingsControllerProvider.notifier,
                    )
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
                  subtitle: Text(
                    'Persistent tab bar without auto-hide',
                  ),
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

class _ShowContextualTabBarTile extends HookConsumerWidget {
  const _ShowContextualTabBarTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabBarShowContextualBar = ref.watch(
      generalSettingsWithDefaultsProvider
          .select((s) => s.tabBarShowContextualBar),
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

class _ShowQuickTabSwitcherBarTile extends HookConsumerWidget {
  const _ShowQuickTabSwitcherBarTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabBarShowQuickTabSwitcherBar = ref.watch(
      generalSettingsWithDefaultsProvider
          .select((s) => s.tabBarShowQuickTabSwitcherBar),
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
              (currentSettings) => currentSettings.copyWith
                  .tabBarShowQuickTabSwitcherBar(value),
            );
      },
    );
  }
}

class _QuickTabSwitcherModeSection extends HookConsumerWidget {
  const _QuickTabSwitcherModeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quickTabSwitcherMode = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.quickTabSwitcherMode),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8,
      ),
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
                    .read(
                      saveGeneralSettingsControllerProvider.notifier,
                    )
                    .save(
                      (currentSettings) => currentSettings.copyWith
                          .quickTabSwitcherMode(value),
                    );
              }
            },
            child: const Column(
              children: [
                RadioListTile.adaptive(
                  value: QuickTabSwitcherMode.lastUsedTabs,
                  title: Text('Recently Used Tabs'),
                  subtitle: Text(
                    'Recently used tabs across all containers',
                  ),
                ),
                RadioListTile.adaptive(
                  value: QuickTabSwitcherMode.containerTabs,
                  title: Text('Container Tabs'),
                  subtitle: Text(
                    'Ordered tabs of the selected container',
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

class _CreateChildTabsTile extends HookConsumerWidget {
  const _CreateChildTabsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final createChildTabsOption = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.createChildTabsOption),
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
      generalSettingsWithDefaultsProvider.select((s) => s.showExtensionShortcut),
    );

    return SwitchListTile.adaptive(
      title: const Text('Show Extension Shortcut'),
      subtitle: const Text(
        'Display an extension menu directly on the tab bar',
      ),
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

class _TabBarSwipeBehaviorSection extends HookConsumerWidget {
  const _TabBarSwipeBehaviorSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabBarSwipeAction = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.tabBarSwipeAction),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8,
      ),
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
                    .read(
                      saveGeneralSettingsControllerProvider.notifier,
                    )
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

class _IconCacheTile extends HookConsumerWidget {
  const _IconCacheTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = ref.watch(
      iconCacheSizeMegabytesProvider.select((value) => value.value),
    );

    return CustomListTile(
      title: 'Icon Cache',
      subtitle: 'Stored favicons',
      prefix: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Icon(
          Icons.image,
          size: 24,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: DefaultTextStyle(
          style: GoogleFonts.robotoMono(
            textStyle: DefaultTextStyle.of(context).style,
          ),
          child: Table(
            columnWidths: const {0: FixedColumnWidth(100)},
            children: [
              TableRow(
                children: [
                  const Text('Size'),
                  Text('${size?.toStringAsFixed(2) ?? 0} MB'),
                ],
              ),
            ],
          ),
        ),
      ),
      suffix: FilledButton.icon(
        onPressed: () async {
          await ref.read(cacheRepositoryProvider.notifier).clearCache();
        },
        icon: const Icon(Icons.delete),
        label: const Text('Clear'),
      ),
    );
  }
}
