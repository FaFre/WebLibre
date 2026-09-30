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
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/app_links/domain/entities/app_link_rule.dart';
import 'package:weblibre/features/app_links/domain/entities/context_app_link_policy.dart';
import 'package:weblibre/features/app_links/presentation/widgets/container_app_link_settings_dialog.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/child_tab_placement.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

List<SettingsSectionDefinition> browsingSettingsSections(BuildContext context) {
  final l10n = AppLocalizations.of(context);

  return [
    SettingsSectionDefinition(
      title: l10n.settings_tabsSectionTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_newTabDefaultTitle,
          subtitle: l10n.settings_newTabDefaultSubtitle,
          keywords: settingsKeywords(l10n.settings_newTabDefaultKeywords),
          child: const _NewTabDefaultSection(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_smallWebTabDefaultTitle,
          subtitle: l10n.settings_smallWebTabDefaultSubtitle,
          keywords: settingsKeywords(l10n.settings_smallWebTabDefaultKeywords),
          child: const _SmallWebTabDefaultSection(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_tabListDirectionTitle,
          subtitle: l10n.settings_indexTabListDirectionSubtitle,
          keywords: settingsKeywords(l10n.settings_tabListDirectionKeywords),
          child: const _TabListDirectionSection(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_tabBarDirectionTitle,
          subtitle: l10n.settings_indexTabBarDirectionSubtitle,
          keywords: settingsKeywords(l10n.settings_tabBarDirectionKeywords),
          child: const _TabBarDirectionSection(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_childTabPlacementTitle,
          subtitle: l10n.settings_indexChildTabPlacementSubtitle,
          keywords: settingsKeywords(l10n.settings_childTabPlacementKeywords),
          child: const _ChildTabPlacementSection(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_showContainerUiTitle,
          subtitle: l10n.settings_showContainerUiSubtitle,
          keywords: settingsKeywords(l10n.settings_showContainerUiKeywords),
          child: const _ShowContainerUiTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_showIsolatedTabUiTitle,
          subtitle: l10n.settings_showIsolatedTabUiSubtitle,
          keywords: settingsKeywords(l10n.settings_showIsolatedTabUiKeywords),
          child: const _ShowIsolatedTabUiTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_createChildTabsTitle,
          subtitle: l10n.settings_indexCreateChildTabsSubtitle,
          keywords: settingsKeywords(l10n.settings_createChildTabsKeywords),
          child: const _CreateChildTabsTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_backgroundTabBehaviorTitle,
          subtitle: l10n.settings_indexBackgroundTabBehaviorSubtitle,
          keywords: settingsKeywords(
            l10n.settings_backgroundTabBehaviorKeywords,
          ),
          child: const _BackgroundTabOpenSection(),
        ),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.settings_navigationSectionTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_pullToRefreshTitle,
          subtitle: l10n.settings_pullToRefreshSubtitle,
          keywords: settingsKeywords(l10n.settings_pullToRefreshKeywords),
          child: const _PullToRefreshTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_doubleBackCloseTabTitle,
          subtitle: l10n.settings_indexDoubleBackCloseTabSubtitle,
          keywords: settingsKeywords(l10n.settings_doubleBackCloseTabKeywords),
          child: const _DoubleBackCloseTabTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_tabBarSwipesTitle,
          subtitle: l10n.settings_indexTabBarSwipesSubtitle,
          keywords: settingsKeywords(l10n.settings_tabBarSwipesKeywords),
          child: const _TabBarSwipesLinkTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_sequentialTabNavigationTitle,
          subtitle: l10n.settings_indexSequentialTabNavigationSubtitle,
          keywords: settingsKeywords(
            l10n.settings_sequentialTabNavigationKeywords,
          ),
          child: const _SequentialTabNavigationSection(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_openLinksInAppsTitle,
          subtitle: l10n.settings_indexOpenLinksInAppsSubtitle,
          keywords: settingsKeywords(l10n.settings_openLinksInAppsKeywords),
          child: const _AppLinksModeSection(),
        ),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.settings_desktopModeSectionTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_globalDesktopModeTitle,
          subtitle: l10n.settings_indexGlobalDesktopModeSubtitle,
          keywords: settingsKeywords(l10n.settings_globalDesktopModeKeywords),
          child: const _GlobalDesktopModeTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_desktopModeSitesTitle,
          subtitle: l10n.settings_desktopModeSitesSubtitle,
          keywords: settingsKeywords(l10n.settings_desktopModeSitesKeywords),
          child: const _DesktopModeSitesTile(),
        ),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.settings_homeScreenSectionTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_allowNonManifestPwaInstallTitle,
          subtitle: l10n.settings_indexAllowNonManifestPwaInstallSubtitle,
          keywords: settingsKeywords(
            l10n.settings_allowNonManifestPwaInstallKeywords,
          ),
          child: const _AllowNonManifestPwaInstallTile(),
        ),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.settings_externalLinksSectionTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_externalLinkHandlingTitle,
          subtitle: l10n.settings_externalLinkHandlingSubtitle,
          keywords: settingsKeywords(
            l10n.settings_externalLinkHandlingKeywords,
          ),
          child: const _ExternalLinkHandlingSection(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_customTabsTitle,
          subtitle: l10n.settings_indexCustomTabsSubtitle,
          keywords: settingsKeywords(l10n.settings_customTabsKeywords),
          child: const _CustomTabsTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_urlCleanerTitle,
          subtitle: l10n.settings_urlCleanerSubtitle,
          keywords: settingsKeywords(l10n.settings_urlCleanerKeywords),
          child: const _UrlCleanerSettingsTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.settings_unshortenerTitle,
          subtitle: l10n.settings_unshortenerSubtitle,
          keywords: settingsKeywords(l10n.settings_unshortenerKeywords),
          child: const _UnshortenerSettingsTile(),
        ),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.settings_bookmarksSectionTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_bookmarkOpenBehaviorTitle,
          subtitle: l10n.settings_bookmarkOpenBehaviorSubtitle,
          keywords: settingsKeywords(
            l10n.settings_bookmarkOpenBehaviorKeywords,
          ),
          child: const _BookmarkOpenBehaviorSection(),
        ),
      ],
    ),
  ];
}

