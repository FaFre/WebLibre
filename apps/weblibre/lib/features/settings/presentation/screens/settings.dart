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
import 'package:weblibre/core/branding/proxy_brands.dart';
import 'package:weblibre/core/design/window_size_class.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/presentation/screens/url_cleaner_settings.dart';
import 'package:weblibre/features/gestures/presentation/screens/gesture_behavior_screen.dart';
import 'package:weblibre/features/gestures/presentation/screens/gesture_feedback_screen.dart';
import 'package:weblibre/features/proxy/presentation/screens/proxy_routing_settings.dart';
import 'package:weblibre/features/settings/domain/providers/pending_settings_highlight.dart';
import 'package:weblibre/features/settings/presentation/screens/advanced_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/browsing_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/custom_tracking_protection.dart';
import 'package:weblibre/features/settings/presentation/screens/experimental_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/extensions_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/feature_control_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/fingerprint_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/general_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/home_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/privacy_security_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/proxy_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/search_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/web_content_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/settings/presentation/widgets/toolbar_layout_content.dart';
import 'package:weblibre/features/sync/presentation/screens/sync_settings.dart';
import 'package:weblibre/features/tor/presentation/screens/tor_proxy.dart';
import 'package:weblibre/features/web_push/presentation/screens/web_push_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/utils/list_format_l10n.dart';
import 'package:weblibre/presentation/utils/visibility_switch_l10n.dart';
import 'package:weblibre/presentation/widgets/hidden_feature_gate.dart';

