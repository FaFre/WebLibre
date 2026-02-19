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

    // Show toolbar on navigation (history state change)
    ref.listen(tabStatesProvider.select((tabs) => tabs[tabId]?.historyState), (
      previous,
      next,
    ) {
      if (!ref.read(generalSettingsWithDefaultsProvider).autoHideTabBar) {
        return;
      }
      if (next != null && previous != null && previous != next) {
        show();
      }
    });

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
    final settings = ref.read(generalSettingsWithDefaultsProvider);
    if (!settings.autoHideTabBar) return;

    final isLoading = ref.read(tabStatesProvider)[tabId]?.isLoading ?? false;
    if (isLoading) return;

    final viewportService = ref.read(viewportServiceProvider);
    if (!viewportService.isBrowserHandlingScrollEnabled) return;

    if (state == ToolbarVisibility.dismissed) return;

    state = ToolbarVisibility.hidden;
  }

  /// Show toolbar (scroll-up, tab change, loading start, etc).
  /// Won't show if manually dismissed — use forceShow() for that.
  void show() {
    if (state == ToolbarVisibility.dismissed) return;
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
