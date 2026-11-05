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
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/window_size_class.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/settings/domain/hidden_settings.dart';
import 'package:weblibre/features/settings/domain/providers/pending_settings_highlight.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/widgets/hidden_feature_gate.dart';
import 'package:weblibre/presentation/widgets/highlight_pulse.dart';

part 'settings_detail.g.dart';

/// Default total-entry count at or below which [SettingsDetailScaffold] hides
/// its search field — searching three toggles is just visual noise.
const int kDefaultSettingsSearchEntryThreshold = 10;

/// Splits a localized `*Keywords` message — comma-separated search terms, kept
/// in the ARB files so translators can supply the words people type in their
/// own language — into the list the settings search matches against.
List<String> settingsKeywords(String message) => [
  for (final keyword in message.split(','))
    if (keyword.trim() case final trimmed when trimmed.isNotEmpty) trimmed,
];

class SettingsEntryDefinition {
  final String title;
  final String? subtitle;
  final List<String> keywords;
  final Widget child;

  /// The policy feature this setting configures. While the feature is hidden
  /// by its visibility switches, the entry stays on its screen grayed out
  /// ([HiddenFeatureGate]): changing it asks to show the feature first. The
  /// settings search lists it with its status (S1).
  final FeatureId? feature;

  /// True while what [feature] configures is already in place, e.g. a server
  /// override that is set. The entry then stays usable even with [feature]
  /// hidden, so it can be checked and undone (P5), and the search lists it
  /// without a hidden status. Only for what keeps applying while hidden
  /// (H1); a setting that does not apply takes [hiddenSettings].
  final KeptWhen? keptWhen;

  /// Like a [keptWhen] that holds, for a condition the screen already knows:
  /// the entry stays usable whatever hides it, a [HiddenFeatureScope] around
  /// its screen included. For a setting that is on and has to stay
  /// switchable off (P5).
  final bool inForce;

  /// Whether the entry only leads to another screen. While hidden it is
  /// grayed out but still opens, and the screen it opens gates its own
  /// controls.
  final bool opensScreen;

  /// The settings this entry shows that stop applying while [feature] is
  /// hidden; see [HiddenFeatureGate.hiddenSettings].
  final List<HiddenSetting> hiddenSettings;

  /// Only for the settings search: never drawn on a screen. For screens whose
  /// content is not a static list (built from live state, or from data such
  /// as the fingerprint targets), so a hidden part can still be found.
  final bool searchOnly;

  /// Names the entry for code that rearranges its section, which must not go
  /// by the translated [title]. Toolbar & Layout tags each "Customize
  /// buttons" row with the toolbar whose editor it opens, so a part that
  /// edits those buttons in place can leave the row out.
  final Object? id;

  const SettingsEntryDefinition({
    required this.title,
    required this.child,
    this.subtitle,
    this.keywords = const [],
    this.feature,
    this.keptWhen,
    this.opensScreen = false,
    this.inForce = false,
    this.hiddenSettings = const [],
    this.searchOnly = false,
    this.id,
  });

  /// A [searchOnly] entry, which needs no widget.
  const SettingsEntryDefinition.searchOnly({
    required this.title,
    this.subtitle,
    this.keywords = const [],
    this.feature,
    this.keptWhen,
    this.id,
  }) : child = const SizedBox.shrink(),
       opensScreen = false,
       inForce = false,
       hiddenSettings = const [],
       searchOnly = true;
}

@CopyWith()
class SettingsSectionDefinition {
  final String title;
  final List<String> keywords;
  final List<SettingsEntryDefinition> entries;

  /// Like [SettingsEntryDefinition.feature], for a whole section.
  final FeatureId? feature;

  /// Like [SettingsEntryDefinition.keptWhen], for a whole section.
  final KeptWhen? keptWhen;

  const SettingsSectionDefinition({
    required this.title,
    required this.entries,
    this.keywords = const [],
    this.feature,
    this.keptWhen,
  });
}

/// The feature an [entry] of [section] belongs to, if any: its own, or the
/// section's.
FeatureId? settingsEntryFeature(
  SettingsSectionDefinition section,
  SettingsEntryDefinition entry,
) => entry.feature ?? section.feature;

/// The [SettingsEntryDefinition.keptWhen] that goes with
/// [settingsEntryFeature]: the entry's for its own feature, else the
/// section's.
KeptWhen? settingsEntryKeptWhen(
  SettingsSectionDefinition section,
  SettingsEntryDefinition entry,
) => entry.feature != null ? entry.keptWhen : section.keptWhen;