class BrowsingSettingsScreen extends StatelessWidget {
  const BrowsingSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SettingsDetailScaffold(
      title: l10n.settings_browsingTitle,
      subtitle: l10n.settings_browsingSubtitle,
      icon: MdiIcons.compassOutline,
      sections: browsingSettingsSections(context),
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
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(l10n.settings_newTabDefaultTitle),
            subtitle: Text(l10n.settings_newTabDefaultSubtitle),
            leading: const Icon(MdiIcons.tab),
            contentPadding: EdgeInsets.zero,
          ),
          Center(
            child: SegmentedButton(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: TabType.regular,
                  label: Text(l10n.settings_tabTypeRegularLabel),
                  icon: const Icon(MdiIcons.tab),
                ),
                ButtonSegment(
                  value: TabType.private,
                  label: Text(l10n.settings_tabTypePrivateLabel),
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
                    label: Text(l10n.settings_tabTypeIsolatedLabel),
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
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(l10n.settings_smallWebTabDefaultTitle),
            subtitle: Text(l10n.settings_smallWebTabDefaultSubtitle),
            leading: const Icon(Icons.explore),
            contentPadding: EdgeInsets.zero,
          ),
          Center(
            child: SegmentedButton(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: TabType.regular,
                  label: Text(l10n.settings_tabTypeRegularLabel),
                  icon: const Icon(MdiIcons.tab),
                ),
                ButtonSegment(
                  value: TabType.private,
                  label: Text(l10n.settings_tabTypePrivateLabel),
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
                    label: Text(l10n.settings_tabTypeIsolatedLabel),
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
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(l10n.settings_externalLinkHandlingTitle),
            subtitle: Text(l10n.settings_externalLinkHandlingSubtitle),
            leading: const Icon(MdiIcons.tabPlus),
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
                RadioListTile.adaptive(
                  value: TabIntentOpenSetting.ask,
                  title: Text(l10n.settings_promptOptionLabel),
                  subtitle: Text(l10n.settings_externalLinkPromptSubtitle),
                  secondary: const Icon(MdiIcons.messageQuestion),
                ),
                RadioListTile.adaptive(
                  value: TabIntentOpenSetting.regular,
                  title: Text(l10n.settings_tabTypeRegularLabel),
                  subtitle: Text(l10n.settings_externalLinkRegularSubtitle),
                  secondary: const Icon(MdiIcons.tab),
                ),
                RadioListTile.adaptive(
                  value: TabIntentOpenSetting.private,
                  title: Text(l10n.settings_tabTypePrivateLabel),
                  subtitle: Text(l10n.settings_externalLinkPrivateSubtitle),
                  secondary: Icon(
                    MdiIcons.dominoMask,
                    color: AppColors.of(context).privateTabPurple,
                  ),
                ),
                if (settings.showIsolatedTabUi)
                  RadioListTile.adaptive(
                    value: TabIntentOpenSetting.isolated,
                    title: Text(l10n.settings_tabTypeIsolatedLabel),
                    subtitle: Text(l10n.settings_externalLinkIsolatedSubtitle),
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

class _BookmarkOpenBehaviorSection extends HookConsumerWidget {
  const _BookmarkOpenBehaviorSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(generalSettingsWithDefaultsProvider);
    final bookmarkOpenSetting = settings.effectiveBookmarkOpenSetting;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(l10n.settings_bookmarkOpenBehaviorTitle),
            subtitle: Text(l10n.settings_bookmarkOpenBehaviorSubtitle),
            leading: const Icon(MdiIcons.bookmarkMultiple),
            contentPadding: EdgeInsets.zero,
          ),
          RadioGroup(
            groupValue: bookmarkOpenSetting,
            onChanged: (value) async {
              if (value != null) {
                await ref
                    .read(saveGeneralSettingsControllerProvider.notifier)
                    .save(
                      (currentSettings) =>
                          currentSettings.copyWith.bookmarkOpenSetting(value),
                    );
              }
            },
            child: Column(
              children: [
                RadioListTile.adaptive(
                  value: BookmarkOpenSetting.ask,
                  title: Text(l10n.settings_promptOptionLabel),
                  subtitle: Text(l10n.settings_bookmarkOpenPromptSubtitle),
                  secondary: const Icon(MdiIcons.messageQuestion),
                ),
                RadioListTile.adaptive(
                  value: BookmarkOpenSetting.regular,
                  title: Text(l10n.settings_tabTypeRegularLabel),
                  subtitle: Text(l10n.settings_bookmarkOpenRegularSubtitle),
                  secondary: const Icon(MdiIcons.tab),
                ),
                RadioListTile.adaptive(
                  value: BookmarkOpenSetting.private,
                  title: Text(l10n.settings_tabTypePrivateLabel),
                  subtitle: Text(l10n.settings_bookmarkOpenPrivateSubtitle),
                  secondary: Icon(
                    MdiIcons.dominoMask,
                    color: AppColors.of(context).privateTabPurple,
                  ),
                ),
                RadioListTile.adaptive(
                  value: BookmarkOpenSetting.customTab,
                  title: Text(l10n.settings_customTabOptionLabel),
                  subtitle: Text(l10n.settings_bookmarkOpenCustomTabSubtitle),
                  secondary: const Icon(MdiIcons.applicationOutline),
                ),
                if (settings.showIsolatedTabUi)
                  RadioListTile.adaptive(
                    value: BookmarkOpenSetting.isolated,
                    title: Text(l10n.settings_tabTypeIsolatedLabel),
                    subtitle: Text(l10n.settings_bookmarkOpenIsolatedSubtitle),
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
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(l10n.settings_tabListDirectionTitle),
            subtitle: Text(l10n.settings_tabListDirectionSubtitle),
            leading: const Icon(MdiIcons.formatListBulleted),
            contentPadding: EdgeInsets.zero,
          ),
          Center(
            child: SegmentedButton(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: TabDirection.newestFirst,
                  label: Text(l10n.settings_directionNewestFirstLabel),
                  icon: const Icon(MdiIcons.arrowCollapseUp),
                ),
                ButtonSegment(
                  value: TabDirection.oldestFirst,
                  label: Text(l10n.settings_directionOldestFirstLabel),
                  icon: const Icon(MdiIcons.arrowCollapseDown),
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
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(l10n.settings_tabBarDirectionTitle),
            subtitle: Text(l10n.settings_tabBarDirectionSubtitle),
            leading: const Icon(MdiIcons.reorderHorizontal),
            contentPadding: EdgeInsets.zero,
          ),
          Center(
            child: SegmentedButton(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: TabDirection.newestFirst,
                  label: Text(l10n.settings_directionNewestFirstLabel),
                  icon: const Icon(MdiIcons.arrowCollapseLeft),
                ),
                ButtonSegment(
                  value: TabDirection.oldestFirst,
                  label: Text(l10n.settings_directionOldestFirstLabel),
                  icon: const Icon(MdiIcons.arrowCollapseRight),
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

class _ChildTabPlacementSection extends HookConsumerWidget {
  const _ChildTabPlacementSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placement = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.childTabPlacement),
    );
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(l10n.settings_childTabPlacementTitle),
            subtitle: Text(l10n.settings_childTabPlacementSubtitle),
            leading: const Icon(MdiIcons.fileTreeOutline),
            contentPadding: EdgeInsets.zero,
          ),
          Center(
            child: SegmentedButton(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: ChildTabPlacement.afterParent,
                  label: Text(l10n.settings_childTabAfterOpenerLabel),
                  icon: const Icon(MdiIcons.arrowRightBottom),
                ),
                ButtonSegment(
                  value: ChildTabPlacement.endOfList,
                  label: Text(l10n.settings_childTabAtEndLabel),
                  icon: const Icon(MdiIcons.arrowCollapseDown),
                ),
              ],
              selected: {placement},
              onSelectionChanged: (value) async {
                await ref
                    .read(saveGeneralSettingsControllerProvider.notifier)
                    .save(
                      (currentSettings) => currentSettings.copyWith
                          .childTabPlacement(value.first),
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
    final l10n = AppLocalizations.of(context);

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_createChildTabsTitle),
      subtitle: Text(l10n.settings_createChildTabsSubtitle),
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
    final l10n = AppLocalizations.of(context);

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_showContainerUiTitle),
      subtitle: Text(l10n.settings_showContainerUiSubtitle),
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
                TabBarStackingMode.tabGroups,
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
    final l10n = AppLocalizations.of(context);

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_showIsolatedTabUiTitle),
      subtitle: Text(l10n.settings_showIsolatedTabUiSubtitle),
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
          if (!value &&
              updated.bookmarkOpenSetting == BookmarkOpenSetting.isolated) {
            updated = updated.copyWith.bookmarkOpenSetting(
              BookmarkOpenSetting.ask,
            );
          }
          return updated;
        });
      },
    );
  }
}

class _BackgroundTabOpenSection extends HookConsumerWidget {
  const _BackgroundTabOpenSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final backgroundTabOpenAction = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.backgroundTabOpenAction,
      ),
    );
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(l10n.settings_backgroundTabBehaviorTitle),
            subtitle: Text(l10n.settings_backgroundTabBehaviorSubtitle),
            leading: const Icon(MdiIcons.tabPlus),
            contentPadding: EdgeInsets.zero,
          ),
          RadioGroup(
            groupValue: backgroundTabOpenAction,
            onChanged: (value) async {
              if (value != null) {
                await ref
                    .read(saveGeneralSettingsControllerProvider.notifier)
                    .save(
                      (currentSettings) => currentSettings.copyWith
                          .backgroundTabOpenAction(value),
                    );
              }
            },
            child: Column(
              children: [
                RadioListTile.adaptive(
                  value: BackgroundTabOpenAction.prompt,
                  title: Text(l10n.settings_backgroundTabPromptTitle),
                  subtitle: Text(l10n.settings_backgroundTabPromptSubtitle),
                ),
                RadioListTile.adaptive(
                  value: BackgroundTabOpenAction.switchImmediately,
                  title: Text(l10n.settings_backgroundTabSwitchTitle),
                  subtitle: Text(l10n.settings_backgroundTabSwitchSubtitle),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tab bar swipes are configured with every other gesture, one binding per
/// direction; this entry only points there so the old place still finds them.
class _TabBarSwipesLinkTile extends StatelessWidget {
  const _TabBarSwipesLinkTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      leading: const Icon(MdiIcons.gestureSwipeHorizontal),
      title: Text(l10n.settings_tabBarSwipesTitle),
      subtitle: Text(l10n.settings_tabBarSwipesSubtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => GestureSettingsRoute().push(context),
    );
  }
}

class _SequentialTabNavigationSection extends HookConsumerWidget {
  const _SequentialTabNavigationSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final crossContainers = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.sequentialTabNavigationCrossContainers,
      ),
    );
    final loop = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.sequentialTabNavigationLoop,
      ),
    );
    final showContainerUi = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.showContainerUi),
    );
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(l10n.settings_sequentialTabNavigationTitle),
            subtitle: Text(l10n.settings_sequentialTabNavigationSubtitle),
            leading: const Icon(MdiIcons.swapHorizontal),
            contentPadding: EdgeInsets.zero,
          ),
          if (showContainerUi)
            SwitchListTile.adaptive(
              title: Text(l10n.settings_continueIntoNextContainerTitle),
              subtitle: Text(l10n.settings_continueIntoNextContainerSubtitle),
              secondary: const Icon(MdiIcons.folderMultipleOutline),
              contentPadding: EdgeInsets.zero,
              value: crossContainers,
              onChanged: (value) async {
                await ref
                    .read(saveGeneralSettingsControllerProvider.notifier)
                    .save(
                      (currentSettings) => currentSettings.copyWith
                          .sequentialTabNavigationCrossContainers(value),
                    );
              },
            ),
          SwitchListTile.adaptive(
            title: Text(l10n.settings_loopAroundTitle),
            subtitle: Text(l10n.settings_loopAroundSubtitle),
            secondary: const Icon(MdiIcons.repeat),
            contentPadding: EdgeInsets.zero,
            value: loop,
            onChanged: (value) async {
              await ref
                  .read(saveGeneralSettingsControllerProvider.notifier)
                  .save(
                    (currentSettings) => currentSettings.copyWith
                        .sequentialTabNavigationLoop(value),
                  );
            },
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
      generalSettingsWithDefaultsProvider.select((s) => s.appLinksMode),
    );
    final marketplaceFallback = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.appLinkMarketplaceFallback,
      ),
    );
    final authExceptionsEnabled = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.appLinkAuthExceptionsEnabled,
      ),
    );
    final blockWhilePrompting = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.appLinkBlockWhilePrompting,
      ),
    );
    final rules = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.appLinkRules),
    );
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(l10n.settings_openLinksInAppsTitle),
            subtitle: Text(l10n.settings_openLinksInAppsSubtitle),
            leading: const Icon(MdiIcons.openInApp),
            contentPadding: EdgeInsets.zero,
          ),
          RadioGroup(
            groupValue: appLinksMode,
            onChanged: (value) async {
              if (value != null) {
                await ref
                    .read(saveGeneralSettingsControllerProvider.notifier)
                    .save((current) => current.copyWith.appLinksMode(value));
              }
            },
            child: Column(
              children: [
                RadioListTile.adaptive(
                  value: AppLinksMode.always,
                  title: Text(l10n.settings_appLinksAlwaysTitle),
                  subtitle: Text(l10n.settings_appLinksAlwaysSubtitle),
                ),
                RadioListTile.adaptive(
                  value: AppLinksMode.ask,
                  title: Text(l10n.settings_appLinksAskTitle),
                  subtitle: Text(l10n.settings_appLinksAskSubtitle),
                ),
                RadioListTile.adaptive(
                  value: AppLinksMode.never,
                  title: Text(l10n.settings_appLinksNeverTitle),
                  subtitle: Text(l10n.settings_appLinksNeverSubtitle),
                ),
              ],
            ),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.settings_waitForAnswerTitle),
            subtitle: Text(l10n.settings_waitForAnswerSubtitle),
            value: blockWhilePrompting,
            // Deliberately never disabled on the global mode. Prompts are not the
            // global mode's alone to grant: a protected container, a private tab
            // and a wallet scheme all prompt regardless of it, and a container
            // with isolated app-link settings can sit on `ask` while the global
            // mode is `never`. Greying this out under those modes would leave
            // blocking switched on with no way to switch it off.
            onChanged: (value) async {
              await ref
                  .read(saveGeneralSettingsControllerProvider.notifier)
                  .save(
                    (current) =>
                        current.copyWith.appLinkBlockWhilePrompting(value),
                  );
            },
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.settings_offerAppStoreFallbackTitle),
            subtitle: Text(l10n.settings_offerAppStoreFallbackSubtitle),
            value: marketplaceFallback,
            onChanged: appLinksMode == AppLinksMode.never
                ? null
                : (value) async {
                    await ref
                        .read(saveGeneralSettingsControllerProvider.notifier)
                        .save(
                          (current) => current.copyWith
                              .appLinkMarketplaceFallback(value),
                        );
                  },
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.settings_allowLoginAppCallbacksTitle),
            subtitle: Text(l10n.settings_allowLoginAppCallbacksSubtitle),
            value: authExceptionsEnabled,
            onChanged: (value) async {
              await ref
                  .read(saveGeneralSettingsControllerProvider.notifier)
                  .save(
                    (current) =>
                        current.copyWith.appLinkAuthExceptionsEnabled(value),
                  );
            },
          ),
          _AppLinkRulesSubsection(rules: rules),
          const _ContainerAppLinkOverridesSubsection(),
        ],
      ),
    );
  }
}

