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

class GeneralSettingsScreen extends HookConsumerWidget {
  const GeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final generalSettings = ref.watch(generalSettingsWithDefaultsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('General Settings')),
      body: FadingScroll(
        fadingSize: 25,
        builder: (context, controller) {
          return ListView(
            controller: controller,
            children: [
              Padding(
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
                        selected: {generalSettings.themeMode},
                        onSelectionChanged: (value) async {
                          await ref
                              .read(
                                saveGeneralSettingsControllerProvider.notifier,
                              )
                              .save(
                                (currentSettings) => currentSettings.copyWith
                                    .themeMode(value.first),
                              );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
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
                        selected: {generalSettings.defaultCreateTabType},
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
                        style: switch (generalSettings.defaultCreateTabType) {
                          TabType.regular => null,
                          TabType.private => SegmentedButton.styleFrom(
                            selectedBackgroundColor: const Color(0x648000D7),
                          ),
                          TabType.child => null,
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
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
                        selected: {generalSettings.tabIntentOpenSetting},
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
                        style: switch (generalSettings.tabIntentOpenSetting) {
                          TabIntentOpenSetting.regular => null,
                          TabIntentOpenSetting.private =>
                            SegmentedButton.styleFrom(
                              selectedBackgroundColor: const Color(0x648000D7),
                            ),
                          TabIntentOpenSetting.ask => null,
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
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
              ),
              Padding(
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
                        initialSelection:
                            generalSettings.defaultSearchSuggestionsProvider,
                        inputDecorationTheme: InputDecorationTheme(
                          prefixIconConstraints: BoxConstraints.tight(
                            const Size.square(24),
                          ),
                        ),
                        width: double.infinity,
                        leadingIcon: generalSettings
                            .defaultSearchSuggestionsProvider
                            .relatedBang
                            .mapNotNull(
                              (trigger) => BangIcon(trigger: trigger),
                            ),
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
                                  saveGeneralSettingsControllerProvider
                                      .notifier,
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
              ),
              SwitchListTile.adaptive(
                title: const Text('On Device AI'),
                subtitle: const Text(
                  'Local on-device features including container topic and tab suggestions',
                ),
                secondary: const Icon(MdiIcons.creation),
                value: generalSettings.enableLocalAiFeatures,
                onChanged: (value) async {
                  await ref
                      .read(saveGeneralSettingsControllerProvider.notifier)
                      .save(
                        (currentSettings) => currentSettings.copyWith
                            .enableLocalAiFeatures(value),
                      );
                },
              ),
              SwitchListTile.adaptive(
                title: const Text('Enable Reader Mode'),
                subtitle: const Text(
                  'Optional browser app bar tool that extracts and simplifies web pages for improved readability by removing ads, sidebars, and other non-essential elements.',
                ),
                secondary: const Icon(MdiIcons.bookOpen),
                value: generalSettings.enableReadability,
                onChanged: (value) async {
                  await ref
                      .read(saveGeneralSettingsControllerProvider.notifier)
                      .save(
                        (currentSettings) =>
                            currentSettings.copyWith.enableReadability(value),
                      );
                },
              ),
              SwitchListTile.adaptive(
                title: const Text('Enforce Reader Mode'),
                subtitle: const Text(
                  'Override readability probability of websites and always show Reader Mode capabilities even the site might not be compatible.',
                ),
                secondary: const Icon(MdiIcons.bookCheck),
                value:
                    generalSettings.enableReadability &&
                    generalSettings.enforceReadability,
                onChanged: generalSettings.enableReadability
                    ? (value) async {
                        await ref
                            .read(
                              saveGeneralSettingsControllerProvider.notifier,
                            )
                            .save(
                              (currentSettings) => currentSettings.copyWith
                                  .enforceReadability(value),
                            );
                      }
                    : null,
              ),
              SwitchListTile.adaptive(
                title: const Text('Create Child Tabs'),
                subtitle: const Text(
                  'Display a button to create a child tab under the current tab (tree view only)',
                ),
                secondary: const Icon(MdiIcons.fileTree),
                value: generalSettings.createChildTabsOption,
                onChanged: (value) async {
                  await ref
                      .read(saveGeneralSettingsControllerProvider.notifier)
                      .save(
                        (currentSettings) => currentSettings.copyWith
                            .createChildTabsOption(value),
                      );
                },
              ),
              SwitchListTile.adaptive(
                title: const Text('Show Extension Shortcut'),
                subtitle: const Text(
                  'Display an extension menu directly on the tab bar',
                ),
                secondary: const Icon(MdiIcons.puzzleHeart),
                value: generalSettings.showExtensionShortcut,
                onChanged: (value) async {
                  await ref
                      .read(saveGeneralSettingsControllerProvider.notifier)
                      .save(
                        (currentSettings) => currentSettings.copyWith
                            .showExtensionShortcut(value),
                      );
                },
              ),
              SwitchListTile.adaptive(
                title: const Text('Auto Hide Tab Bar'),
                subtitle: const Text('Hide tab bar when scrolling'),
                secondary: const Icon(MdiIcons.folderHidden),
                value: generalSettings.autoHideTabBar,
                onChanged: (value) async {
                  await ref
                      .read(saveGeneralSettingsControllerProvider.notifier)
                      .save(
                        (currentSettings) =>
                            currentSettings.copyWith.autoHideTabBar(value),
                      );
                },
              ),
              Padding(
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
                      groupValue: generalSettings.tabBarSwipeAction,
                      onChanged: (value) async {
                        if (value != null) {
                          await ref
                              .read(
                                saveGeneralSettingsControllerProvider.notifier,
                              )
                              .save(
                                (currentSettings) => currentSettings.copyWith
                                    .tabBarSwipeAction(value),
                              );
                        }
                      },
                      child: const RadioListTile.adaptive(
                        value: TabBarSwipeAction.switchLastOpened,
                        title: Text('Switch to Last Used Tab'),
                        subtitle: Text(
                          'Swipe to toggle between current and previously opened tab',
                        ),
                      ),
                    ),
                    RadioGroup(
                      groupValue: generalSettings.tabBarSwipeAction,
                      onChanged: (value) async {
                        if (value != null) {
                          await ref
                              .read(
                                saveGeneralSettingsControllerProvider.notifier,
                              )
                              .save(
                                (currentSettings) => currentSettings.copyWith
                                    .tabBarSwipeAction(value),
                              );
                        }
                      },
                      child: const RadioListTile.adaptive(
                        value: TabBarSwipeAction.navigateOrderedTabs,
                        title: Text('Navigate Sequential Tabs'),
                        subtitle: Text(
                          'Swipe left/right to move through tabs in order',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Consumer(
                builder: (context, ref, child) {
                  final size = ref.watch(
                    iconCacheSizeMegabytesProvider.select(
                      (value) => value.valueOrNull,
                    ),
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
                        await ref
                            .read(cacheRepositoryProvider.notifier)
                            .clearCache();
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Clear'),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
