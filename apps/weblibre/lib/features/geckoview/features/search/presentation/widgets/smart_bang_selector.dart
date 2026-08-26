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
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/extensions/uri.dart';
import 'package:weblibre/features/bangs/data/models/bang_data.dart';
import 'package:weblibre/features/bangs/data/models/bang_key.dart';
import 'package:weblibre/features/bangs/domain/providers/bangs.dart';
import 'package:weblibre/features/bangs/domain/providers/search.dart';
import 'package:weblibre/features/bangs/presentation/widgets/bang_label.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/bang_chip_strip.dart';
import 'package:weblibre/presentation/hooks/on_listenable_change_selector.dart';
import 'package:weblibre/presentation/widgets/sliding_pill_toggle.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';
import 'package:weblibre/utils/uri_parser.dart' as uri_parser;

/// A unified bang selector widget that displays site-specific and/or global
/// search bangs with a tabbed interface when in edit mode.
///
/// In edit mode (domain != null):
/// - Shows "Site" and "All" tabs when site-specific bangs exist
/// - "Site" tab displays only domain-specific bangs
/// - "All" tab displays global bangs (same as new tab mode)
/// - Selecting in one tab clears selection in the other (mutual exclusion)
///
/// In new tab mode (domain == null):
/// - Shows global bangs without tabs
class SmartBangSelector extends HookConsumerWidget {
  /// The domain to scope site-specific bangs to.
  /// When null, only global bangs are shown (new tab mode).
  final String? domain;

  /// Controller for the search text field.
  /// Used for text clearing on selection and for seamless bang search.
  final TextEditingController searchTextController;

  /// Whether to display the menu button to open bang search.
  final bool displayMenu;

  const SmartBangSelector({
    required this.domain,
    required this.searchTextController,
    this.displayMenu = true,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditMode = domain != null;

    // Watch site-specific bangs (only in edit mode)
    final siteBangs = isEditMode
        ? ref.watch(
            bangListProvider(
              domain: domain,
              orderMostFrequentFirst: true,
            ).select((value) => value.value ?? const []),
          )
        : const <BangData>[];

    // Watch global bangs via seamless provider (supports search)
    // When search text is empty: shows frequentBangListProvider
    // When search text is not empty: shows search results
    final searchBangs = ref.watch(
      seamlessBangProvider.select((v) => v.value ?? const []),
    );

    // Also watch frequent bangs as fallback when search returns empty
    final frequentBangs = ref.watch(
      frequentBangListProvider.select((v) => v.value ?? const []),
    );

    final pinnedBangs = ref.watch(
      pinnedBangListProvider.select((v) => v.value ?? const []),
    );

    // Search results stand on their own — they are already ranked, and pushing
    // pins in front of an explicit query would bury what was asked for. With
    // no query the pins lead, then whatever frequency turned up that they do
    // not already cover.
    final globalBangs = searchBangs.isNotEmpty
        ? searchBangs
        : mergePinnedBangs(pinned: pinnedBangs, rest: frequentBangs);

    // Trigger search when text changes, and once for the text that is already
    // there: this selector only mounts once the field is non-empty, so the
    // keystroke that brought it on screen never arrives as a change event.
    useOnListenableChangeSelector(
      searchTextController,
      () => searchTextController.text,
      () {
        ref
            .read(seamlessBangProvider.notifier)
            .search(searchTextController.text);
      },
      fireImmediately: true,
    );

    // Determine if we should show tabs
    final showTabs = isEditMode && siteBangs.isNotEmpty;

    // Watch both selection providers to determine the active bang
    final siteSelectedBang = isEditMode
        ? ref.watch(selectedBangDataProvider(domain: domain))
        : null;
    final globalSelectedBang = ref.watch(selectedBangDataProvider());

    // The active bang is whichever one is set (only one should be set at a time)
    final activeBang = siteSelectedBang ?? globalSelectedBang;

    if (showTabs) {
      return _TabbedBangSelector(
        domain: domain!,
        siteBangs: siteBangs,
        globalBangs: globalBangs,
        activeBang: activeBang,
        isSiteSelected: siteSelectedBang != null,
        searchTextController: searchTextController,
        displayMenu: displayMenu,
      );
    }

    // No tabs — these are global bangs, so they select into the global scope
    // even in edit mode. Scoping them to the domain instead put the selection
    // somewhere nothing else reads: the reverse URL match and the new-tab
    // strip both write the global one, and the chip's `x` then found no
    // selection to clear.
    return _BangChipsList(
      domain: null,
      // Still worth clearing a leftover site selection, which would otherwise
      // outrank the global one this list writes.
      siteDomain: domain,
      bangs: globalBangs,
      selectedBang: activeBang,
      searchTextController: searchTextController,
      displayMenu: displayMenu,
    );
  }
}

/// Tabbed bang selector with "Site" and "All" tabs.
class _TabbedBangSelector extends HookConsumerWidget {
  final String domain;
  final List<BangData> siteBangs;
  final List<BangData> globalBangs;
  final BangData? activeBang;
  final bool isSiteSelected;
  final TextEditingController searchTextController;
  final bool displayMenu;

