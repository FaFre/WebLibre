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

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:weblibre/features/settings/presentation/widgets/toolbar_layout_content.dart';

/// A part of the toolbar the preview lets the user select, to change just its
/// settings.
///
/// Parts nest: a tap inside the selected part selects the part under the
/// finger one level deeper.
enum LayoutPart {
  /// The whole tab bar, address bar included.
  tabBar(null, ToolbarLayoutSection.tabBar),
  quickTabSwitcher(tabBar, ToolbarLayoutSection.quickTabSwitcher),
  tabChip(quickTabSwitcher, ToolbarLayoutSection.tabChips),
  contextualToolbar(tabBar, ToolbarLayoutSection.contextualToolbar),

  /// The tab count button, which opens the tab view.
  tabView(tabBar, ToolbarLayoutSection.tabView),

  /// The menu button. Its settings are the menu's own arrangement.
  menu(tabBar, null);

  const LayoutPart(this.parent, this.section);

  /// The part this one sits inside, or null for the outermost.
  final LayoutPart? parent;

  /// The settings section it opens; null for [menu], which opens the menu's.
  final ToolbarLayoutSection? section;

  /// This part and the parts around it, outermost first.
  List<LayoutPart> get path => [...?parent?.path, this];
}

/// Which part a tap selects.
///
/// [underPointer] are the parts under the finger, innermost first. With
/// nothing under it the selection clears. A tap inside the [current] part
/// selects the part one level deeper under the finger; one on the innermost
/// part keeps it; one anywhere else selects the outermost part there.
LayoutPart? nextLayoutPartSelection(
  List<LayoutPart> underPointer,
  LayoutPart? current,
) {
  if (underPointer.isEmpty) return null;

  final index = current == null ? -1 : underPointer.indexOf(current);
  if (index > 0) return underPointer[index - 1];
  if (index == 0) return current;
  return underPointer.last;
}

/// The parts at [position] in [root]'s coordinates, innermost first.
///
/// Hit-tests [root] directly, so it works under an [AbsorbPointer] or
/// [IgnorePointer] that keeps taps away from the preview's own widgets.
List<LayoutPart> layoutPartsAt(RenderBox root, Offset position) {
  final result = BoxHitTestResult();
  root.hitTest(result, position: position);

  final parts = <LayoutPart>[];
  for (final entry in result.path) {
    final target = entry.target;
    if (target is RenderMetaData) {
      final part = target.metaData;
      if (part is LayoutPart && (parts.isEmpty || parts.last != part)) {
        parts.add(part);
      }
    }
  }
  return parts;
}

/// [layoutPartsAt], also looking around [position] within [slop] when nothing
/// is right under it, so a part drawn smaller than a touch target can still
/// be hit with a finger.
List<LayoutPart> layoutPartsNear(
  RenderBox root,
  Offset position, {
  required double slop,
}) {
  final direct = layoutPartsAt(root, position);
  if (direct.isNotEmpty || slop <= 0) return direct;

  // Two rings around the point, the nearer first, so the closest part wins
  // and one smaller than the slop is not stepped over.
  for (final distance in [slop / 2, slop]) {
    for (final direction in const [
      Offset(0, -1),
      Offset(0, 1),
      Offset(-1, 0),
      Offset(1, 0),
      Offset(-1, -1),
      Offset(1, -1),
      Offset(-1, 1),
      Offset(1, 1),
    ]) {
      final parts = layoutPartsAt(root, position + direction * distance);
      if (parts.isNotEmpty) return parts;
    }
  }
  return const [];
}

/// Marks [child] as [part] of the preview, for [layoutPartsAt] and
/// [layoutPartRects]. Draws nothing itself: [PreviewPartHighlights] outlines
/// and labels the parts above the whole window, where no clip inside it (a
/// narrow side panel, a scrolling row of chips) can cut them.
class PreviewPartRegion extends StatelessWidget {
  const PreviewPartRegion({super.key, required this.part, required this.child});

  final LayoutPart part;
  final Widget child;

  @override
  Widget build(BuildContext context) => MetaData(
    metaData: part,
    behavior: HitTestBehavior.translucent,
    child: child,
  );
}

/// Where each of [parts] is drawn in [root], in its coordinates: the bounds
/// of every region of that part together, within [root]. A part not drawn at
/// all is left out.
Map<LayoutPart, Rect> layoutPartRects(RenderBox root, Set<LayoutPart> parts) {
  final bounds = Offset.zero & root.size;
  final rects = <LayoutPart, Rect>{};

  void visit(RenderObject object) {
    if (object is RenderMetaData &&
        object.metaData is LayoutPart &&
        parts.contains(object.metaData) &&
        object.hasSize &&
        object.attached) {
      final rect = MatrixUtils.transformRect(
        object.getTransformTo(root),
        Offset.zero & object.size,
      ).intersect(bounds);
      if (!rect.isEmpty) {
        final part = object.metaData as LayoutPart;
        rects[part] = rects[part]?.expandToInclude(rect) ?? rect;
      }
    }
    object.visitChildren(visit);
  }

  root.visitChildren(visit);
  return rects;
}

/// The outlines and labels of the preview's [selected] part, the part around
/// it, and the part the mouse is over ([hovered]), drawn over the window at
/// screen size from [rects] (on screen, relative to the window).
///
/// A label goes just above its part, below it when there is no room above,
/// and inside it when neither fits; always whole within the window and never
/// over another label. An outline's corner that sits in a corner of the
/// window takes the window's [windowRadius], so the window's clip does not
/// cut it.
class PreviewPartHighlights extends StatelessWidget {
  const PreviewPartHighlights({
    super.key,
    required this.rects,
    required this.selected,
    required this.hovered,
    required this.labelFor,
    this.windowRadius = Radius.zero,
  });

