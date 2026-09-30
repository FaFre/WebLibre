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
import 'package:weblibre/core/providers/window_size_class.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/utils/tab_bar_position_setting_l10n.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/hooks/keyed_state.dart';

List<SettingsSectionDefinition> toolbarLayoutSettingsSections(
  BuildContext context,
) {
  final l10n = AppLocalizations.of(context);

  return [
    SettingsSectionDefinition(
      title: l10n.settings_tabBarSectionTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_tabBarPositionTitle,
          subtitle: l10n.settings_indexTabBarPositionSubtitle,
          keywords: settingsKeywords(l10n.settings_tabBarPositionKeywords),
          child: const _TabBarPositionSection(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_tabBarStyleTitle,
          subtitle: l10n.settings_indexTabBarStyleSubtitle,
          keywords: settingsKeywords(l10n.settings_tabBarStyleKeywords),
          child: const _TabBarLayoutModeSection(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_autoHideTabBarTitle,
          subtitle: l10n.settings_indexAutoHideTabBarSubtitle,
          keywords: settingsKeywords(l10n.settings_autoHideTabBarKeywords),
          child: const _AutoHideTabBarTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_autoHideSidePanelTitle,
          subtitle: l10n.settings_indexAutoHideSidePanelSubtitle,
          keywords: settingsKeywords(l10n.settings_autoHideSidePanelKeywords),
          child: const _SideRailAutoHideTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_longPressUrlCopyTitle,
          subtitle: l10n.settings_indexLongPressUrlCopySubtitle,
          keywords: settingsKeywords(l10n.settings_longPressUrlCopyKeywords),
          child: const _TabBarLongPressUrlCopyTile(),
        ),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.settings_contextualToolbarSectionTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_showContextualToolbarTitle,
          subtitle: l10n.settings_indexShowContextualToolbarSubtitle,
          keywords: settingsKeywords(
            l10n.settings_showContextualToolbarKeywords,
          ),
          child: const _ShowContextualTabBarTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_customizeToolbarButtons,
          subtitle: l10n.settings_indexCustomizeToolbarButtonsSubtitle,
          keywords: settingsKeywords(
            l10n.settings_customizeToolbarButtonsKeywords,
          ),
          child: const _CustomizeToolbarButtonsTile(),
        ),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.settings_quickTabSwitcherSectionTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_tabStackingTitle,
          subtitle: l10n.settings_indexTabStackingSubtitle,
          keywords: settingsKeywords(l10n.settings_tabStackingKeywords),
          child: const _TabBarStackingModeSection(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_customizeSwitcherButtons,
          subtitle: l10n.settings_indexCustomizeSwitcherButtonsSubtitle,
          keywords: settingsKeywords(
            l10n.settings_customizeSwitcherButtonsKeywords,
          ),
          child: const _CustomizeQuickSwitcherButtonsTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_closeButtonsTitle,
          subtitle: l10n.settings_closeButtonsSubtitle,
          keywords: settingsKeywords(l10n.settings_closeButtonsKeywords),
          child: const _QuickTabSwitcherCloseButtonsSection(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_historyFallbackTitle,
          subtitle: l10n.settings_indexHistoryFallbackSubtitle,
          keywords: settingsKeywords(l10n.settings_historyFallbackKeywords),
          child: const _QuickTabSwitcherHistorySuggestionsTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_showTitlesTitle,
          subtitle: l10n.settings_indexShowTitlesSubtitle,
          keywords: settingsKeywords(l10n.settings_showTitlesKeywords),
          child: const _QuickTabSwitcherShowTitlesTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_titleWidthTitle,
          subtitle: l10n.settings_titleWidthSubtitle,
          keywords: settingsKeywords(l10n.settings_titleWidthKeywords),
          child: const _QuickTabSwitcherTitleWidthTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_hierarchyDepthTitle,
          subtitle: l10n.settings_indexHierarchyDepthSubtitle,
          keywords: settingsKeywords(l10n.settings_hierarchyDepthKeywords),
          child: const _QuickTabSwitcherHierarchyGlyphsTile(),
        ),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.settings_tabViewSectionTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_bottomSheetTabViewTitle,
          subtitle: l10n.settings_indexBottomSheetTabViewSubtitle,
          keywords: settingsKeywords(l10n.settings_bottomSheetTabViewKeywords),
          child: const _BottomSheetTabViewTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_showFaviconsTitle,
          subtitle: l10n.settings_indexShowFaviconsSubtitle,
          keywords: settingsKeywords(l10n.settings_showFaviconsKeywords),
          child: const _TabListShowFaviconsTile(),
        ),
      ],
    ),
  ];
}

