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
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

part 'toolbar_visibility.g.dart';

enum ToolbarVisibility { visible, hidden, dismissed }

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

    return ToolbarVisibility.visible;
  }

  /// Hide toolbar via scroll. All guards checked internally.
  void requestHide() {
    if (state != ToolbarVisibility.visible) return;

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

  /// Force-show unconditionally + un-dismiss.
  void forceShow() {
    state = ToolbarVisibility.visible;
  }

  /// Dismiss toolbar (user swipe). Only affects this tab.
  void dismiss() {
    state = ToolbarVisibility.dismissed;
  }
}
