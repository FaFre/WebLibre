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
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/controllers/side_rail.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/browser_modules/bottom_app_bar.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

/// The splitter on the side panel's inner edge that resizes it: the boundary
/// line between panel and page, which is all it draws.
///
/// No grip rides on the line, deliberately — M3's adaptive guidance puts a
/// drag handle on a resizable pane divider, but a handle big enough to read as
/// one costs the tab list width the panel would rather spend on tabs. The line
/// widens and takes the accent under the pointer instead, and the panel keeps
/// its other ways in (swipe to dismiss, double tap to reset).
///
/// The drag drives [SideRailDragWidth], which the browser screen reads in place
/// of the saved width, so the panel and the page both follow it live. Only the
/// released width is saved. Dragging far enough towards the docked edge snaps
/// the panel to the icon rail, and dragging out again restores it; see
/// [BrowserTabBar.draggedRailWidth]. A double tap resets the default width.
class SideRailResizeHandle extends HookConsumerWidget {
  /// The strip at the panel's inner edge the handle draws its line in.
  ///
  /// Equal to [BrowserTabBar.panelInset], which is the width the tab rows and
  /// the toolbar block above them already hold clear of that edge — so the
  /// line lives in padding the panel was spending anyway and costs the tab
  /// list nothing. It must never exceed that inset, or it would be drawing on
  /// top of the rows.
  static const laneWidth = BrowserTabBar.panelInset;

  /// Width of the area that takes the resize drag, which reaches [laneWidth]
  /// further in than the line is drawn so the pointer has something to land
  /// on. That part is over the tab rows, so only the *drag* extends there —
  /// the double tap stays inside the lane, because a double-tap recogniser
  /// that far in would hold up every tap on a row for its timeout.
  static const hitWidth = laneWidth * 2;

  /// How long the line takes to follow hover and drag.
  static const _duration = Duration(milliseconds: 150);

  final bool railOnLeft;

  /// The rail's width when the drag starts.
  final double railWidth;

  const SideRailResizeHandle({
    super.key,
    required this.railOnLeft,
    required this.railWidth,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hovered = useState(false);
    final dragging = useState(false);
    final startWidth = useRef(0.0);
    final travel = useRef(0.0);
    final scheme = Theme.of(context).colorScheme;

    Future<void> save(double width) {
      return ref
          .read(saveGeneralSettingsControllerProvider.notifier)
          .save((settings) => settings.copyWith.sideRailWidth(width));
    }

    Future<void> finish() async {
      dragging.value = false;

      final notifier = ref.read(sideRailDragWidthProvider.notifier);
      final width = notifier.end();
      if (width == null) return;

      try {
        // Straight to the repository: SaveGeneralSettingsController turns a
        // failure into its own state and returns normally, so nothing would be
        // caught here and the drag width would override the saved one for good.
        await ref
            .read(generalSettingsRepositoryProvider.notifier)
            .updateSettings(
              (settings) => settings.copyWith.sideRailWidth(width),
            );
      } catch (error, stackTrace) {
        logger.e(
          'Failed to save the side panel width',
          error: error,
          stackTrace: stackTrace,
        );
        notifier.cancel();
      }
    }

    final active = hovered.value || dragging.value;

    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      onEnter: (_) => hovered.value = true,
      onExit: (_) => hovered.value = false,
      child: GestureDetector(
        // Translucent, not opaque: the part of the hit area that reaches over
        // the panel's padding still lets the tab list under it see the
        // pointer, so a vertical drag there scrolls the list as it always did
        // while a horizontal one resizes.
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: (_) {
          dragging.value = true;
          startWidth.value = railWidth;
          travel.value = 0.0;
        },
        onHorizontalDragUpdate: (details) {
          travel.value += details.delta.dx;
          // Dragging away from the docked edge widens the panel.
          final rawWidth =
              startWidth.value + (railOnLeft ? travel.value : -travel.value);
          ref
              .read(sideRailDragWidthProvider.notifier)
              .update(
                BrowserTabBar.draggedRailWidth(
                  rawWidth,
                  windowWidth: MediaQuery.sizeOf(context).width,
                ),
              );
        },
        onHorizontalDragEnd: (_) => unawaited(finish()),
        onHorizontalDragCancel: () => unawaited(finish()),
        child: Semantics(
          label: 'Resize side panel',
          child: Align(
            alignment: railOnLeft
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: SizedBox(
              width: laneWidth,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onDoubleTap: () =>
                    unawaited(save(BrowserTabBar.expandedRailWidth)),
                child: Align(
                  // The lane's inner edge is the panel/page boundary, so the
                  // line that marks it is the whole handle: a hairline at rest
                  // that thickens and takes the accent while it is worked.
                  alignment: railOnLeft
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: AnimatedContainer(
                    duration: _duration,
                    width: active ? 3.0 : 1.0,
                    // Align hands its child loose constraints, so the line has
                    // to ask for the height rather than inherit it.
                    height: double.infinity,
                    color: active ? scheme.primary : scheme.outlineVariant,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