class SettingsScreen extends HookWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final search = useSettingsSearch();

    final categories = _buildCategories(context);
    final sections = search.normalizedQuery.isEmpty
        ? _buildCategorySections(context, categories)
        : _buildSearchSections([
            ...categories.browser,
            ...categories.services,
          ], search.normalizedQuery);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final inset = centeringInset(
              constraints.maxWidth,
              maxWidth: ContentWidth.list,
            );

            return FadingScroll(
              fadingSize: 25,
              builder: (context, controller) {
                return CustomScrollView(
                  controller: controller,
                  slivers: [
                    SliverAppBar.large(
                      centerTitle: false,
                      title: Text(l10n.settings_settingsHomeTitle),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        16 + inset,
                        8,
                        16 + inset,
                        0,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: SettingsSearchField(
                          controller: search.controller,
                          hintText: l10n.settings_settingsHomeSearchHint,
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        16 + inset,
                        24,
                        16 + inset,
                        20,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: SettingsSectionList(
                          sections: sections,
                          query: search.rawQuery,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

typedef _CategoryGroups = ({
  List<_SettingsCategoryDefinition> browser,
  List<_SettingsCategoryDefinition> services,
});

_CategoryGroups _buildCategories(BuildContext context) {
  final l10n = AppLocalizations.of(context);

  final browser = [
    _SettingsCategoryDefinition(
      title: l10n.settings_categoryGeneralTitle,
      subtitle: l10n.settings_categoryGeneralSubtitle,
      icon: Icons.tune,
      keywords: settingsKeywords(l10n.settings_categoryGeneralKeywords),
      sections: generalSettingsSections(context),
      onTap: (context) => GeneralSettingsRoute().push(context),
    ),
    _SettingsCategoryDefinition(
      title: l10n.settings_categoryFeatureControlTitle,
      subtitle: l10n.settings_categoryFeatureControlSubtitle,
      icon: Icons.visibility_outlined,
      keywords: settingsKeywords(l10n.settings_categoryFeatureControlKeywords),
      sections: featureControlSettingsSections(context),
      onTap: (context) => const FeatureControlSettingsRoute().push(context),
    ),
    _SettingsCategoryDefinition(
      title: l10n.settings_categoryBrowsingTitle,
      subtitle: l10n.settings_categoryBrowsingSubtitle,
      icon: MdiIcons.compassOutline,
      keywords: settingsKeywords(l10n.settings_categoryBrowsingKeywords),
      sections: browsingSettingsSections(context),
      onTap: (context) => BrowsingSettingsRoute().push(context),
      subscreens: [
        _SettingsSubscreen(
          title: l10n.settings_urlCleanerTitle,
          sections: urlCleanerSettingsSections(context),
          open: (context) => UrlCleanerSettingsRoute().push(context),
        ),
      ],
    ),
    _SettingsCategoryDefinition(
      title: l10n.settings_categoryHomeNewTabTitle,
      subtitle: l10n.settings_categoryHomeNewTabSubtitle,
      icon: MdiIcons.homeOutline,
      keywords: settingsKeywords(l10n.settings_categoryHomeNewTabKeywords),
      sections: homeSettingsSections(context),
      onTap: (context) => const HomeSettingsRoute().push(context),
    ),
    _SettingsCategoryDefinition(
      title: l10n.settings_categoryGesturesTitle,
      feature: FeatureId.inputDrawnGestures,
      subtitle: l10n.settings_categoryGesturesSubtitle,
      icon: MdiIcons.gestureSwipe,
      keywords: settingsKeywords(l10n.settings_categoryGesturesKeywords),
      onTap: (context) => GestureSettingsRoute().push(context),
      subscreens: [
        _SettingsSubscreen(
          title: l10n.gestures_behaviorTimingTitle,
          sections: gestureBehaviorSections(context),
          open: (context) => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const GestureBehaviorScreen(),
            ),
          ),
          feature: FeatureId.inputDrawnGestures,
        ),
        _SettingsSubscreen(
          title: l10n.gestures_feedbackTitle,
          sections: gestureFeedbackSections(context),
          open: (context) => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const GestureFeedbackScreen(),
            ),
          ),
          feature: FeatureId.inputDrawnGestures,
        ),
      ],
    ),
    _SettingsCategoryDefinition(
      title: l10n.settings_categoryKeyboardShortcutsTitle,
      subtitle: l10n.settings_categoryKeyboardShortcutsSubtitle,
      icon: MdiIcons.keyboardOutline,
      keywords: settingsKeywords(
        l10n.settings_categoryKeyboardShortcutsKeywords,
      ),
      onTap: (context) => const KeyboardShortcutSettingsRoute().push(context),
    ),
    _SettingsCategoryDefinition(
      title: l10n.settings_categoryToolbarLayoutTitle,
      subtitle: l10n.settings_categoryToolbarLayoutSubtitle,
      icon: MdiIcons.viewDashboardOutline,
      keywords: settingsKeywords(l10n.settings_categoryToolbarLayoutKeywords),
      sections: [
        ...toolbarLayoutSettingsSections(context),
        ...menuLayoutSettingsSections(context),
      ],
      onTap: (context) => ToolbarLayoutSettingsRoute().push(context),
    ),
    _SettingsCategoryDefinition(
      title: l10n.settings_categoryWebContentTitle,
      subtitle: l10n.settings_categoryWebContentSubtitle,
      icon: MdiIcons.fileDocumentOutline,
      keywords: settingsKeywords(l10n.settings_categoryWebContentKeywords),
      sections: webContentSettingsSections(context),
      onTap: (context) => WebContentSettingsRoute().push(context),
    ),
    _SettingsCategoryDefinition(
      title: l10n.settings_categoryNotificationsTitle,
      subtitle: l10n.settings_categoryNotificationsSubtitle,
      icon: MdiIcons.bellBadgeOutline,
      keywords: settingsKeywords(l10n.settings_categoryNotificationsKeywords),
      sections: webPushSettingsSections(context),
      onTap: (context) => WebPushSettingsRoute().push(context),
    ),
    _SettingsCategoryDefinition(
      title: l10n.settings_categorySearchTitle,
      subtitle: l10n.settings_categorySearchSubtitle,
      icon: MdiIcons.magnify,
      keywords: settingsKeywords(l10n.settings_categorySearchKeywords),
      sections: searchSettingsSections(context),
      onTap: (context) => SearchSettingsRoute().push(context),
    ),
    _SettingsCategoryDefinition(
      title: l10n.settings_categoryPrivacySecurityTitle,
      subtitle: l10n.settings_categoryPrivacySecuritySubtitle,
      icon: MdiIcons.shieldLock,
      keywords: settingsKeywords(l10n.settings_categoryPrivacySecurityKeywords),
      sections: privacySecuritySettingsSections(context),
      onTap: (context) => PrivacySecuritySettingsRoute().push(context),
      subscreens: [
        _SettingsSubscreen(
          title: l10n.settings_fingerprintProtectionTitle,
          sections: fingerprintSettingsSearchSections(context),
          open: (context) => FingerprintSettingsRoute().push(context),
        ),
        _SettingsSubscreen(
          title: l10n.settings_customTrackingProtectionTitle,
          sections: customTrackingProtectionSections(context),
          open: (context) => CustomTrackingProtectionRoute().push(context),
          // The whole editor is Expert.
          feature: FeatureId.privacyEtpCustomPolicies,
        ),
      ],
    ),
    _SettingsCategoryDefinition(
      title: l10n.settings_categoryProxyTitle,
      feature: FeatureId.connectionsImportVpnProxy,
      keptWhen: KeptWhen.connectionsInUse,
      subtitle: l10n.settings_categoryProxySubtitle,
      icon: MdiIcons.lanConnect,
      keywords: settingsKeywords(l10n.settings_categoryProxyKeywords),
      sections: proxySettingsSections(context),
      onTap: (context) => const ProxySettingsRoute().push(context),
      subscreens: [
        _SettingsSubscreen(
          title: l10n.settings_proxyRoutingTitle,
          sections: proxyRoutingSettingsSections(context),
          open: (context) => const ProxyRoutingSettingsRoute().push(context),
          feature: FeatureId.connectionsGlobalRouting,
          keptWhen: KeptWhen.globalRouteInUse,
        ),
        _SettingsSubscreen(
          title: l10n.tor_proxyLabel(torBrand),
          sections: torProxySettingsSections(l10n),
          open: (context) => const TorProxyRoute().push(context),
          feature: FeatureId.connectionsTorBasic,
          keptWhen: KeptWhen.torInUse,
        ),
      ],
    ),
  ];

  final services = [
    _SettingsCategoryDefinition(
      title: l10n.settings_categoryExtensionsTitle,
      subtitle: l10n.settings_categoryExtensionsSubtitle,
      icon: MdiIcons.puzzleOutline,
      keywords: settingsKeywords(l10n.settings_categoryExtensionsKeywords),
      sections: extensionsSettingsSections(context),
      onTap: (context) => ExtensionsSettingsRoute().push(context),
    ),
    _SettingsCategoryDefinition(
      title: l10n.settings_categoryAccountTitle,
      subtitle: l10n.settings_categoryAccountSubtitle,
      icon: Icons.account_circle_outlined,
      keywords: settingsKeywords(l10n.settings_categoryAccountKeywords),
      onTap: (context) => AccountSettingsRoute().push(context),
    ),
    _SettingsCategoryDefinition(
      title: l10n.settings_categorySyncTitle,
      subtitle: l10n.settings_categorySyncSubtitle,
      icon: Icons.sync,
      keywords: settingsKeywords(l10n.settings_categorySyncKeywords),
      sections: syncSettingsSearchSections(context),
      onTap: (context) => SyncSettingsRoute().push(context),
    ),
    _SettingsCategoryDefinition(
      title: l10n.settings_categoryAdvancedTitle,
      subtitle: l10n.settings_categoryAdvancedSubtitle,
      icon: Icons.developer_mode,
      keywords: settingsKeywords(l10n.settings_categoryAdvancedKeywords),
      sections: advancedSettingsSections(context),
      onTap: (context) => AdvancedSettingsRoute().push(context),
      subscreens: [
        _SettingsSubscreen(
          title: l10n.settings_experimentalTitle,
          sections: experimentalSettingsSections(context),
          open: (context) => ExperimentalSettingsRoute().push(context),
          feature: FeatureId.advancedExperimentalProcess,
        ),
      ],
    ),
  ];

  return (browser: browser, services: services);
}

List<SettingsSectionDefinition> _buildCategorySections(
  BuildContext context,
  _CategoryGroups categories,
) {
  final l10n = AppLocalizations.of(context);

  return [
    SettingsSectionDefinition(
      title: l10n.settings_categoryGroupBrowserTitle,
      entries: [
        for (final category in categories.browser)
          _buildCategoryEntry(category),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.settings_categoryGroupServicesAdvancedTitle,
      entries: [
        for (final category in categories.services)
          _buildCategoryEntry(category),
      ],
    ),
  ];
}

List<SettingsSectionDefinition> _buildSearchSections(
  List<_SettingsCategoryDefinition> categories,
  String normalizedQuery,
) {
  final results = <String, List<SettingsEntryDefinition>>{};

  for (final category in categories) {
    final categoryEntries = <SettingsEntryDefinition>[];

    if (matchesSettingsSearch(normalizedQuery, [
      category.title,
      category.subtitle,
      ...category.keywords,
    ])) {
      categoryEntries.add(
        SettingsEntryDefinition(
          title: category.title,
          subtitle: category.subtitle,
          keywords: category.keywords,
          child: _SearchResultTile(
            SettingsSearchTarget(
              title: category.title,
              subtitle: category.subtitle,
              keywords: category.keywords,
              category: category.title,
              section: null,
              icon: category.icon,
              feature: category.feature,
              keptWhen: category.keptWhen,
              open: category.onTap,
            ),
          ),
        ),
      );
    }

    for (final (:section, :sectionLabel, :open) in _searchableSections(
      category,
      (sections) =>
          filterSettingsSections(sections: sections, query: normalizedQuery),
    )) {
      for (final entry in section.entries) {
        categoryEntries.add(
          SettingsEntryDefinition(
            title: entry.title,
            subtitle: '$sectionLabel • ${category.title}',
            keywords: entry.keywords,
            child: _SearchResultTile(
              SettingsSearchTarget(
                title: entry.title,
                subtitle: entry.subtitle,
                keywords: entry.keywords,
                category: category.title,
                section: sectionLabel,
                icon: category.icon,
                feature:
                    settingsEntryFeature(section, entry) ?? category.feature,
                keptWhen: _entryKeptWhen(category, section, entry),
                open: open,
              ),
            ),
          ),
        );
      }
    }

    if (categoryEntries.isNotEmpty) {
      results[category.title] = categoryEntries;
    }
  }

  return [
    for (final result in results.entries)
      SettingsSectionDefinition(title: result.key, entries: result.value),
  ];
}

/// What keeps [entry] shown while its feature is hidden: its own condition,
/// or — for an entry that takes the category's feature — the category's.
KeptWhen? _entryKeptWhen(
  _SettingsCategoryDefinition category,
  SettingsSectionDefinition section,
  SettingsEntryDefinition entry,
) => settingsEntryFeature(section, entry) == null
    ? category.keptWhen
    : settingsEntryKeptWhen(section, entry);

SettingsEntryDefinition _buildCategoryEntry(
  _SettingsCategoryDefinition category,
) {
  return SettingsEntryDefinition(
    title: category.title,
    subtitle: category.subtitle,
    keywords: category.keywords,
    feature: category.feature,
    keptWhen: category.keptWhen,
    // A hidden category is grayed out but still opens; its screen grays out
    // what it hides.
    opensScreen: true,
    child: _CategoryTile(category: category),
  );
}

class _SettingsCategoryDefinition {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> keywords;
  final List<SettingsSectionDefinition> sections;
  final Future<void> Function(BuildContext context) onTap;

  /// The policy feature the whole screen configures. Hidden with it, but
  /// still found by the search (S1).
  final FeatureId? feature;

  /// While true, [feature] does not hide the category (P5); see
  /// [SettingsEntryDefinition.keptWhen]. Its settings that name no feature of
  /// their own follow it, as they follow [feature].
  final KeptWhen? keptWhen;

  /// Screens opened from this one whose settings the search finds too.
  final List<_SettingsSubscreen> subscreens;

  const _SettingsCategoryDefinition({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.keywords = const [],
    this.sections = const [],
    this.feature,
    this.keptWhen,
    this.subscreens = const [],
  });
}

/// A settings screen one level below a category (URL Cleaner below
/// Browsing), indexed so that its hidden settings can be found and revealed
/// (S1). A result opens [open], not the category.
class _SettingsSubscreen {
  final String title;
  final List<SettingsSectionDefinition> sections;
  final Future<void> Function(BuildContext context) open;

  /// The policy feature the whole subscreen configures, for sections that
  /// name none of their own, and when what it configures is in place
  /// ([SettingsEntryDefinition.keptWhen]).
  final FeatureId? feature;
  final KeptWhen? keptWhen;

  const _SettingsSubscreen({
    required this.title,
    required this.sections,
    required this.open,
    this.feature,
    this.keptWhen,
  });

  /// [sections], with [feature] and [keptWhen] on those that name no feature.
  List<SettingsSectionDefinition> get searchSections => feature == null
      ? sections
      : [
          for (final section in sections)
            if (section.feature != null)
              section
            else
              section.copyWith(feature: feature, keptWhen: keptWhen),
        ];
}

/// Every place the search looks in a [category]: its own sections, opened
/// with the category, and its subscreens', opened with the subscreen.
Iterable<
  ({
    SettingsSectionDefinition section,
    String sectionLabel,
    Future<void> Function(BuildContext context) open,
  })
>
_searchableSections(
  _SettingsCategoryDefinition category,
  List<SettingsSectionDefinition> Function(List<SettingsSectionDefinition>)
  filter,
) sync* {
  for (final section in filter(category.sections)) {
    yield (section: section, sectionLabel: section.title, open: category.onTap);
  }
  for (final subscreen in category.subscreens) {
    for (final section in filter(subscreen.searchSections)) {
      yield (
        section: section,
        sectionLabel: '${subscreen.title} • ${section.title}',
        open: subscreen.open,
      );
    }
  }
}

class _CategoryTile extends StatelessWidget {
  final _SettingsCategoryDefinition category;

  const _CategoryTile({required this.category});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(category.title),
      subtitle: Text(category.subtitle),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      leading: Icon(category.icon),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await category.onTap(context);
      },
    );
  }
}

class _SearchResultTile extends ConsumerWidget {
  final SettingsSearchTarget target;

  const _SearchResultTile(this.target);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feature = target.feature;
    // Every switch that hides it, as "Show" in the reveal dialog turns them
    // all on.
    return HiddenSwitchesBuilder(
      conditions: [
        if (feature != null) (feature: feature, keptWhen: target.keptWhen),
      ],
      builder: (context, hiddenBy) => _tile(context, ref, hiddenBy),
    );
  }

  Widget _tile(
    BuildContext context,
    WidgetRef ref,
    List<VisibilitySwitch> hiddenBy,
  ) {
    final l10n = AppLocalizations.of(context);
    final isHidden = hiddenBy.isNotEmpty;

    final lines = [
      if (target.section != null) '${target.category} • ${target.section}',
      if (target.subtitle case final subtitle? when subtitle.isNotEmpty)
        subtitle,
      if (hiddenBy.length == 1)
        l10n.visibilitySwitch_hiddenStatus(hiddenBy.single.label(context))
      else if (hiddenBy.length > 1)
        l10n.visibilitySwitch_hiddenStatusSeveral(
          formatList(l10n, hiddenBy.map((s) => s.label(context))),
        ),
    ];

    return ListTile(
      leading: Icon(!isHidden ? target.icon : Icons.visibility_off_outlined),
      title: Text(target.title),
      subtitle: Text(lines.join('\n')),
      isThreeLine: lines.length > 1,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => target.openFromSearch(context, ref),
    );
  }
}

