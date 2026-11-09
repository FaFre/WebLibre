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
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/providers/split_view.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

part 'toolbar_visibility.g.dart';

enum ToolbarVisibility { visible, hidden, dismissed }

/// Per tab, except that the two tabs of a shown split pair share one state:
/// the bars belong to the pair, so focus moving between the panes must not
/// move them and resize both pages. Dismissing applies to the pair. Scroll
/// auto-hide is off while both pages are shown: it would resize both, and
/// could flip the layout between side by side and stacked. With "Show only
/// this page" chosen it works as for a single tab.
@Riverpod(keepAlive: true)
class ToolbarVisibilityController extends _$ToolbarVisibilityController {
  @override
  ToolbarVisibility build(String? tabId) {
    // Show toolbar when loading starts
    ref.listen(tabStatesProvider.select((tabs) => tabs[tabId]?.isLoading), (
      previous,
      next,
    ) {
      if (!ref.read(generalSettingsWithDefaultsProvider).autoHideTabBar) {
        return;
      }
      if (next == true) {
        show();
      }
    });

    // Deliberately no trigger on the session history (tabHistoryStates).
    // GeckoView only reports that list from a session-store flush, which runs
    // on `browser.sessionstore.interval` (10 s), so it lands up to ten seconds
    // after the navigation — by then the user is reading and has scrolled the
    // bar away, and showing it again reads as the bar popping up mid-scroll
    // (https://github.com/FaFre/WebLibre/issues/653). Loading start above
    // already covers navigations, as it does in Fenix.

    // Force-show when GeckoView requests toolbar expansion
    // (e.g. touch on form input)
    ref.listen<bool>(
      tabStatesProvider.select(
        (tabs) => tabs[tabId]?.showToolbarAsExpanded ?? false,
      ),
      (previous, next) {
        if (next && previous != next) {
          forceShow();
        }
      },
    );

    // Joining a pair or getting a new partner: take the pair's state. Both
    // pages coming back on screen: a bar scrolled away returns.
    ref.listen(
      splitPairShownProvider.select(
        (pair) => (
          partner: tabId == null ? null : pair?.partnerOf(tabId),
          focusedOnly: pair?.focusedOnly ?? false,
        ),
      ),
      (previous, next) {
        final partner = next.partner;
        if (partner == null) return;
        if (partner != previous?.partner) {
          _joinPair(partner);
        } else if (previous?.focusedOnly == true && !next.focusedOnly) {
          state = _paired(state);
        }
      },
    );

    if (_shownPartner() case final partner?
        when ref.exists(toolbarVisibilityControllerProvider(partner))) {
      return _paired(ref.read(toolbarVisibilityControllerProvider(partner)));
    }
    return ToolbarVisibility.visible;
  }

  /// [tabId]'s partner while it is one of the shown split pair.
  String? _shownPartner() => tabId == null
      ? null
      : ref.read(splitPairShownProvider)?.partnerOf(tabId!);

  /// Whether [tabId] is one of the shown pair with both pages on screen,
  /// where scroll auto-hide is off.
  bool _bothPagesShown() {
    if (tabId == null) return false;
    final pair = ref.read(splitPairShownProvider);
    return pair != null && pair.contains(tabId!) && !pair.focusedOnly;
  }

  /// A state as it applies to the pair: a bar scrolled away comes back while
  /// both pages are shown, where auto-hide is off.
  ToolbarVisibility _paired(ToolbarVisibility value) =>
      value == ToolbarVisibility.hidden && _bothPagesShown()
      ? ToolbarVisibility.visible
      : value;

  /// The selected pane's state wins, so the bars do not move when a pair forms
  /// or a pane is replaced. Each member's listener runs this; the selected
  /// one keeps its own state.
  void _joinPair(String partner) {
    final selected = ref.read(selectedTabProvider);
    final partnerProvider = toolbarVisibilityControllerProvider(partner);
    state = selected == partner && ref.exists(partnerProvider)
        ? _paired(ref.read(partnerProvider))
        : _paired(state);
  }

  /// Sets [value] here and on the shown partner, if any.
  void _setForPair(ToolbarVisibility value) {
    state = value;
    if (_shownPartner() case final partner?) {
      ref.read(toolbarVisibilityControllerProvider(partner).notifier).state =
          value;
    }
  }

  /// Hide toolbar via scroll. All guards checked internally.
  void requestHide() {
    if (state != ToolbarVisibility.visible) return;
    // No scroll auto-hide while both pages are shown: see the class comment.
    if (_bothPagesShown()) return;

    final settings = ref.read(generalSettingsWithDefaultsProvider);
    if (!settings.autoHideTabBar) return;

    final isLoading = ref.read(tabStatesProvider)[tabId]?.isLoading ?? false;
    if (isLoading) return;

    final viewportService = ref.read(viewportServiceProvider);
    if (!viewportService.isBrowserHandlingScrollEnabled) return;

    state = ToolbarVisibility.hidden;
  }

  /// Show toolbar (scroll-up, tab change, loading start, etc).
  /// Won't show if manually dismissed — use forceShow() for that.
  void show() {
    if (state != ToolbarVisibility.hidden) return;
    state = ToolbarVisibility.visible;
  }

  /// Force-show unconditionally + un-dismiss. Applies to the shown split
  /// partner too.
  void forceShow() => _setForPair(ToolbarVisibility.visible);

  /// Dismiss toolbar (user swipe). Affects this tab and, while it is one of
  /// the shown split pair, its partner.
  void dismiss() => _setForPair(ToolbarVisibility.dismissed);
}
