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
import 'package:weblibre/features/bangs/domain/repositories/data.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/dialogs/reset_bang_dialog.dart';
import 'package:weblibre/presentation/widgets/selectable_chips.dart';
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

    // Use search results if available, otherwise fall back to frequent bangs
    final globalBangs = searchBangs.isNotEmpty ? searchBangs : frequentBangs;

    // Trigger search when text changes
    useOnListenableChange(searchTextController, () {
      ref.read(seamlessBangProvider.notifier).search(searchTextController.text);
    });

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

    // No tabs - show global bangs directly
    return _BangChipsList(
      domain: domain,
      siteDomain: null, // No mutual exclusion needed without tabs
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
    final tabController = useTabController(initialLength: 2);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tab bar - full width
        SizedBox(
          height: 32,
          width: double.infinity,
          child: TabBar(
            controller: tabController,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'Site'),
              Tab(text: 'All'),
            ],
          ),
        ),
        // Tab content
        SizedBox(
          height: 48,
          child: TabBarView(
            controller: tabController,
            children: [
              // Site tab - uses domain-scoped provider, clears global on select
              _BangChipsList(
                domain: domain,
                siteDomain: domain, // Pass for mutual exclusion
                bangs: siteBangs,
                selectedBang: isSiteSelected ? activeBang : null,
                searchTextController: searchTextController,
                displayMenu: displayMenu,
              ),
              // All tab - uses global provider, clears site on select
              _BangChipsList(
                domain: null,
                siteDomain: domain, // Pass for mutual exclusion
                bangs: globalBangs,
                selectedBang: !isSiteSelected ? activeBang : null,
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
    final hasContent = selectedBang != null || bangs.isNotEmpty;

    return SizedBox(
      height: 48,
      child: Row(
        children: [
          if (hasContent)
            Expanded(
              child: SelectableChips(
                itemId: (bang) => bang.trigger,
                itemAvatar: (bang) =>
                    UrlIcon([bang.getDefaultUrl()], iconSize: 20),
                itemLabel: (bang) => Text(bang.websiteName),
                itemTooltip: (bang) => bang.trigger,
                availableItems: bangs,
                selectedItem: selectedBang,
                onSelected: (bang) => _handleSelection(context, ref, bang),
                onDeleted: (bang) => _handleDeletion(context, ref, bang),
              ),
            )
          else if (displayMenu)
            Expanded(
              child: Text(
                "Press '>' to search Bangs.",
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            const Spacer(),
          if (displayMenu)
            IconButton(
              onPressed: () => _openBangSearch(context, ref),
              icon: const Icon(Icons.chevron_right),
            ),
        ],
      ),
    );
  }

  void _handleSelection(BuildContext context, WidgetRef ref, BangData bang) {
    // Text clearing logic:
    // - Site tab (domain != null): only clear if text is a valid URL
    // - All tab (domain == null): always clear (same as original BangChips)
    if (domain == null) {
      // All tab / new tab mode - always clear
      searchTextController.clear();
    } else {
      // Site tab - only clear if text is a valid URL
      final hasSupportedScheme = uri_parser
              .tryParseUrl(searchTextController.text)
              .mapNotNull((uri) => uri.hasSupportedScheme) ??
          false;

      if (hasSupportedScheme) {
        searchTextController.clear();
      }
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
  }

  Future<void> _handleDeletion(
    BuildContext context,
    WidgetRef ref,
    BangData bang,
  ) async {
    final currentSelection =
        ref.read(selectedBangTriggerProvider(domain: domain));

    if (currentSelection == bang.toKey()) {
      // Clear selection if the deleted bang is currently selected
      ref
          .read(selectedBangTriggerProvider(domain: domain).notifier)
          .clearTrigger();
    } else {
      // Show reset frequency dialog for non-selected bangs
      final dialogResult = await showResetBangDialog(
        context,
        triggerName: bang.trigger,
      );

      if (dialogResult == true) {
        await ref
            .read(bangDataRepositoryProvider.notifier)
            .resetFrequency(bang.trigger);
      }
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
