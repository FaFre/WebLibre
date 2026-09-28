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
import 'package:weblibre/core/design/window_size_class.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/settings/domain/providers/pending_settings_highlight.dart';
import 'package:weblibre/features/settings/presentation/screens/advanced_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/browsing_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/extensions_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/general_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/home_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/privacy_security_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/proxy_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/search_settings.dart';
import 'package:weblibre/features/settings/presentation/screens/web_content_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/settings/presentation/widgets/toolbar_layout_content.dart';
import 'package:weblibre/features/web_push/presentation/screens/web_push_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

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
      title: l10n.settings_categoryBrowsingTitle,
      subtitle: l10n.settings_categoryBrowsingSubtitle,
      icon: MdiIcons.compassOutline,
      keywords: settingsKeywords(l10n.settings_categoryBrowsingKeywords),
      sections: browsingSettingsSections(context),
      onTap: (context) => BrowsingSettingsRoute().push(context),
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
      subtitle: l10n.settings_categoryGesturesSubtitle,
      icon: MdiIcons.gestureSwipe,
      keywords: settingsKeywords(l10n.settings_categoryGesturesKeywords),
      onTap: (context) => GestureSettingsRoute().push(context),
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
    ),
    _SettingsCategoryDefinition(
      title: l10n.settings_categoryProxyTitle,
      subtitle: l10n.settings_categoryProxySubtitle,
      icon: MdiIcons.lanConnect,
      keywords: settingsKeywords(l10n.settings_categoryProxyKeywords),
      sections: proxySettingsSections(context),
      onTap: (context) => const ProxySettingsRoute().push(context),
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
      onTap: (context) => SyncSettingsRoute().push(context),
    ),
    _SettingsCategoryDefinition(
      title: l10n.settings_categoryAdvancedTitle,
      subtitle: l10n.settings_categoryAdvancedSubtitle,
      icon: Icons.developer_mode,
      keywords: settingsKeywords(l10n.settings_categoryAdvancedKeywords),
      sections: advancedSettingsSections(context),
      onTap: (context) => AdvancedSettingsRoute().push(context),
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
      categoryEntries.add(_buildCategoryEntry(category));
    }

    for (final section in filterSettingsSections(
      sections: category.sections,
      query: normalizedQuery,
    )) {
      for (final entry in section.entries) {
        categoryEntries.add(
          SettingsEntryDefinition(
            title: entry.title,
            subtitle: '${section.title} • ${category.title}',
            keywords: entry.keywords,
            child: _SearchResultTile(
              title: entry.title,
              subtitle: entry.subtitle,
              category: category.title,
              section: section.title,
              icon: category.icon,
              onTap: category.onTap,
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

SettingsEntryDefinition _buildCategoryEntry(
  _SettingsCategoryDefinition category,
) {
  return SettingsEntryDefinition(
    title: category.title,
    subtitle: category.subtitle,
    keywords: category.keywords,
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

  const _SettingsCategoryDefinition({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.keywords = const [],
    this.sections = const [],
  });
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

class _SearchResultTile extends HookConsumerWidget {
  final String title;
  final String? subtitle;
  final String category;
  final String section;
  final IconData icon;
  final Future<void> Function(BuildContext context) onTap;

  const _SearchResultTile({
    required this.title,
    required this.category,
    required this.section,
    required this.icon,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(
        subtitle == null || subtitle!.isEmpty
            ? '$category • $section'
            : '$category • $section\n$subtitle',
      ),
      isThreeLine: subtitle != null && subtitle!.isNotEmpty,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        final pendingHighlight = ref.read(
          pendingSettingsHighlightProvider.notifier,
        );
        pendingHighlight.set(title);
        try {
          await onTap(context);
        } catch (_) {
          pendingHighlight.clear();
          rethrow;
        }
      },
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
  });

  bool get isCategory => section == null;
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
        open: category.onTap,
      ),
      for (final section in category.sections)
        for (final entry in section.entries)
          SettingsSearchTarget(
            title: entry.title,
            subtitle: entry.subtitle,
            // A section's synonyms find every setting in it, as they do in the
            // settings search itself.
            keywords: [...entry.keywords, ...section.keywords],
            category: category.title,
            section: section.title,
            icon: category.icon,
            open: category.onTap,
          ),
    ],
  ];
}
