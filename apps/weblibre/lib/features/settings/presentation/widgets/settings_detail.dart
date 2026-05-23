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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/settings/domain/providers/pending_settings_highlight.dart';

/// Default total-entry count at or below which [SettingsDetailScaffold] hides
/// its search field — searching three toggles is just visual noise.
const int kDefaultSettingsSearchEntryThreshold = 10;

class SettingsEntryDefinition {
  final String title;
  final String? subtitle;
  final List<String> keywords;
  final Widget child;

  const SettingsEntryDefinition({
    required this.title,
    required this.child,
    this.subtitle,
    this.keywords = const [],
  });
}

class SettingsSectionDefinition {
  final String title;
  final List<String> keywords;
  final List<SettingsEntryDefinition> entries;

  const SettingsSectionDefinition({
    required this.title,
    required this.entries,
    this.keywords = const [],
  });
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
  final String searchHintText;
  final int searchEntryThreshold;

  const SettingsDetailScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.sections,
    this.actions = const [],
    this.searchHintText = 'Search settings',
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
        child: FadingScroll(
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
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    sliver: SliverToBoxAdapter(
                      child: SettingsSearchField(
                        controller: search.controller,
                        hintText: searchHintText,
                      ),
                    ),
                  ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    showSearch ? 24 : 16,
                    16,
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
        ),
      ),
    );
  }
}

class SettingsCustomScrollScaffold extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final TextEditingController? searchController;
  final String searchHintText;
  final List<Widget> slivers;

  const SettingsCustomScrollScaffold({
    super.key,
    required this.title,
    required this.slivers,
    this.actions = const [],
    this.searchController,
    this.searchHintText = 'Search settings',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FadingScroll(
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
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    sliver: SliverToBoxAdapter(
                      child: SettingsSearchField(
                        controller: searchController!,
                        hintText: searchHintText,
                      ),
                    ),
                  ),
                ...slivers,
              ],
            );
          },
        ),
      ),
    );
  }
}

class SettingsSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const SettingsSearchField({
    super.key,
    required this.controller,
    this.hintText = 'Search settings',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
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
  final List<SettingsSectionDefinition> sections;
  final String query;

  const SettingsSectionList({
    super.key,
    required this.sections,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 8.0),
        child: Center(
          child: Text(
            query.trim().isEmpty
                ? 'No settings available.'
                : 'No settings match "$query".',
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
                child: sections[sectionIndex].entries[entryIndex].child,
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
class _HighlightableEntry extends HookConsumerWidget {
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
    final isTarget = pending != null && pending == title;

    final controller = useAnimationController(
      duration: const Duration(milliseconds: 1500),
    );

    final animation = useMemoized(
      () => TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween(
            begin: 0.0,
            end: 1.0,
          ).chain(CurveTween(curve: Curves.easeOut)),
          weight: 20,
        ),
        TweenSequenceItem(tween: ConstantTween(1.0), weight: 30),
        TweenSequenceItem(
          tween: Tween(
            begin: 1.0,
            end: 0.0,
          ).chain(CurveTween(curve: Curves.easeIn)),
          weight: 50,
        ),
      ]).animate(controller),
      [controller],
    );

    useEffect(() {
      if (!isTarget) return null;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Clear immediately once this entry claims the highlight so stale
        // state cannot survive a quick pop or interrupted animation.
        ref.read(pendingSettingsHighlightProvider.notifier).clear();
        if (!context.mounted) return;
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          alignment: 0.2,
        );
        controller.forward(from: 0);
      });

      return null;
    }, [isTarget]);

    final highlightColor = Theme.of(context).colorScheme.secondaryContainer;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value;
        if (t == 0.0) return child!;
        return ColoredBox(
          color: highlightColor.withValues(alpha: t * 0.7),
          child: child,
        );
      },
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
      filteredSections.add(
        SettingsSectionDefinition(
          title: section.title,
          keywords: section.keywords,
          entries: filteredEntries,
        ),
      );
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
