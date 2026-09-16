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
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';

part 'accordion_expansion.g.dart';

/// Which container groups the accordion tab switcher shows expanded.
///
/// Deliberately separate from the selected container. Tying the two together
/// meant a group could not be collapsed — tapping the expanded header selected
/// the container that was already selected — and that looking into another
/// group switched the browser away from the page.
///
/// Container ids are nullable: null is the group of unassigned tabs.
@immutable
class AccordionExpansion {
  /// Expanded groups, least recently expanded first.
  final List<String?> order;

  const AccordionExpansion([this.order = const []]);

  /// The groups actually shown open.
  ///
  /// With [multiple] every expanded group is; otherwise only the most recently
  /// expanded one, as a single scrolling row has no room for more.
  Set<String?> displayed({required bool multiple}) =>
      multiple ? order.toSet() : {if (order.isNotEmpty) order.last};

  bool isExpanded(String? containerId, {required bool multiple}) =>
      displayed(multiple: multiple).contains(containerId);

  /// Collapses [containerId] if it is shown open, and expands it otherwise.
  ///
  /// Collapsing the one open group in single mode leaves none open, rather than
  /// falling back to whichever group was expanded before it.
  AccordionExpansion toggle(String? containerId, {required bool multiple}) {
    if (!isExpanded(containerId, multiple: multiple)) {
      return reveal(containerId);
    }

    return multiple
        ? AccordionExpansion([
            for (final id in order)
              if (id != containerId) id,
          ])
        : const AccordionExpansion();
  }

  /// Expands [containerId] and makes it the most recently expanded group.
  AccordionExpansion reveal(String? containerId) => AccordionExpansion([
    for (final id in order)
      if (id != containerId) id,
    containerId,
  ]);

  @override
  bool operator ==(Object other) =>
      other is AccordionExpansion && listEquals(other.order, order);

  @override
  int get hashCode => Object.hashAll(order);
}

/// A selected tab and the container it belongs to.
typedef SelectedTabContainer = ({String tabId, String? containerId});

/// The selected tab paired with its own container, or null while either is
/// unknown.
///
/// One value rather than the selected tab and `selectedTabContainerIdProvider`
/// read side by side. Read from inside a selected-tab listener, the container
/// provider had not caught up yet and still answered for the *previous* tab, so
/// selecting a tab in container A opened the group of the tab before it — in
/// the single row that closed A, the group the user had just picked the tab
/// from. Pairing the two here makes a stale container impossible to attribute
/// to a new tab.
@riverpod
SelectedTabContainer? _selectedTabWithContainer(Ref ref) {
  final tabId = ref.watch(selectedTabProvider);
  if (tabId == null) return null;

  return switch (ref.watch(watchContainerTabIdProvider(tabId))) {
    AsyncData(:final value) => (tabId: tabId, containerId: value),
    _ => null,
  };
}

/// The accordion's expanded groups, which follow the selected tab.
///
/// Whenever a different tab gets selected — from the switcher, a gesture, a
/// shortcut or a link — its group is expanded so the active tab stays in view,
/// and so is the new group of a selected tab moved to another container.
/// Groups the user collapsed stay collapsed until then.
@riverpod
class AccordionExpansionController extends _$AccordionExpansionController {
  /// The selection whose group was last opened, so the same selection
  /// resolving again does not reopen a group the user has since closed.
  SelectedTabContainer? _revealedFor;

  @override
  AccordionExpansion build() {
    ref.listen(
      _selectedTabWithContainerProvider,
      (previous, next) => _reveal(next),
    );

    final current = ref.read(_selectedTabWithContainerProvider);
    if (current == null) return const AccordionExpansion();

    _revealedFor = current;
    return AccordionExpansion([current.containerId]);
  }

  void _reveal(SelectedTabContainer? selection) {
    if (selection == null || selection == _revealedFor) return;

    _revealedFor = selection;
    state = state.reveal(selection.containerId);
  }

  void toggle(String? containerId, {required bool multiple}) {
    state = state.toggle(containerId, multiple: multiple);
  }
}
