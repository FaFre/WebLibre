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
 */
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Centres [sliver] in the viewport while its content is shorter than the space
/// left for it, and gets out of the way as soon as it is not.
///
/// A scroll surface top-aligns, which is right for a feed and wrong for a page:
/// with only a couple of short sections switched on, the browser home would
/// otherwise hold its content against the top edge with two thirds of the
/// screen empty underneath. That reads as a layout that failed rather than as a
/// sparse one. Once the content is tall enough to scroll there is no free space
/// to distribute and this behaves exactly like its child.
///
/// The leading space is measured against what is left of the viewport *after*
/// the slivers before this one, so anything the host keeps outside — a pinned
/// search pill, say — centres the content in the region below itself rather
/// than being counted as content.
class SliverCenterOnUnderflow extends SingleChildRenderObjectWidget {
  const SliverCenterOnUnderflow({super.key, Widget? sliver})
    : super(child: sliver);

  @override
  RenderSliverCenterOnUnderflow createRenderObject(BuildContext context) =>
      RenderSliverCenterOnUnderflow();
}

/// Leading padding that can only be known once the child has been laid out.
///
/// [RenderSliverEdgeInsetsPadding] already does every part of this that is
/// fiddly — paint and cache offsets, overlap, hit-test extent, scroll-offset
/// corrections — so the only thing added here is running it twice: once with no
/// padding to learn the child's scroll extent, and again with the padding that
/// extent implies.
///
/// The second pass only happens when the content actually underflows, which is
/// the case with little in it. Content long enough for the double layout to
/// cost anything leaves no free space, so it is laid out once.
class RenderSliverCenterOnUnderflow extends RenderSliverEdgeInsetsPadding {
  EdgeInsets _padding = EdgeInsets.zero;

  @override
  EdgeInsets get resolvedPadding => _padding;

  @override
  void performLayout() {
    _padding = EdgeInsets.zero;
    super.performLayout();

    final child = this.child;
    if (child == null) return;

    // The viewport is about to lay everything out again against a corrected
    // offset; measuring against this pass would centre on a stale extent.
    if (geometry!.scrollOffsetCorrection != null) return;

    final free =
        constraints.viewportMainAxisExtent -
        constraints.precedingScrollExtent -
        child.geometry!.scrollExtent;

    if (!free.isFinite || free <= 0) return;

    _padding = _leading(free / 2);
    super.performLayout();
  }

  /// [free] as an inset on the edge the child grows away from, which is what
  /// [RenderSliverEdgeInsetsPadding.beforePadding] reads back.
  EdgeInsets _leading(double extent) =>
      switch (applyGrowthDirectionToAxisDirection(
        constraints.axisDirection,
        constraints.growthDirection,
      )) {
        AxisDirection.up => EdgeInsets.only(bottom: extent),
        AxisDirection.down => EdgeInsets.only(top: extent),
        AxisDirection.left => EdgeInsets.only(right: extent),
        AxisDirection.right => EdgeInsets.only(left: extent),
      };
}