/// The browser menu's own arrangement entry.
///
/// Kept out of [toolbarLayoutSettingsSections] because onboarding renders those
/// too, and arranging the menu is not a first-run decision. Offered to the
/// settings screen as [ToolbarLayoutContent.extraSections] so it takes part in
/// the same filtering — a row rendered beside the filtered list would survive a
/// query that empties the list, leaving a match sitting above "No settings
/// match".
List<SettingsSectionDefinition> menuLayoutSettingsSections(
  BuildContext context,
) {
  final l10n = AppLocalizations.of(context);

  return [
    SettingsSectionDefinition(
      title: l10n.settings_menuSectionTitle,
      keywords: settingsKeywords(l10n.settings_menuSectionKeywords),
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_customizeMenu,
          subtitle: l10n.settings_customizeMenuSubtitle,
          keywords: settingsKeywords(l10n.settings_customizeMenuKeywords),
          child: const _CustomizeMenuTile(),
        ),
      ],
    ),
  ];
}

class ToolbarLayoutContent extends StatelessWidget {
  final String query;

  /// Sections shown after the toolbar's own, filtered by the same [query].
  final List<SettingsSectionDefinition> extraSections;

  const ToolbarLayoutContent({
    super.key,
    this.query = '',
    this.extraSections = const [],
  });

  @override
  Widget build(BuildContext context) {
    final filteredSections = filterSettingsSections(
      sections: [...toolbarLayoutSettingsSections(context), ...extraSections],
      query: query,
    );

    return SettingsSectionList(sections: filteredSections, query: query);
  }
}

class _CustomizeMenuTile extends StatelessWidget {
  const _CustomizeMenuTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      leading: const Icon(Icons.tune),
      title: Text(l10n.settings_customizeMenu),
      subtitle: Text(l10n.settings_customizeMenuSubtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await const MenuLayoutSettingsRoute().push(context);
      },
    );
  }
}

