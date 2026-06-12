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

/// Keeps the "active" chip of a horizontally-scrolling chip row centered in
/// its viewport, reliably even when that chip is far outside the currently
/// built (lazy) range.
///
/// A plain [Scrollable.ensureVisible] is not enough for these rows: the chips
/// live in a horizontal `ListView.builder`, so an active chip outside the
/// build/cache range has no `BuildContext` and there is nothing to scroll to.
/// Their widths also vary (titles, badges, hierarchy glyphs), so a single
/// index-proportional jump usually lands the target close but not exactly.
///
/// This hook runs a short, bounded converge loop instead. Each pass either:
///   * centers the chip precisely with [Scrollable.ensureVisible] (when the
///     chip is built and therefore has a context), finishing the loop; or
///   * jumps to an index-proportional estimate of the chip's centered offset
///     to pull it into the build/cache range, then retries on the next frame.
///
/// When the estimate is too far off for the chip to build (most likely in the
/// accordion, whose rows mix wide container headers with narrow tab chips),
/// later passes fan out from the estimate in alternating viewport-sized steps
/// so the search window sweeps across the error instead of stalling. The
/// target enters the cache range within a few passes and the final
/// `ensureVisible` snaps it to the exact center — handling the "calculation is
/// a bit off" (variable widths), "doesn't work at all" (metrics not ready on
/// the first frame, e.g. two stacked rows), and far-off-estimate cases.
///
/// The routine re-runs whenever [activeId] changes or its position within
/// [orderedIds] changes (reorders, insertions, container switches), and is
/// suppressed while [isUserScrolling] returns true so it never fights a manual
/// scroll.
void useScrollToActiveChip<K>({
  required ScrollController controller,
  required GlobalKey activeChipKey,
  required K? activeId,
  required List<K> orderedIds,
  required bool Function() isUserScrolling,
  Duration animationDuration = const Duration(milliseconds: 200),
  int maxPasses = 8,
}) {
  // Index of the active chip drives both the estimate and the effect's
  // re-run trigger: a selection change, a reorder, or an insertion that
  // shifts the active chip all change this value.
  final activeIndex = activeId == null ? -1 : orderedIds.indexOf(activeId);
  final totalCount = orderedIds.length;

  useEffect(() {
    if (activeIndex < 0) return null;
    if (isUserScrolling()) return null;

    var cancelled = false;

    void runPass(int pass) {
      if (cancelled || isUserScrolling()) return;

      void scheduleNext() {
        if (pass >= maxPasses) return;
        WidgetsBinding.instance.addPostFrameCallback((_) => runPass(pass + 1));
      }

      if (!controller.hasClients) {
        // Viewport not attached yet (common on the first frame, and worse for
        // two stacked rows); wait for it to come up.
        scheduleNext();
        return;
      }

      final chipContext = activeChipKey.currentContext;
      if (chipContext != null) {
        // The chip is built: snap it to the exact center and stop. Any late
        // layout shift (image/badge resize) is small enough to ignore.
        unawaited(
          Scrollable.ensureVisible(
            chipContext,
            alignment: 0.5,
            duration: animationDuration,
            curve: Curves.easeInOut,
          ),
        );
        return;
      }

      // The chip is outside the build/cache range, so there is no context to
      // center yet. Jump to an estimate of its offset to pull it into range,
      // then refine on the next pass once it has been built.
      final position = controller.position;
      final maxExtent = position.maxScrollExtent;
      final viewport = position.viewportDimension;
      if (maxExtent <= 0 || totalCount <= 0) {
        // Metrics not ready (or everything fits): retry until they settle.
        scheduleNext();
        return;
      }

      // Index-proportional estimate of the chip's centered offset, assuming
      // roughly uniform widths. Total content spans [0, maxExtent + viewport].
      final contentExtent = maxExtent + viewport;
      final estimatedCenter = (activeIndex + 0.5) / totalCount * contentExtent;
      final estimate = estimatedCenter - viewport / 2;

      // Uniform widths are only an approximation — worst for the accordion,
      // whose rows mix wide container headers with tab chips. When the first
      // estimate doesn't surface the chip, fan out from it in alternating
      // directions (pass 2: +1 viewport, pass 3: -1, pass 4: +2, ...) so the
      // search window sweeps across the mis-estimate instead of stalling on a
      // repeated identical jump. Each step overlaps the lazy cache, so the
      // chip is guaranteed to build within a few passes.
      final step = pass ~/ 2;
      final direction = pass.isOdd ? 1 : -1;
      final target = (estimate + direction * step * viewport).clamp(
        0.0,
        maxExtent,
      );

      controller.jumpTo(target);
      scheduleNext();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => runPass(1));

    return () => cancelled = true;
  }, [activeId, activeIndex, totalCount]);
}