  final Map<LayoutPart, Rect> rects;
  final LayoutPart? selected;
  final LayoutPart? hovered;
  final String Function(LayoutPart part) labelFor;
  final Radius windowRadius;

  static const _partRadius = Radius.circular(4);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final surrounding = selected?.parent;
    final shownHover = hovered == selected ? null : hovered;
    final shownSelected = rects.containsKey(selected) ? selected : null;
    final hoverLabel = rects.containsKey(shownHover) ? shownHover : null;

    Widget outline(
      LayoutPart part, {
      required bool isSelected,
      required Size window,
    }) {
      final isHovered = !isSelected && part == shownHover;
      final rect = rects[part]!;
      return Positioned.fromRect(
        rect: rect,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isHovered
                ? colorScheme.onSurface.withValues(alpha: 0.08)
                : null,
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.primary.withValues(alpha: 0.5),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: outlineRadius(
              rect,
              window: window,
              windowRadius: windowRadius,
              partRadius: _partRadius,
            ),
          ),
        ),
      );
    }

    Widget label(LayoutPart part, {required bool isSelected}) => LayoutId(
      id: isSelected ? _LabelSlot.selected : _LabelSlot.hovered,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.inverseSurface,
          borderRadius: const BorderRadius.all(_partRadius),
        ),
        child: Text(
          labelFor(part),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? colorScheme.onPrimary
                : colorScheme.onInverseSurface,
          ),
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final window = constraints.biggest;
        return Stack(
          children: [
            if (surrounding != null &&
                surrounding != shownHover &&
                rects.containsKey(surrounding))
              outline(surrounding, isSelected: false, window: window),
            if (hoverLabel != null)
              outline(hoverLabel, isSelected: false, window: window),
            if (shownSelected != null)
              outline(shownSelected, isSelected: true, window: window),
            Positioned.fill(
              child: CustomMultiChildLayout(
                delegate: _LabelLayout(
                  selected: shownSelected == null ? null : rects[shownSelected],
                  hovered: hoverLabel == null ? null : rects[hoverLabel],
                ),
                children: [
                  // The selected label paints last, over everything else.
                  if (hoverLabel != null) label(hoverLabel, isSelected: false),
                  if (shownSelected != null)
                    label(shownSelected, isSelected: true),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// The corners of an outline around [rect] in a window of size [window]
/// whose corners are rounded by [windowRadius]: a corner of [rect] that lies
/// in a corner of the window follows the window's curve, every other corner
/// is [partRadius].
@visibleForTesting
BorderRadius outlineRadius(
  Rect rect, {
  required Size window,
  required Radius windowRadius,
  required Radius partRadius,
}) {
  const tolerance = 1.0;
  final atLeft = rect.left <= tolerance;
  final atTop = rect.top <= tolerance;
  final atRight = rect.right >= window.width - tolerance;
  final atBottom = rect.bottom >= window.height - tolerance;

  Radius corner(bool horizontal, bool vertical) =>
      horizontal && vertical ? windowRadius : partRadius;

  return BorderRadius.only(
    topLeft: corner(atLeft, atTop),
    topRight: corner(atRight, atTop),
    bottomLeft: corner(atLeft, atBottom),
    bottomRight: corner(atRight, atBottom),
  );
}

enum _LabelSlot { selected, hovered }

/// Places the labels of the [selected] and [hovered] parts around their
/// rects, whole within the space they are given. The selected label is placed
/// first; the hovered one then takes the first spot that does not cover it:
/// beside it, else below its part, else inside.
class _LabelLayout extends MultiChildLayoutDelegate {
  _LabelLayout({required this.selected, required this.hovered});

  final Rect? selected;
  final Rect? hovered;

  static const _gap = 4.0;

  @override
  void performLayout(Size size) {
    final placed = <Rect>[];
    for (final (slot, anchor) in [
      (_LabelSlot.selected, selected),
      (_LabelSlot.hovered, hovered),
    ]) {
      if (anchor == null || !hasChild(slot)) continue;
      final childSize = layoutChild(slot, BoxConstraints.loose(size));
      final position = _place(size, childSize, anchor, placed);
      positionChild(slot, position);
      placed.add(position & childSize);
    }
  }

  static Offset _place(
    Size size,
    Size childSize,
    Rect anchor,
    List<Rect> placed,
  ) {
    final maxX = math.max(0.0, size.width - childSize.width);
    final maxY = math.max(0.0, size.height - childSize.height);

    final rows = [
      if (anchor.top - childSize.height >= 0) anchor.top - childSize.height,
      if (anchor.bottom + childSize.height <= size.height) anchor.bottom,
      anchor.top.clamp(0.0, maxY),
    ];
    Offset? fallback;
    for (final y in rows) {
      final columns = [
        anchor.left.clamp(0.0, maxX),
        for (final other in placed) ...[
          other.right + _gap,
          other.left - _gap - childSize.width,
        ],
      ];
      for (final x in columns) {
        if (x < 0 || x > maxX) continue;
        final candidate = Offset(x, y);
        fallback ??= candidate;
        final rect = candidate & childSize;
        if (!placed.any(rect.overlaps)) return candidate;
      }
    }
    return fallback ?? Offset(anchor.left.clamp(0.0, maxX), rows.first);
  }

  @override
  bool shouldRelayout(_LabelLayout oldDelegate) =>
      oldDelegate.selected != selected || oldDelegate.hovered != hovered;
}
