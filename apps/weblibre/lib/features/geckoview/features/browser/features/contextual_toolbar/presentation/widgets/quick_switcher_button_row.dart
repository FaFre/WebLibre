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
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/sheet.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/data/providers/toolbar_button_configs.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_button_spec.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_config_location.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/services/toolbar_button_resolution.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/models/contextual_toolbar_scope.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/toolbar_button_registry.dart';

/// The switcher bar's cross-axis extent (height when horizontal, width on the
/// side rail). Mirrors `BrowserTabBar.quickTabSwitcherHeight`; kept as a local
/// const to avoid a circular import with the bar widget that hosts this row.
const double _switcherExtent = 48.0;

/// Trailing fixed button cluster for the quick tab switcher bar. Reuses the
/// contextual toolbar's button registry and resolution logic against the
/// independently-persisted [ToolbarConfigLocation.quickSwitcher] configuration.
///
/// Pins to the trailing end of the bar while the tab chips keep the remaining
/// scrollable space. Each button is scaled to fit the bar's cross-axis extent
/// (reused [ToolbarButton]s are taller than the 48px bar), and the cluster
/// scrolls along the bar axis so enabling many buttons can never overflow — the
/// hosting bar additionally caps how much room the cluster may claim. Renders
/// nothing when no buttons are enabled.
class QuickSwitcherButtonRow extends HookConsumerWidget {
  const QuickSwitcherButtonRow({
    super.key,
    required this.selectedTabId,
    required this.displayedSheet,
    this.axis = Axis.horizontal,
  });

  final String? selectedTabId;
  final Sheet? displayedSheet;

  /// Layout direction of the switcher bar; vertical for the side rail.
  final Axis axis;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabState = ref.watch(tabStateProvider(selectedTabId));
    final configs = ref.watch(
      effectiveToolbarButtonConfigsProvider(
        ToolbarConfigLocation.quickSwitcher,
      ),
    );

    final scope = ContextualToolbarScope(
      selectedTabId: selectedTabId,
      displayedSheet: displayedSheet,
      tabState: tabState,
      isPreview: false,
      location: ToolbarConfigLocation.quickSwitcher,
    );

    final resolvedButtons = useMemoized(
      () => resolveVisibleContextualToolbarButtons(
        configs: configs.value,
        knownButtonIds: knownToolbarButtonIds,
        isPrimaryAvailable: (buttonId) {
          final def = toolbarButtonRegistryById[buttonId];
          return def?.isPrimaryAvailable?.call(scope, ref) ?? true;
        },
      ),
      [configs, scope],
    );

    if (resolvedButtons.isEmpty) {
      return const SizedBox.shrink();
    }

    final isVertical = axis == Axis.vertical;

    final buttons = resolvedButtons
        .map((button) => _buildButton(scope, context, ref, button))
        .toList();

    // Bound each button to the bar's cross-axis extent and scale down (never
    // clip) so a taller [ToolbarButton] can't overflow the switcher bar.
    final fittedButtons = [
      for (final button in buttons)
        SizedBox(
          height: isVertical ? null : _switcherExtent,
          width: isVertical ? _switcherExtent : null,
          child: FittedBox(fit: BoxFit.scaleDown, child: button),
        ),
    ];

    // Scroll along the bar axis: the host caps the cluster's main-axis extent,
    // and anything beyond that scrolls instead of stealing the chips' space.
    return SizedBox(
      height: isVertical ? null : _switcherExtent,
      width: isVertical ? _switcherExtent : null,
      child: SingleChildScrollView(
        scrollDirection: axis,
        child: isVertical
            ? Column(mainAxisSize: MainAxisSize.min, children: fittedButtons)
            : Row(mainAxisSize: MainAxisSize.min, children: fittedButtons),
      ),
    );
  }

  Widget _buildButton(
    ContextualToolbarScope scope,
    BuildContext context,
    WidgetRef ref,
    ContextualToolbarButtonResolution button,
  ) {
    final def = toolbarButtonRegistryById[button.buttonId];
    if (def == null) return const SizedBox.shrink();

    final child = def.builder(scope, context, ref);

    if (button.isEnabled) {
      return child;
    }

    return Opacity(opacity: 0.38, child: IgnorePointer(child: child));
  }
}
