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
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/services/toolbar_button_resolution.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/models/contextual_toolbar_scope.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/toolbar_button_registry.dart';

class ContextualToolbar extends HookConsumerWidget {
  const ContextualToolbar({
    super.key,
    required this.selectedTabId,
    required this.displayedSheet,
    this.axis = Axis.horizontal,
  });

  final String? selectedTabId;
  final Sheet? displayedSheet;

  /// Layout direction, forwarded to [ContextualToolbarView]. Vertical for the
  /// side rail.
  final Axis axis;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabState = ref.watch(tabStateProvider(selectedTabId));
    final configs = ref.watch(effectiveToolbarButtonConfigsProvider);

    final scope = ContextualToolbarScope(
      selectedTabId: selectedTabId,
      displayedSheet: displayedSheet,
      tabState: tabState,
      isPreview: false,
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

    final buttons = resolvedButtons
        .map((button) => _buildButton(scope, context, ref, button))
        .toList();

    return ContextualToolbarView(buttons: buttons, axis: axis);
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

class ContextualToolbarView extends StatelessWidget {
  const ContextualToolbarView({
    super.key,
    required this.buttons,
    this.axis = Axis.horizontal,
  });

  final List<Widget> buttons;

  /// Layout direction of the contextual button strip. Horizontal for the
  /// top/bottom tab bar, vertical for the side rail.
  final Axis axis;

  static const _minButtonWidth = 48.0;

  @override
  Widget build(BuildContext context) {
    if (buttons.isEmpty) return const SizedBox.shrink();

    if (axis == Axis.vertical) {
      return LayoutBuilder(
        builder: (context, constraints) {
          // spaceEvenly needs a bounded height; in the rail the contextual
          // strip usually sits in an intrinsic (unbounded) slot, so fall back
          // to a min-sized fixed-height column there.
          final fitsEvenly =
              constraints.maxHeight.isFinite &&
              constraints.maxHeight >= _minButtonWidth * buttons.length;

          if (fitsEvenly) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: buttons,
            );
          }

          // Let buttons size to their natural height instead of clamping them
          // into fixed _minButtonWidth-tall slots: some buttons (e.g. the
          // tab-count box, which carries its own ToolbarButton padding) are
          // taller than that, and a short SizedBox + Center would clip them.
          //
          // UnconstrainedBox frees the horizontal axis so each button
          // shrink-wraps its content instead of stretching to the rail width
          // (the tab-count box's inner Center would otherwise fill it); the
          // Column then centers each on the cross axis.
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final button in buttons)
                UnconstrainedBox(
                  constrainedAxis: Axis.vertical,
                  child: button,
                ),
            ],
          );
        },
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final fitsEvenly =
            constraints.maxWidth >= _minButtonWidth * buttons.length;

        if (fitsEvenly) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: buttons,
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: buttons
                .map(
                  (button) => SizedBox(
                    width: _minButtonWidth,
                    child: Center(child: button),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
