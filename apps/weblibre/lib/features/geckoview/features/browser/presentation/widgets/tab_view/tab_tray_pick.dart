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
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/tab_pick_request.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/tab_view_filter_options.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/tab_picker_rows.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_preview.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/tab_view/tab_tray_new_tab_fab.dart';
import 'package:weblibre/features/geckoview/features/browser/utils/grid_calculations.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// The tab tray as a picker, for everything below it: the [request], and the
/// container and tab-type filter the picker shows. Those two are the
/// picker's own, so choosing them never switches the browser's container
/// (which would bring up home over the page the pick is for) or changes the
/// tray's saved filter.
class TabTrayPick extends InheritedWidget {
  final TabPickRequest request;

  /// The container shown (null for tabs without one).
  final ContainerData? container;
  final TabTypeFilter typeFilter;
  final ValueChanged<ContainerData?> selectContainer;
  final ValueChanged<TabTypeFilter> selectTypeFilter;

  const TabTrayPick._({
    required this.request,
    required this.container,
    required this.typeFilter,
    required this.selectContainer,
    required this.selectTypeFilter,
    required super.child,
  });

  /// The picker the tray is shown as, or null for the plain tray.
  static TabTrayPick? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TabTrayPick>();

  /// The tab types the picker's filter bar offers: none for private tabs
  /// (there is only one kind), otherwise all non-private ones together,
  /// regular and isolated.
  List<TabTypeFilter> get typeFilters => request.privateTabs
      ? const []
      : const [
          TabTypeFilter.all,
          TabTypeFilter.regularOnly,
          TabTypeFilter.isolatedOnly,
        ];

  String? get containerId => container?.id;

  /// Picks [tabId] for the request.
  void pick(String tabId) => request.onPicked(tabId);

  @override
  bool updateShouldNotify(TabTrayPick oldWidget) =>
      request != oldWidget.request ||
      container != oldWidget.container ||
      typeFilter != oldWidget.typeFilter;
}

/// Holds the picker's container and filter and provides [TabTrayPick].
class TabTrayPickScope extends HookWidget {
  final TabPickRequest request;
  final Widget child;

  const TabTrayPickScope({
    super.key,
    required this.request,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final container = useState(request.initialContainer);
    final typeFilter = useState(TabTypeFilter.all);

    return TabTrayPick._(
      request: request,
      container: container.value,
      typeFilter: typeFilter.value,
      selectContainer: (selected) => container.value = selected,
      selectTypeFilter: (filter) => typeFilter.value = filter,
      child: child,
    );
  }
}

/// Takes the action bar's place at the bottom of the tray while it picks:
/// keeps the tabs clear of the navigation bar, or of the keyboard while it
/// covers the bar, as the action bar does.
class TabPickerBottomInset extends StatelessWidget {
  const TabPickerBottomInset({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: math.max(
      MediaQuery.paddingOf(context).bottom,
      MediaQuery.viewInsetsOf(context).bottom,
    ),
  );
}

TabPickerRowsProvider _offeredRowsProvider(TabTrayPick pick) =>
    tabPickerRowsProvider(
      containerId: pick.containerId,
      privateTabs: pick.request.privateTabs,
      typeFilter: pick.typeFilter,
    );

/// [rows] without the tabs [pick] excludes.
List<TabPickerRow> _withoutExcluded(
  List<TabPickerRow> rows,
  TabTrayPick pick,
) => rows
    .where((row) => !pick.request.excludedTabIds.contains(row.tabId))
    .toList();

/// Shown, in a scroll view of its own, when nothing can be picked here, so
/// the header still learns that nothing is scrolled under it.
Widget _nothingToPick(BuildContext context, ScrollController controller) =>
    CustomScrollView(
      controller: controller,
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                AppLocalizations.of(context).browser_tabPickerNothingHere,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );

/// The tray's list view while it picks a tab: the same rows, and a tap picks.
/// Nothing is closed, moved or dragged here.
class TabPickerListView extends ConsumerWidget {
  /// The tray list's row height (`tab_list_view.dart`).
  static const itemHeight = 86.0;

  final ScrollController scrollController;

  const TabPickerListView({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pick = TabTrayPick.maybeOf(context)!;
    final offeredRows = ref.watch(_offeredRowsProvider(pick)).value;
    final rows = _withoutExcluded(offeredRows, pick);

    if (rows.isEmpty) return _nothingToPick(context, scrollController);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.only(bottom: tabTrayListBottomPadding),
        itemCount: rows.length,
        itemExtent: itemHeight,
        itemBuilder: (context, index) {
          final row = rows[index];
          return ListTabPreview(
            key: ValueKey(row.tabId),
            tabId: row.tabId,
            isActive: false,
            depth: row.depth,
            onTap: () => pick.pick(row.tabId),
          );
        },
      ),
    );
  }
}

/// The tray's grid view while it picks a tab: the same tiles, and a tap
/// picks.
class TabPickerGridView extends ConsumerWidget {
  /// Width available to the grid, as for the tray's grid.
  final double availableWidth;
  final ScrollController scrollController;

  const TabPickerGridView({
    super.key,
    required this.availableWidth,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pick = TabTrayPick.maybeOf(context)!;
    final offeredRows = ref.watch(_offeredRowsProvider(pick)).value;
    final rows = _withoutExcluded(offeredRows, pick);

    if (rows.isEmpty) return _nothingToPick(context, scrollController);

    // As the tray's grid lays out its tiles.
    final crossAxisCount = math.max(
      math.min(
        calculateCrossAxisItemCount(
          screenWidth: availableWidth,
          horizontalPadding: 4.0,
          crossAxisSpacing: 8.0,
        ),
        rows.length,
      ),
      2,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: GridView.builder(
        controller: scrollController,
        padding: const EdgeInsets.only(bottom: tabTrayListBottomPadding),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 0.75,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
          crossAxisCount: crossAxisCount,
        ),
        itemCount: rows.length,
        itemBuilder: (context, index) {
          final row = rows[index];
          return GridTabPreview(
            key: ValueKey(row.tabId),
            tabId: row.tabId,
            isActive: false,
            depth: row.depth,
            onTap: () => pick.pick(row.tabId),
          );
        },
      ),
    );
  }
}