/// Containers running their own app-link policy (§ container isolation).
///
/// Their settings fully replace everything above for their tabs, and until now
/// the only way to reach one was through that container's own edit dialog — so a
/// container quietly set to "always" was invisible from the screen that claims to
/// govern app links. Listing them here says which containers are not covered by
/// the settings above, and opens the same editor.
class _ContainerAppLinkOverridesSubsection extends ConsumerWidget {
  const _ContainerAppLinkOverridesSubsection();

  static String _containerLabel(
    ContainerDataWithCount container,
    AppLocalizations l10n,
  ) => container.name ?? l10n.settings_appLinkContainerFallbackName;

  String _modeLabel(AppLinksMode mode, AppLocalizations l10n) => switch (mode) {
    AppLinksMode.always => l10n.settings_appLinkOverrideModeAlways,
    AppLinksMode.ask => l10n.settings_appLinkOverrideModeAsk,
    AppLinksMode.never => l10n.settings_appLinkOverrideModeNever,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final containers =
        ref.watch(watchContainersWithCountProvider).value ?? const [];
    final overrides = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.appLinkContextOverrides,
      ),
    );

    final isolated =
        containers
            .where(
              (container) =>
                  container.metadata.isolatedAppLinkSettings &&
                  container.metadata.contextualIdentity != null,
            )
            .toList()
          ..sort(
            (a, b) =>
                _containerLabel(a, l10n).compareTo(_containerLabel(b, l10n)),
          );

    if (isolated.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 4),
          child: Text(l10n.settings_appLinkContainerOverridesHeader),
        ),
        for (final container in isolated)
          Builder(
            builder: (context) {
              final contextId = container.metadata.contextualIdentity!;
              final policy =
                  overrides[contextId] ?? ContextAppLinkPolicy.blank();
              final ruleCount = policy.rules.length;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: const Icon(MdiIcons.circleOutline),
                title: Text(_containerLabel(container, l10n)),
                subtitle: Text(
                  ruleCount == 0
                      ? _modeLabel(policy.mode, l10n)
                      : l10n.settings_appLinkOverrideSummaryWithRules(
                          _modeLabel(policy.mode, l10n),
                          ruleCount,
                        ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => unawaited(
                  showDialog<void>(
                    context: context,
                    builder: (_) => ContainerAppLinkSettingsDialog(
                      contextId: contextId,
                      containerName: container.name,
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

/// Managed per-site app-link rules (§2.5): "always open" and "never open"
/// decisions the user remembered from a prompt. Read-only list with removal.
class _AppLinkRulesSubsection extends ConsumerWidget {
  final Map<String, PersistedAppLinkRule> rules;

  const _AppLinkRulesSubsection({required this.rules});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (rules.isEmpty) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    final entries = rules.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 4),
          child: Text(l10n.settings_appLinkRememberedRulesHeader),
        ),
        for (final MapEntry(:key, :value) in entries)
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: Icon(
              value.decision == AppLinkRuleDecision.alwaysOpen
                  ? MdiIcons.openInApp
                  : Icons.public,
            ),
            title: Text(displayAppLinkScope(key)),
            subtitle: Text(
              value.decision == AppLinkRuleDecision.alwaysOpen
                  ? l10n.settings_appLinkRuleAlwaysOpenLabel
                  : l10n.settings_appLinkRuleAlwaysKeepLabel,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: l10n.settings_appLinkRuleRemoveTooltip,
              onPressed: () async {
                await ref
                    .read(saveGeneralSettingsControllerProvider.notifier)
                    .save(
                      (current) => current.copyWith.appLinkRules(
                        {...current.appLinkRules}..remove(key),
                      ),
                    );
              },
            ),
          ),
      ],
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
    final l10n = AppLocalizations.of(context);

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_globalDesktopModeTitle),
      subtitle: Text(l10n.settings_globalDesktopModeSubtitle),
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
    final l10n = AppLocalizations.of(context);

    return ListTile(
      leading: const Icon(Icons.desktop_windows),
      title: Text(l10n.settings_desktopModeSitesTitle),
      subtitle: Text(l10n.settings_desktopModeSitesSubtitle),
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
    final l10n = AppLocalizations.of(context);

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_pullToRefreshTitle),
      subtitle: Text(l10n.settings_pullToRefreshSubtitle),
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

class _CustomTabsTile extends HookConsumerWidget {
  const _CustomTabsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customTabsEnabled = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.customTabsEnabled),
    );
    final l10n = AppLocalizations.of(context);

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_customTabsTitle),
      subtitle: Text(l10n.settings_customTabsSubtitle),
      secondary: const Icon(Icons.web_asset),
      value: customTabsEnabled,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save(
              (currentSettings) =>
                  currentSettings.copyWith.customTabsEnabled(value),
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
    final l10n = AppLocalizations.of(context);

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_doubleBackCloseTabTitle),
      subtitle: Text(l10n.settings_doubleBackCloseTabSubtitle),
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
    final l10n = AppLocalizations.of(context);

    return SwitchListTile.adaptive(
      title: Text(l10n.settings_allowNonManifestPwaInstallTitle),
      subtitle: Text(l10n.settings_allowNonManifestPwaInstallSubtitle),
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
    final l10n = AppLocalizations.of(context);

    return ListTile(
      leading: const Icon(MdiIcons.broom),
      title: Text(l10n.settings_urlCleanerTitle),
      subtitle: Text(l10n.settings_urlCleanerSubtitle),
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
    final l10n = AppLocalizations.of(context);

    return ListTile(
      leading: const Icon(MdiIcons.linkVariant),
      title: Text(l10n.settings_unshortenerTitle),
      subtitle: Text(l10n.settings_unshortenerSubtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await UnshortenerSettingsRoute().push(context);
      },
    );
  }
}
