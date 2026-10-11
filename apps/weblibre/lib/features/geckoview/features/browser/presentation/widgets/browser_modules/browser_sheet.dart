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
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/presentation/widgets/browser_sheet_surface.dart';

/// Hosts a sheet as a modal bottom sheet in the browser's own Stack (the tab
/// tray, site settings), as its topmost layer (#651).
///
/// Spans the window: a scrim over everything the sheet leaves uncovered, and
/// the sheet anchored to the window's bottom edge, its extents fractions of
/// the window height. The scrim is laid out after the sheet, from the height
/// the sheet actually took, so it follows a drag, an animation and a sheet
/// rebuilt at its initial extent alike.
///
/// The sheet is as wide as the browser's route sheets (the ⋮ menu, prompts):
/// it takes [BottomSheetThemeData.constraints] from the browser's theme, which
/// also keeps it clear of the side insets, and is centered in the window.
///
/// Modal to assistive technology and the keyboard as well, the way a
/// [ModalBottomSheetRoute] is: everything painted under it drops out of the
/// semantics tree, so a screen reader can't reach the controls the scrim
/// covers, and keyboard focus moves into the sheet and stays there until it
/// closes. The scrim offers the dismiss action instead, and the sheet
/// announces itself as a route. Escape closes it.
class BrowserSheetHost extends HookWidget {
  /// A [DraggableScrollableSheet] whose builder returns a
  /// [BrowserSheetSurface].
  final Widget sheet;

  /// Closes the sheet: a tap on the scrim, a screen reader's dismiss action,
  /// or a drag all the way down.
  final VoidCallback onDismiss;

  const BrowserSheetHost({
    required this.sheet,
    required this.onDismiss,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final modalBarrierColor =
        theme.bottomSheetTheme.modalBarrierColor ??
        theme.colorScheme.scrim.withValues(alpha: 0.5);
    final localizations = MaterialLocalizations.of(context);

    // Takes focus from whatever had it, the address bar or the page included,
    // the way a pushed route does. Tab traversal stays inside the nearest
    // scope, so the controls under the scrim can't be reached from a keyboard.
    // When the sheet closes, focus goes back to where it was.
    final focusScope = useFocusScopeNode(debugLabel: 'BrowserSheetHost');
    useEffect(() {
      var active = true;
      // Once the scope has joined the focus tree: a scope asked before that
      // drops the request.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (active) focusScope.requestFocus();
      });
      return () => active = false;
    }, [focusScope]);

    bool onSheetNotification(DraggableScrollableNotification notification) {
      if (notification.extent <= 0.1) {
        logger.i('Dismissing sheet, reached min extend');
        onDismiss();
        return true;
      }
      return false;
    }

    // Tapping anywhere the sheet doesn't occupy dismisses it. The scrim is
    // split around the sheet rather than painted under it: under hybrid
    // composition every pixel painted over the platform view goes through an
    // overlay surface, and once the tab sheet settles near full extent almost
    // all of a full-window scrim would be hidden behind it anyway.
    Widget scrim() => GestureDetector(
      behavior: HitTestBehavior.opaque,
      // The band above the sheet carries the scrim's semantics.
      excludeFromSemantics: true,
      onTap: onDismiss,
      child: ColoredBox(color: modalBarrierColor),
    );

    // Escape closes the sheet, as it closes a route's.
    return Actions(
      actions: {
        DismissIntent: CallbackAction<DismissIntent>(
          onInvoke: (_) {
            onDismiss();
            return null;
          },
        ),
      },
      child: FocusScope(
        node: focusScope,
        child: BlockSemantics(
          child: CustomMultiChildLayout(
            delegate: _BrowserSheetLayout(
              maxSheetWidth:
                  theme.bottomSheetTheme.constraints?.maxWidth ??
                  double.infinity,
            ),
            children: [
              LayoutId(
                id: _BrowserSheetSlot.scrim,
                // What a screen reader finds of the scrim, labelled and
                // dismissing like a modal bottom sheet's barrier, and like it
                // confined to the part the sheet leaves uncovered.
                child: Semantics(
                  label: localizations.scrimLabel,
                  onTapHint: localizations.scrimOnTapHint(
                    localizations.bottomSheetLabel,
                  ),
                  onTap: onDismiss,
                  onDismiss: onDismiss,
                  child: scrim(),
                ),
              ),
              // Beside a width-capped sheet the page would otherwise stay
              // unscrimmed below the band, reading as live content next to a
              // modal surface.
              LayoutId(id: _BrowserSheetSlot.leftGutter, child: scrim()),
              LayoutId(id: _BrowserSheetSlot.rightGutter, child: scrim()),
              LayoutId(
                id: _BrowserSheetSlot.sheet,
                // Announced the way Android announces a modal bottom sheet's
                // route.
                child: Semantics(
                  scopesRoute: true,
                  namesRoute: true,
                  label: localizations.dialogLabel,
                  explicitChildNodes: true,
                  child: NotificationListener<DraggableScrollableNotification>(
                    onNotification: onSheetNotification,
                    child: sheet,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _BrowserSheetSlot { scrim, leftGutter, rightGutter, sheet }

/// Lays out [BrowserSheetHost]: the sheet at the window's bottom edge, then the
/// scrim around it.
class _BrowserSheetLayout extends MultiChildLayoutDelegate {
  final double maxSheetWidth;

  _BrowserSheetLayout({required this.maxSheetWidth});

  /// How far the scrim reaches *under* the sheet. The sheets round their top
  /// corners ([BrowserSheetSurface.cornerRadius]), and the page shows through
  /// those cutouts — so the scrim has to reach a little past the sheet's top
  /// edge or the corners would reveal unscrimmed content.
  static const _cornerOverlap = 32.0;

  @override
  void performLayout(Size size) {
    final sheetWidth = math.min(size.width, maxSheetWidth);
    // Empty on a phone in portrait, where the sheet spans the window.
    final gutter = (size.width - sheetWidth) / 2;

    // The sheet takes its own height, a fraction of the window's.
    final sheet = layoutChild(
      _BrowserSheetSlot.sheet,
      BoxConstraints(
        minWidth: sheetWidth,
        maxWidth: sheetWidth,
        maxHeight: size.height,
      ),
    );
    final sheetTop = size.height - sheet.height;
    positionChild(_BrowserSheetSlot.sheet, Offset(gutter, sheetTop));

    final scrimHeight = math.min(sheetTop + _cornerOverlap, size.height);
    layoutChild(
      _BrowserSheetSlot.scrim,
      BoxConstraints.tightFor(width: size.width, height: scrimHeight),
    );
    positionChild(_BrowserSheetSlot.scrim, Offset.zero);

    // From the band down to the window's bottom edge, which the sheet never
    // reaches into. Not behind the band as well: two scrims stacked would dim
    // the page twice as much there.
    final gutterConstraints = BoxConstraints.tightFor(
      width: gutter,
      height: size.height - scrimHeight,
    );
    layoutChild(_BrowserSheetSlot.leftGutter, gutterConstraints);
    positionChild(_BrowserSheetSlot.leftGutter, Offset(0, scrimHeight));
    layoutChild(_BrowserSheetSlot.rightGutter, gutterConstraints);
    positionChild(
      _BrowserSheetSlot.rightGutter,
      Offset(size.width - gutter, scrimHeight),
    );
  }

  @override
  bool shouldRelayout(_BrowserSheetLayout oldDelegate) =>
      maxSheetWidth != oldDelegate.maxSheetWidth;
}