  const _TabbedBangSelector({
    required this.domain,
    required this.siteBangs,
    required this.globalBangs,
    required this.activeBang,
    required this.isSiteSelected,
    required this.searchTextController,
    required this.displayMenu,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useTabController(
      initialLength: 2,
      initialIndex: isSiteSelected ? 1 : 0,
    );
    final tabIndex = useState(isSiteSelected ? 1 : 0);

    useEffect(() {
      void listener() => tabIndex.value = tabController.index;
      tabController.addListener(listener);
      return () => tabController.removeListener(listener);
    }, [tabController]);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated sliding pill toggle
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: SlidingPillToggle(
            selectedIndex: tabIndex.value,
            labels: const ['All Providers', 'Search On This Site'],
            onChanged: (index) => tabController.animateTo(index),
          ),
        ),
        // Tab content
        SizedBox(
          height: 48,
          child: TabBarView(
            controller: tabController,
            children: [
              // All tab - uses global provider, clears site on select
              _BangChipsList(
                domain: null,
                siteDomain: domain, // Pass for mutual exclusion
                bangs: globalBangs,
                selectedBang: !isSiteSelected ? activeBang : null,
                searchTextController: searchTextController,
                displayMenu: displayMenu,
              ),
              // Site tab - uses domain-scoped provider, clears global on select
              _BangChipsList(
                domain: domain,
                siteDomain: domain, // Pass for mutual exclusion
                bangs: siteBangs,
                selectedBang: isSiteSelected ? activeBang : null,
                searchTextController: searchTextController,
                displayMenu: displayMenu,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Displays the default search provider as a chip.
class _DefaultSearchProviderChip extends ConsumerWidget {
  const _DefaultSearchProviderChip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defaultBang = ref.watch(defaultSearchBangDataProvider);

    return defaultBang.when(
      data: (bang) {
        if (bang == null) {
          return const SizedBox.shrink();
        }

        return ActionChip(
          avatar: UrlIcon([bang.getDefaultUrl()], iconSize: 20),
          label: BangLabel(bang),
          onPressed: () async {
            // Open bang search when tapped
            await const BangSearchRoute().push(context);
          },
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

/// The actual chip list with selection handling.
class _BangChipsList extends HookConsumerWidget {
  /// The domain for this list's selection provider.
  /// null = global provider, non-null = domain-scoped provider.
  final String? domain;

  /// The site domain for mutual exclusion.
  /// When selecting, the OTHER provider (site vs global) will be cleared.
  /// null = no mutual exclusion (single mode without tabs).
  final String? siteDomain;

  final List<BangData> bangs;
  final BangData? selectedBang;
  final TextEditingController searchTextController;
  final bool displayMenu;

  const _BangChipsList({
    required this.domain,
    required this.siteDomain,
    required this.bangs,
    required this.selectedBang,
    required this.searchTextController,
    required this.displayMenu,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BangChipStrip(
      bangs: bangs,
      selectedBang: selectedBang,
      // Here the active chip is always a real selection — the default provider
      // has its own prefix chip rather than a place in this list.
      clearableBang: selectedBang,
      prefixItems: displayMenu
          ? const [_DefaultSearchProviderChip()]
          : const [],
      showTrailingMenu: displayMenu,
      onMenuPressed: displayMenu ? () => _openBangSearch(context, ref) : null,
      onSelected: (bang) => _handleSelection(context, ref, bang),
      onDeleted: (_) => _handleDeletion(ref),
    );
  }

  void _handleSelection(BuildContext context, WidgetRef ref, BangData bang) {
    // Only clear text when it parses as a URL — searching a URL via a bang
    // makes no sense. Otherwise preserve the query so the user can run it
    // against the newly selected provider.
    final hasSupportedScheme =
        uri_parser
            .tryParseUrl(searchTextController.text)
            .mapNotNull((uri) => uri.hasSupportedScheme) ??
        false;

    if (hasSupportedScheme) {
      searchTextController.clear();
    }

    // Clear the OTHER provider for mutual exclusion
    if (siteDomain != null) {
      if (domain == null) {
        // We're in All tab (global), clear Site selection
        ref
            .read(selectedBangTriggerProvider(domain: siteDomain).notifier)
            .clearTrigger();
      } else {
        // We're in Site tab, clear All (global) selection
        ref.read(selectedBangTriggerProvider().notifier).clearTrigger();
      }
    }

    // Set selection using this list's provider scope
    ref
        .read(selectedBangTriggerProvider(domain: domain).notifier)
        .setTrigger(bang.toKey());

    // Highlight the full query so the user can immediately type over it to
    // replace the search term, or run it against the newly selected provider
    // as-is. Skipped when the text was cleared above (URL case).
    final text = searchTextController.text;
    if (text.isNotEmpty) {
      searchTextController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: text.length,
      );
    }
  }

  /// Clears the selection — the only thing the trailing `x` does. Frequency
  /// reset lives in the chip's long-press menu.
  ///
  /// Both scopes are cleared rather than the one this list writes to: a bang
  /// auto-selected from a reverse URL match lands in the global scope while a
  /// site-scoped list may be the one on screen, and mutual exclusion means at
  /// most one of them holds anything anyway.
  void _handleDeletion(WidgetRef ref) {
    ref
        .read(selectedBangTriggerProvider(domain: domain).notifier)
        .clearTrigger();

    if (siteDomain != null && siteDomain != domain) {
      ref
          .read(selectedBangTriggerProvider(domain: siteDomain).notifier)
          .clearTrigger();
    }
  }

  Future<void> _openBangSearch(BuildContext context, WidgetRef ref) async {
    final searchText = searchTextController.text.trim();

    final trigger = await BangSearchRoute(
      searchText: searchText.isEmpty
          ? BangSearchRoute.emptySearchText
          : searchText,
    ).push<BangKey?>(context);

    if (trigger != null) {
      // Clear the OTHER provider for mutual exclusion
      if (siteDomain != null) {
        if (domain == null) {
          ref
              .read(selectedBangTriggerProvider(domain: siteDomain).notifier)
              .clearTrigger();
        } else {
          ref.read(selectedBangTriggerProvider().notifier).clearTrigger();
        }
      }

      ref
          .read(selectedBangTriggerProvider(domain: domain).notifier)
          .setTrigger(trigger);
    }
  }
}
