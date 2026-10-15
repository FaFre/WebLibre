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

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:weblibre/presentation/widgets/pointer_scrollable_sheet.dart';

/// Builds the content of a [FittedPointerScrollableSheet].
///
/// [contentEnd] is a sliver that must be the last one in the scroll view
/// driven by [scrollController]: it is where the sheet learns how tall the
/// content is. It takes no space.
typedef FittedSheetBuilder =
    Widget Function(
      BuildContext context,
      ScrollController scrollController,
      Widget contentEnd,
    );

/// A [PointerScrollableSheet] that is as tall as its content, up to
/// [maxInitialChildSize] of the window (#664).
///
/// A sheet sized by a fixed fraction leaves its bottom blank whenever it has
/// little to show: the ⋮ menu on the home screen, with the sections that act on
/// a page left out, filled barely half of the 85% it opened at. This one opens
/// at its content's height instead, and cannot be dragged up past it into
/// empty space. Content taller than [maxInitialChildSize] opens at that cap
/// and can be dragged up to its full height, the window's at most, as before.
///
/// The sheet follows its content when that changes — a section expanding, a
/// row folding away — as long as the user has not resized it, or left it at
/// its full height. Each change lands a frame late: the content is measured
/// while it is laid out, which is too late to resize the sheet in the same
/// frame.
///
/// The content is the sheet's whole height less its scroll view's, which is
/// whatever sits around the list (a drag handle, a pinned header, a bottom
/// row, the surface's padding), plus everything the list scrolls through.
/// Content that sizes itself to the viewport (a `SliverFillRemaining`) would
/// chase its own measurement, so it does not belong in one of these. The
/// slivers a lazy list has not built yet are estimated, which only matters
/// once the content is taller than the window.
class FittedPointerScrollableSheet extends HookWidget {
  /// The tallest the sheet opens at, as a fraction of the window's height.
  final double maxInitialChildSize;

  /// The size the sheet closes at when dragged down, as a fraction of the
  /// window's height. Halved for a sheet that opens below twice this, so a
  /// short sheet still needs a deliberate drag to close.
  final double minChildSize;

  final DraggableScrollableController? controller;
  final FittedSheetBuilder builder;

  const FittedPointerScrollableSheet({
    required this.builder,
    this.maxInitialChildSize = 0.85,
    this.minChildSize = 0.4,
    this.controller,
    super.key,
  }) : assert(maxInitialChildSize > 0 && maxInitialChildSize <= 1),
       assert(minChildSize >= 0);

  /// Changes smaller than this are rounding, not content.
  static const _tolerance = 0.5;

  @override
  Widget build(BuildContext context) {
    final fallbackController = useDraggableScrollableController();
    final sheetController = controller ?? fallbackController;

    final measurement = useMemoized(_SheetMeasurement.new);
    final contentHeight = useState<double?>(null);
    // The sizes the sheet was last built with, for the measurement's
    // callback, which runs between frames.
    final sizes = useRef((initial: maxInitialChildSize, max: 1.0));

    measurement.onChanged = (height) {
      if (!context.mounted) return;

      // A sheet the user has resized keeps its size when its sizes change. One
      // left at its full height should still grow with its content, so it is
      // moved along once it has been rebuilt with the new sizes. So is one
      // that can no longer show its content at all: chrome that grew taller
      // than the sheet (the arrangement header of a menu with every section
      // switched off) would otherwise leave it stuck at its old height.
      final follow =
          sheetController.isAttached &&
          (measurement.overflowing ||
              sheetController.size >=
                  sizes.value.max - precisionErrorTolerance);

      contentHeight.value = height;

      if (!follow) return;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted || !sheetController.isAttached) return;

        final target = sizes.value.initial;
        if (sheetController.size < target - precisionErrorTolerance) {
          sheetController.jumpTo(target);
        }
      });
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        // The height the sheet's sizes are fractions of.
        final windowHeight = constraints.maxHeight;
        final measured = contentHeight.value;
        final fit = (measured == null || !windowHeight.isFinite)
            ? null
            : clampDouble(measured / windowHeight, 0.05, 1.0);

        // Until the first measurement, which is the sheet's first frame, the
        // sheet is as it would be with nothing to fit.
        final maxChildSize = fit ?? 1.0;
        final initialChildSize = math.min(
          fit ?? maxInitialChildSize,
          maxInitialChildSize,
        );
        final minChildSize = math.min(this.minChildSize, initialChildSize / 2);
        sizes.value = (initial: initialChildSize, max: maxChildSize);
        measurement
          ..windowHeight = windowHeight
          ..measuringHeight = maxInitialChildSize * windowHeight;

        return PointerScrollableSheet(
          controller: sheetController,
          expand: false,
          initialChildSize: initialChildSize,
          minChildSize: minChildSize,
          maxChildSize: maxChildSize,
          builder: (context, scrollController) => _SheetHeightProbe(
            measurement: measurement,
            child: builder(
              context,
              scrollController,
              _ContentEnd(measurement: measurement),
            ),
          ),
        );
      },
    );
  }
}

/// What the sheet's two probes found out during layout, handed over to the
/// sheet after the frame.
class _SheetMeasurement {
  /// The height the sheet's sizes are fractions of.
  double windowHeight = double.infinity;

  /// The height to measure the content at when the sheet is too short to.
  double measuringHeight = double.infinity;

  /// The height the content was last laid out at.
  double? sheetHeight;