/// One place the settings search can take the user: a whole settings screen,
/// or one setting on it.
class SettingsSearchTarget {
  final String title;
  final String? subtitle;
  final List<String> keywords;

  /// The settings screen it lives on.
  final String category;

  /// The section on that screen, or null when the target is the screen itself.
  final String? section;

  final IconData icon;

  /// The policy feature the target configures, if any. The search lists a
  /// hidden one with its status (S1); its screen shows it grayed out.
  final FeatureId? feature;

  /// See [SettingsEntryDefinition.keptWhen]: while true, [feature] does not
  /// hide the target.
  final KeptWhen? keptWhen;

  /// Pushes the settings screen. For a single setting, the caller first hands
  /// [title] to `PendingSettingsHighlight` so the screen scrolls to it.
  final Future<void> Function(BuildContext context) open;

  const SettingsSearchTarget({
    required this.title,
    required this.subtitle,
    required this.keywords,
    required this.category,
    required this.section,
    required this.icon,
    required this.open,
    this.feature,
    this.keptWhen,
  });

  bool get isCategory => section == null;

  /// Opens the target as a search result. A single setting is handed to
  /// `PendingSettingsHighlight` so its screen opens scrolled to it. A hidden
  /// one opens too: its screen shows it grayed out, and changing it asks to
  /// show it there (S1).
  Future<void> openFromSearch(BuildContext context, WidgetRef ref) async {
    final pendingHighlight = ref.read(
      pendingSettingsHighlightProvider.notifier,
    );
    if (!isCategory) pendingHighlight.set(title);
    try {
      await open(context);
    } catch (_) {
      pendingHighlight.clear();
      rethrow;
    }
  }
}