class _TabBarPositionSection extends HookConsumerWidget {
  const _TabBarPositionSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The raw setting drives the radio group -- this is the one screen that
    // must show what was *chosen*, including "decide for me". Everywhere else
    // reads effectiveTabBarPositionProvider.
    final l10n = AppLocalizations.of(context);
    final tabBarPosition = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.tabBarPosition),
    );
    final resolved = ref.watch(effectiveTabBarPositionProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(l10n.settings_tabBarPositionTitle),
            leading: const Icon(MdiIcons.dockWindow),
            contentPadding: EdgeInsets.zero,
          ),
          RadioGroup(
            groupValue: tabBarPosition,
            onChanged: (TabBarPositionSetting? value) async {
              if (value != null) {
                await ref
                    .read(saveGeneralSettingsControllerProvider.notifier)
                    .save(
                      (currentSettings) =>
                          currentSettings.copyWith.tabBarPosition(value),
                    );
              }
            },
            child: Column(
              children: [
                for (final position in TabBarPositionSetting.values)
                  RadioListTile.adaptive(
                    value: position,
                    title: Text(position.label(context)),
                    // Automatic says what it currently resolves to on this
                    // screen; the fixed choices already describe themselves.
                    subtitle: Text(
                      position == TabBarPositionSetting.auto
                          ? l10n.settings_currentlyResolvesTo(
                              position.description(context),
                              resolved.label(context),
                            )
                          : position.description(context),
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

class _TabBarLayoutModeSection extends HookConsumerWidget {
  const _TabBarLayoutModeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tabBarLayout = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.tabBarLayout),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(l10n.settings_tabBarStyleTitle),
            leading: const Icon(MdiIcons.tabUnselected),
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
            child: Column(
              children: [
                RadioListTile.adaptive(
                  value: TabBarLayout.withTitle,
                  title: Text(l10n.settings_withTitleOption),
                  subtitle: Text(l10n.settings_withTitleDescription),
                ),
                RadioListTile.adaptive(
                  value: TabBarLayout.compact,
                  title: Text(l10n.settings_compactOption),
                  subtitle: Text(l10n.settings_compactDescription),
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
    final l10n = AppLocalizations.of(context);
    final tabBarShowContextualBar = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.tabBarShowContextualBar,
      ),
    );

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_showContextualToolbarTitle),
      subtitle: Text(l10n.settings_showContextualToolbarSubtitle),
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
    final l10n = AppLocalizations.of(context);
    final tabBarShowContextualBar = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.tabBarShowContextualBar,
      ),
    );

    return ListTile(
      leading: const Icon(Icons.tune),
      title: Text(l10n.settings_customizeToolbarButtons),
      trailing: const Icon(Icons.chevron_right),
      enabled: tabBarShowContextualBar,
      onTap: () async {
        await const ContextualToolbarSettingsRoute().push(context);
      },
    );
  }
}

class _CustomizeQuickSwitcherButtonsTile extends HookConsumerWidget {
  const _CustomizeQuickSwitcherButtonsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final switcherEnabled = ref.watch(
      effectiveTabBarStackingModeProvider.select(
        (mode) => mode != TabBarStackingMode.disabled,
      ),
    );

    return ListTile(
      leading: const Icon(Icons.tune),
      title: Text(l10n.settings_customizeSwitcherButtons),
      subtitle: Text(l10n.settings_customizeSwitcherButtonsSubtitle),
      trailing: const Icon(Icons.chevron_right),
      enabled: switcherEnabled,
      onTap: () async {
        await const QuickSwitcherToolbarSettingsRoute().push(context);
      },
    );
  }
}

class _TabBarStackingModeSection extends HookConsumerWidget {
  const _TabBarStackingModeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(generalSettingsWithDefaultsProvider);
    final stackingMode = ref.watch(effectiveTabBarStackingModeProvider);
    final window = ref.watch(windowSizeClassControllerProvider);
    final railIsNarrow =
        ref.watch(effectiveTabBarPositionProvider).isVertical &&
        !window.allowsWideRail;

    final offeredModes = {
      TabBarStackingMode.lastUsedTabs,
      if (settings.showContainerUi) ...[
        TabBarStackingMode.containerTabs,
        TabBarStackingMode.accordion,
        if (!railIsNarrow) ...[
          TabBarStackingMode.twoLevel,
          TabBarStackingMode.tabGroups,
        ],
      ],
      TabBarStackingMode.disabled,
    };
    // The radio shows what the user picked, not what the current room reduces
    // it to: a short window or a collapsed side panel stands a stacked mode in
    // for a single row, and marking that row selected would make picking the
    // stacked mode look like it did nothing. The stand-in is named under the
    // choice instead. A choice that is not offered here falls back to the
    // effective mode, as before.
    final selectedMode = offeredModes.contains(settings.tabBarStackingMode)
        ? settings.tabBarStackingMode
        : stackingMode;
    final fallbackNote = selectedMode == stackingMode
        ? null
        : switch (stackingMode) {
            TabBarStackingMode.accordion =>
              l10n.settings_tabStackingFallbackAccordion,
            TabBarStackingMode.containerTabs =>
              l10n.settings_tabStackingFallbackContainerTabs,
            _ => null,
          };