  /// Whether the chrome left the scroll view no room the last time the
  /// content was laid out.
  bool squeezed = false;

  /// Whether the content is laid out taller than the sheet, because the sheet
  /// was too short to measure it at.
  bool overflowing = false;

  /// Called after the frame in which the content's height changed.
  ValueSetter<double>? onChanged;

  double? _contentHeight;
  bool _scheduled = false;

  void report(double contentHeight) {
    final previous = _contentHeight;
    if (previous != null &&
        (contentHeight - previous).abs() <=
            FittedPointerScrollableSheet._tolerance) {
      return;
    }
    _contentHeight = contentHeight;

    // A viewport may lay its slivers out more than once a frame; the sheet
    // only hears about the last.
    if (_scheduled) return;
    _scheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      onChanged?.call(_contentHeight!);
    });
  }
}

/// Records the height the sheet gives its content, and makes sure it can be
/// measured at it.
class _SheetHeightProbe extends SingleChildRenderObjectWidget {
  final _SheetMeasurement measurement;

  const _SheetHeightProbe({required this.measurement, super.child});

  @override
  _RenderSheetHeightProbe createRenderObject(BuildContext context) =>
      _RenderSheetHeightProbe(measurement);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSheetHeightProbe renderObject,
  ) {
    renderObject.measurement = measurement;
  }
}

/// The content's height is its chrome's plus its list's, and the chrome's is
/// read off the sheet less the list's viewport. That fails once the chrome
/// takes the whole sheet and squeezes the viewport out of it. The content is
/// then laid out a second time at [_SheetMeasurement.measuringHeight], where
/// the viewport shows again, and kept at that height, top-aligned and
/// clipped, until the sheet has grown to fit it a frame later. It never
/// overflows on the way.
///
/// The content gets the sheet's height as a maximum rather than a tight one.
/// A tightly constrained child is a relayout boundary: chrome added to it
/// would lay it out again without this probe ever running, and a squeezed
/// viewport would go unmeasured. Content fills the height it is offered (a
/// column, a scroll view, a [Material]), so it is laid out exactly as before.
class _RenderSheetHeightProbe extends RenderProxyBox {
  _SheetMeasurement measurement;

  _RenderSheetHeightProbe(this.measurement);

  final _clipLayer = LayerHandle<ClipRectLayer>();
  bool _overflowing = false;

  BoxConstraints _contentConstraints(double height) => BoxConstraints(
    minWidth: constraints.minWidth,
    maxWidth: constraints.maxWidth,
    maxHeight: height,
  );

  void _layoutContent(RenderBox child, double height) {
    // Read before the child is laid out: the content's own probe runs inside
    // that layout.
    measurement.sheetHeight = height;
    child.layout(_contentConstraints(height), parentUsesSize: true);
  }

  @override
  void performLayout() {
    final child = this.child;
    _overflowing = false;
    if (child == null) {
      size = constraints.smallest;
      measurement.overflowing = false;
      return;
    }

    final sheetHeight = constraints.maxHeight;
    _layoutContent(child, sheetHeight);

    if (measurement.squeezed) {
      final measuringHeight = measurement.measuringHeight;
      if (measuringHeight.isFinite && measuringHeight > sheetHeight) {
        _layoutContent(child, measuringHeight);
        _overflowing = true;
      }

      // Chrome taller than even that: the sheet opens at the cap and can be
      // dragged up to the window, where it is measured for real.
      if (measurement.squeezed && measurement.windowHeight.isFinite) {
        measurement.report(measurement.windowHeight);
      }
    }

    measurement.overflowing = _overflowing;
    size = constraints.constrain(child.size);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (!_overflowing) {
      _clipLayer.layer = null;
      super.paint(context, offset);
      return;
    }

    _clipLayer.layer = context.pushClipRect(
      needsCompositing,
      offset,
      Offset.zero & size,
      super.paint,
      oldLayer: _clipLayer.layer,
    );
  }

  @override
  Rect? describeApproximatePaintClip(RenderObject child) =>
      _overflowing ? Offset.zero & size : null;

  @override
  void dispose() {
    _clipLayer.layer = null;
    super.dispose();
  }
}

/// The sliver [FittedSheetBuilder] hands out as `contentEnd`.
class _ContentEnd extends LeafRenderObjectWidget {
  final _SheetMeasurement measurement;

  const _ContentEnd({required this.measurement});

  @override
  _RenderContentEnd createRenderObject(BuildContext context) =>
      _RenderContentEnd(measurement);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderContentEnd renderObject,
  ) {
    renderObject.measurement = measurement;
  }
}

/// Takes no space, and reports the height the sheet needs to show everything
/// before it: the sheet's height less the viewport's, plus the scroll extent
/// of the slivers ahead of it.
class _RenderContentEnd extends RenderSliver {
  _SheetMeasurement measurement;

  _RenderContentEnd(this.measurement);

  @override
  void performLayout() {
    geometry = SliverGeometry.zero;

    final sheetHeight = measurement.sheetHeight;
    final viewportHeight = constraints.viewportMainAxisExtent;
    final contentExtent = constraints.precedingScrollExtent;
    // Chrome that squeezes the viewport out of the sheet no longer shows how
    // tall it is; the sheet's probe measures it again at a taller height.
    measurement.squeezed = viewportHeight <= 0;
    if (sheetHeight == null ||
        measurement.squeezed ||
        !contentExtent.isFinite) {
      return;
    }

    measurement.report(sheetHeight - viewportHeight + contentExtent);
  }
}