/// What gates [entry] of [section]: the section's feature and the entry's
/// own, each with its `keptWhen`. Hidden while either is.
List<HiddenFeatureCondition> settingsEntryConditions(
  SettingsSectionDefinition section,
  SettingsEntryDefinition entry,
) => [
  if (section.feature case final feature?)
    (feature: feature, keptWhen: section.keptWhen),
  if (entry.feature case final feature?)
    (feature: feature, keptWhen: entry.keptWhen),
];

/// [sections] as a screen draws them: without the search-only entries.
/// Sections left empty are dropped. Hidden entries stay;
/// [buildSettingsSectionWidgets] grays them out.
List<SettingsSectionDefinition> visibleSettingsSections(
  List<SettingsSectionDefinition> sections,
) {
  final visible = <SettingsSectionDefinition>[];
  for (final section in sections) {
    final entries = [
      for (final entry in section.entries)
        if (!entry.searchOnly) entry,
    ];
    if (entries.isEmpty) continue;

    visible.add(
      entries.length == section.entries.length
          ? section
          : section.copyWith(entries: entries),
    );
  }
  return visible;
}

/// Result of [useSettingsSearch]: the bound [TextEditingController] used by
/// [SettingsSearchField], plus the trimmed/lowercased query suitable for
/// substring matching with [matchesSettingsSearch].
class SettingsSearchState {
  final TextEditingController controller;
  final String normalizedQuery;

  const SettingsSearchState({
    required this.controller,
    required this.normalizedQuery,
  });

  String get rawQuery => controller.text;
}

/// Standard search-field plumbing for a settings screen: returns a controller
/// that should be passed to [SettingsCustomScrollScaffold.searchController] /
/// [SettingsSearchField], plus the normalized query string callers use to
/// filter their own data. Rebuilds the surrounding widget on every keystroke.
SettingsSearchState useSettingsSearch() {
  final controller = useTextEditingController();
  useListenable(controller);
  return SettingsSearchState(
    controller: controller,
    normalizedQuery: controller.text.trim().toLowerCase(),
  );
}

class SettingsDetailScaffold extends HookWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<SettingsSectionDefinition> sections;
  final List<Widget> actions;

  /// Falls back to a localized "Search settings" when not given.
  final String? searchHintText;
  final int searchEntryThreshold;

  const SettingsDetailScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.sections,
    this.actions = const [],
    this.searchHintText,
    this.searchEntryThreshold = kDefaultSettingsSearchEntryThreshold,
  });

  @override
  Widget build(BuildContext context) {
    final totalEntries = sections.fold<int>(
      0,
      (sum, section) => sum + section.entries.length,
    );
    final showSearch = totalEntries > searchEntryThreshold;

    final search = useSettingsSearch();

    final filteredSections = showSearch
        ? filterSettingsSections(sections: sections, query: search.rawQuery)
        : sections;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Settings rows run edge to edge otherwise: a switch stranded
            // 900dp from its label is no easier to read than prose is. The app
            // bar stays full-bleed, so only the content is centred.
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
                      title: Text(title),
                      actions: actions,
                    ),
                    if (showSearch)
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
                            hintText: searchHintText,
                          ),
                        ),
                      ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        16 + inset,
                        showSearch ? 24 : 16,
                        16 + inset,
                        20,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: SettingsSectionList(
                          sections: filteredSections,
                          query: showSearch ? search.rawQuery : '',
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

class SettingsCustomScrollScaffold extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final TextEditingController? searchController;

  /// Falls back to a localized "Search settings" when not given.
  final String? searchHintText;
  final List<Widget> slivers;
  final Widget? floatingActionButton;

  const SettingsCustomScrollScaffold({
    super.key,
    required this.title,
    required this.slivers,
    this.actions = const [],
    this.searchController,
    this.searchHintText,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floatingActionButton,
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
                      title: Text(title),
                      actions: actions,
                    ),
                    if (searchController != null)
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          16 + inset,
                          8,
                          16 + inset,
                          0,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: SettingsSearchField(
                            controller: searchController!,
                            hintText: searchHintText,
                          ),
                        ),
                      ),
                    // Caller slivers bring their own padding; this only adds
                    // the centring amount, which is zero on a phone.
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: inset),
                      sliver: SliverMainAxisGroup(slivers: slivers),
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

class SettingsSearchField extends StatelessWidget {
  final TextEditingController controller;

  /// Falls back to a localized "Search settings" when not given.
  final String? hintText;

  final FocusNode? focusNode;