/// Everything the settings search indexes, for search surfaces outside the
/// settings screen (the search screen's Actions section).
///
/// Built from the same category definitions as the settings screen, so the two
/// can never disagree about what exists or where it lives.
List<SettingsSearchTarget> settingsSearchTargets(BuildContext context) {
  final categories = _buildCategories(context);

  return [
    for (final category in [...categories.browser, ...categories.services]) ...[
      SettingsSearchTarget(
        title: category.title,
        subtitle: category.subtitle,
        keywords: category.keywords,
        category: category.title,
        section: null,
        icon: category.icon,
        feature: category.feature,
        keptWhen: category.keptWhen,
        open: category.onTap,
      ),
      for (final (:section, :sectionLabel, :open) in _searchableSections(
        category,
        (sections) => sections,
      ))
        for (final entry in section.entries)
          SettingsSearchTarget(
            title: entry.title,
            subtitle: entry.subtitle,
            // A section's synonyms find every setting in it, as they do in the
            // settings search itself.
            keywords: [...entry.keywords, ...section.keywords],
            category: category.title,
            section: sectionLabel,
            icon: category.icon,
            feature: settingsEntryFeature(section, entry) ?? category.feature,
            keptWhen: _entryKeptWhen(category, section, entry),
            open: open,
          ),
    ],
  ];
}