    Widget optionSubtitle(TabBarStackingMode mode, String description) {
      if (mode != selectedMode || fallbackNote == null) {
        return Text(description);
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(description),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              fallbackNote,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(l10n.settings_tabStackingTitle),
            subtitle: Text(l10n.settings_tabStackingSubtitle),
            leading: const Icon(MdiIcons.folderSettings),
            contentPadding: EdgeInsets.zero,
          ),
          RadioGroup(
            groupValue: selectedMode,
            onChanged: (value) async {
              if (value != null) {
                await ref
                    .read(saveGeneralSettingsControllerProvider.notifier)
                    .save(
                      (currentSettings) =>
                          currentSettings.copyWith.tabBarStackingMode(value),
                    );
              }
            },
            child: Column(
              children: [
                RadioListTile.adaptive(
                  value: TabBarStackingMode.lastUsedTabs,
                  title: Text(l10n.settings_recentlyUsedTabsOption),
                  subtitle: Text(l10n.settings_recentlyUsedTabsDescription),
                ),
                if (settings.showContainerUi) ...[
                  RadioListTile.adaptive(
                    value: TabBarStackingMode.containerTabs,
                    title: Text(l10n.settings_containerTabsOption),
                    subtitle: Text(l10n.settings_containerTabsDescription),
                  ),
                  RadioListTile.adaptive(
                    value: TabBarStackingMode.accordion,
                    title: Text(l10n.settings_accordionOption),
                    subtitle: Text(l10n.settings_accordionDescription),
                  ),
                  // Two stacked rows don't fit the *narrow* vertical side
                  // rail, which no resize can widen in this window; hide the
                  // options there to avoid a no-op choice. A short window or a
                  // collapsed panel can change, so there they stay offered and
                  // name their stand-in (see selectedMode).
                  if (!railIsNarrow) ...[
                    RadioListTile.adaptive(
                      value: TabBarStackingMode.twoLevel,
                      title: Text(l10n.settings_twoRowsOption),
                      subtitle: optionSubtitle(
                        TabBarStackingMode.twoLevel,
                        l10n.settings_twoRowsDescription,
                      ),
                    ),
                    RadioListTile.adaptive(
                      value: TabBarStackingMode.tabGroups,
                      title: Text(l10n.settings_tabGroupsOption),
                      subtitle: optionSubtitle(
                        TabBarStackingMode.tabGroups,
                        l10n.settings_tabGroupsDescription,
                      ),
                    ),
                  ],
                ],
                RadioListTile.adaptive(
                  value: TabBarStackingMode.disabled,
                  title: Text(l10n.settings_disabledOption),
                  subtitle: Text(l10n.settings_disabledDescription),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickTabSwitcherCloseButtonsSection extends HookConsumerWidget {
  const _QuickTabSwitcherCloseButtonsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final closeButtonMode = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.quickTabSwitcherCloseButtonMode,
      ),
    );
    final switcherEnabled = ref.watch(
      effectiveTabBarStackingModeProvider.select(
        (mode) => mode != TabBarStackingMode.disabled,
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(l10n.settings_closeButtonsTitle),
            subtitle: Text(l10n.settings_closeButtonsSubtitle),
            leading: const Icon(MdiIcons.closeCircleOutline),
            contentPadding: EdgeInsets.zero,
          ),
          RadioGroup(
            groupValue: closeButtonMode,
            onChanged: (value) async {
              if (value != null) {
                await ref
                    .read(saveGeneralSettingsControllerProvider.notifier)
                    .save(
                      (currentSettings) => currentSettings.copyWith
                          .quickTabSwitcherCloseButtonMode(value),
                    );
              }
            },
            child: Column(
              children: [
                RadioListTile.adaptive(
                  value: TabChipCloseButtonMode.activeTabOnly,
                  enabled: switcherEnabled,
                  title: Text(l10n.settings_activeTabOnlyOption),
                  subtitle: Text(l10n.settings_activeTabOnlyDescription),
                ),
                RadioListTile.adaptive(
                  value: TabChipCloseButtonMode.all,
                  enabled: switcherEnabled,
                  title: Text(l10n.settings_allTabsOption),
                  subtitle: Text(l10n.settings_allTabsDescription),
                ),
                RadioListTile.adaptive(
                  value: TabChipCloseButtonMode.never,
                  enabled: switcherEnabled,
                  title: Text(l10n.settings_neverOption),
                  subtitle: Text(l10n.settings_neverCloseDescription),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickTabSwitcherTitleWidthTile extends HookConsumerWidget {
  const _QuickTabSwitcherTitleWidthTile();

  static final _divisions =
      ((maxQuickTabSwitcherTitleWidth - minQuickTabSwitcherTitleWidth) /
              quickTabSwitcherTitleWidthStep)
          .round();

  static String _label(double width) => '${width.round()} px';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleWidth = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.quickTabSwitcherTitleWidth,
      ),
    );
    final showTitles = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.quickTabSwitcherShowTitles,
      ),
    );
    final switcherEnabled = ref.watch(
      effectiveTabBarStackingModeProvider.select(
        (mode) => mode != TabBarStackingMode.disabled,
      ),
    );

    final l10n = AppLocalizations.of(context);
    final sliderValue = useKeyedState(titleWidth, [titleWidth]);

    final enabled = switcherEnabled && showTitles;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(l10n.settings_titleWidthTitle),
            subtitle: Text(l10n.settings_titleWidthSubtitle),
            leading: const Icon(MdiIcons.arrowExpandHorizontal),
            contentPadding: EdgeInsets.zero,
            enabled: enabled,
          ),
          Row(
            children: [
              Expanded(
                child: Slider(
                  min: minQuickTabSwitcherTitleWidth,
                  max: maxQuickTabSwitcherTitleWidth,
                  divisions: _divisions,
                  label: _label(sliderValue.value),
                  value: sliderValue.value.clamp(
                    minQuickTabSwitcherTitleWidth,
                    maxQuickTabSwitcherTitleWidth,
                  ),
                  onChanged: enabled
                      ? (value) {
                          sliderValue.value = value;
                        }
                      : null,
                  onChangeEnd: enabled
                      ? (value) async {
                          final normalized =
                              (value / quickTabSwitcherTitleWidthStep).round() *
                              quickTabSwitcherTitleWidthStep;
                          sliderValue.value = normalized;
                          await ref
                              .read(
                                saveGeneralSettingsControllerProvider.notifier,
                              )
                              .save(
                                (currentSettings) => currentSettings.copyWith
                                    .quickTabSwitcherTitleWidth(normalized),
                              );
                        }
                      : null,
                ),
              ),
              Text(
                _label(sliderValue.value),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
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
    final l10n = AppLocalizations.of(context);
    final showHistorySuggestions = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.quickTabSwitcherShowHistorySuggestions,
      ),
    );
    final switcherEnabled = ref.watch(
      effectiveTabBarStackingModeProvider.select(
        (mode) => mode != TabBarStackingMode.disabled,
      ),
    );

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_historyFallbackTitle),
      subtitle: Text(l10n.settings_historyFallbackSubtitle),
      secondary: const Icon(MdiIcons.history),
      value: showHistorySuggestions,
      onChanged: switcherEnabled
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
    final l10n = AppLocalizations.of(context);
    final quickTabSwitcherShowTitles = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.quickTabSwitcherShowTitles,
      ),
    );
    final switcherEnabled = ref.watch(
      effectiveTabBarStackingModeProvider.select(
        (mode) => mode != TabBarStackingMode.disabled,
      ),
    );

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_showTitlesTitle),
      subtitle: Text(l10n.settings_showTitlesSubtitle),
      secondary: const Icon(MdiIcons.textRecognition),
      value: quickTabSwitcherShowTitles,
      onChanged: switcherEnabled
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

class _QuickTabSwitcherHierarchyGlyphsTile extends HookConsumerWidget {
  const _QuickTabSwitcherHierarchyGlyphsTile();

  static String _label(AppLocalizations l10n, int glyphs) =>
      l10n.settings_hierarchyGlyphsLabel(glyphs);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final hierarchyGlyphs = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.quickTabSwitcherHierarchyGlyphs,
      ),
    );
    final switcherEnabled = ref.watch(
      effectiveTabBarStackingModeProvider.select(
        (mode) => mode != TabBarStackingMode.disabled,
      ),
    );

    final sliderValue = useKeyedState(hierarchyGlyphs.toDouble(), [
      hierarchyGlyphs,
    ]);

    final currentGlyphs = sliderValue.value.round();
    final enabled = switcherEnabled;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(l10n.settings_hierarchyDepthTitle),
            subtitle: Text(l10n.settings_hierarchyDepthSubtitle),
            leading: const Icon(MdiIcons.fileTree),
            contentPadding: EdgeInsets.zero,
            enabled: enabled,
          ),
          Row(
            children: [
              Expanded(
                child: Slider(
                  min: minQuickTabSwitcherHierarchyGlyphs.toDouble(),
                  max: maxQuickTabSwitcherHierarchyGlyphs.toDouble(),
                  divisions:
                      maxQuickTabSwitcherHierarchyGlyphs -
                      minQuickTabSwitcherHierarchyGlyphs,
                  label: _label(l10n, currentGlyphs),
                  value: sliderValue.value.clamp(
                    minQuickTabSwitcherHierarchyGlyphs.toDouble(),
                    maxQuickTabSwitcherHierarchyGlyphs.toDouble(),
                  ),
                  onChanged: enabled
                      ? (value) {
                          sliderValue.value = value;
                        }
                      : null,
                  onChangeEnd: enabled
                      ? (value) async {
                          final normalized = value.round();
                          sliderValue.value = normalized.toDouble();
                          await ref
                              .read(
                                saveGeneralSettingsControllerProvider.notifier,
                              )
                              .save(
                                (currentSettings) => currentSettings.copyWith
                                    .quickTabSwitcherHierarchyGlyphs(
                                      normalized,
                                    ),
                              );
                        }
                      : null,
                ),
              ),
              Text(
                _label(l10n, currentGlyphs),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
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
    final l10n = AppLocalizations.of(context);
    final autoHideTabBar = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.autoHideTabBar),
    );

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_autoHideTabBarTitle),
      subtitle: Text(l10n.settings_autoHideTabBarSubtitle),
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

class _SideRailAutoHideTile extends HookConsumerWidget {
  const _SideRailAutoHideTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sideRailAutoHide = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.sideRailAutoHide),
    );

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_autoHideSidePanelTitle),
      subtitle: Text(l10n.settings_autoHideSidePanelSubtitle),
      secondary: const Icon(MdiIcons.dockLeft),
      value: sideRailAutoHide,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.sideRailAutoHide(value),
            );
      },
    );
  }
}

class _BottomSheetTabViewTile extends HookConsumerWidget {
  const _BottomSheetTabViewTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tabViewBottomSheet = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.tabViewBottomSheet),
    );

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_bottomSheetTabViewTitle),
      subtitle: Text(l10n.settings_bottomSheetTabViewSubtitle),
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

class _TabBarLongPressUrlCopyTile extends HookConsumerWidget {
  const _TabBarLongPressUrlCopyTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tabBarLongPressUrlCopy = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.tabBarLongPressUrlCopy,
      ),
    );

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_longPressUrlCopyTitle),
      subtitle: Text(l10n.settings_longPressUrlCopySubtitle),
      secondary: const Icon(MdiIcons.contentCopy),
      value: tabBarLongPressUrlCopy,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.tabBarLongPressUrlCopy(value),
            );
      },
    );
  }
}

class _TabListShowFaviconsTile extends HookConsumerWidget {
  const _TabListShowFaviconsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tabListShowFavicons = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.tabListShowFavicons),
    );

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_showFaviconsTitle),
      subtitle: Text(l10n.settings_showFaviconsSubtitle),
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