  const SettingsSearchField({
    super.key,
    required this.controller,
    this.hintText,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        hintText: hintText ?? l10n.settings_searchHint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                onPressed: controller.clear,
                icon: const Icon(Icons.close),
              ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class SettingsSectionList extends StatelessWidget {
  final List<SettingsSectionDefinition> unfilteredSections;
  final String query;

  /// Lists [sections] as [visibleSettingsSections] says, with hidden entries
  /// grayed out in place.
  const SettingsSectionList({
    super.key,
    required List<SettingsSectionDefinition> sections,
    required this.query,
  }) : unfilteredSections = sections;

  @override
  Widget build(BuildContext context) {
    final sections = visibleSettingsSections(unfilteredSections);

    if (sections.isEmpty) {
      final l10n = AppLocalizations.of(context);

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 8.0),
        child: Center(
          child: Text(
            query.trim().isEmpty
                ? l10n.settings_noSettingsAvailable
                : l10n.settings_noSettingsMatch(query),
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: buildSettingsSectionWidgets(context, sections),
    );
  }
}

List<Widget> buildSettingsSectionWidgets(
  BuildContext context,
  List<SettingsSectionDefinition> sections,
) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;

  return [
    for (
      var sectionIndex = 0;
      sectionIndex < sections.length;
      sectionIndex++
    ) ...[
      if (sectionIndex > 0) const SizedBox(height: 24),
      Text(
        sections[sectionIndex].title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 12),
      Card.filled(
        margin: EdgeInsets.zero,
        color: colorScheme.surfaceContainer,
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (
              var entryIndex = 0;
              entryIndex < sections[sectionIndex].entries.length;
              entryIndex++
            ) ...[
              if (entryIndex > 0) const Divider(height: 1),
              _HighlightableEntry(
                key: ValueKey(
                  '${sections[sectionIndex].title}/'
                  '${sections[sectionIndex].entries[entryIndex].title}',
                ),
                title: sections[sectionIndex].entries[entryIndex].title,
                child: HiddenFeatureGate(
                  conditions: settingsEntryConditions(
                    sections[sectionIndex],
                    sections[sectionIndex].entries[entryIndex],
                  ),
                  opensScreen:
                      sections[sectionIndex].entries[entryIndex].opensScreen,
                  inForce: sections[sectionIndex].entries[entryIndex].inForce,
                  hiddenSettings:
                      sections[sectionIndex].entries[entryIndex].hiddenSettings,
                  indicator: true,
                  child: sections[sectionIndex].entries[entryIndex].child,
                ),
              ),
            ],
          ],
        ),
      ),
    ],
  ];
}

/// Wraps a settings entry tile and, when [PendingSettingsHighlight] matches
/// [title], auto-scrolls it into view and briefly pulses a tint behind it.
/// Self-clears the pending highlight as soon as the destination entry handles
/// it so the effect doesn't replay on rebuild or back-navigation.
class _HighlightableEntry extends ConsumerWidget {
  final String title;
  final Widget child;

  const _HighlightableEntry({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingSettingsHighlightProvider);

    return HighlightPulse(
      active: pending != null && pending == title,
      // Cleared as soon as this entry claims the highlight, so stale state
      // cannot survive a quick pop or an interrupted animation.
      onStarted: () =>
          ref.read(pendingSettingsHighlightProvider.notifier).clear(),
      child: child,
    );
  }
}

List<SettingsSectionDefinition> filterSettingsSections({
  required List<SettingsSectionDefinition> sections,
  required String query,
}) {
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) return sections;

  final filteredSections = <SettingsSectionDefinition>[];

  for (final section in sections) {
    if (matchesSettingsSearch(normalizedQuery, [
      section.title,
      ...section.keywords,
    ])) {
      filteredSections.add(section);
      continue;
    }

    final filteredEntries = [
      for (final entry in section.entries)
        if (matchesSettingsSearch(normalizedQuery, [
          section.title,
          entry.title,
          if (entry.subtitle != null) entry.subtitle!,
          ...section.keywords,
          ...entry.keywords,
        ]))
          entry,
    ];

    if (filteredEntries.isNotEmpty) {
      filteredSections.add(section.copyWith(entries: filteredEntries));
    }
  }

  return filteredSections;
}

/// Token-AND substring match used by every settings search. The query is
/// expected to already be trimmed and lowercased (e.g. via
/// [useSettingsSearch] or [filterSettingsSections]).
bool matchesSettingsSearch(String normalizedQuery, List<String> values) {
  final tokens = normalizedQuery
      .split(RegExp(r'\s+'))
      .where((token) => token.isNotEmpty);
  final haystack = values.join(' ').toLowerCase();
  return tokens.every(haystack.contains);
}
