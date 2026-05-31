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
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

part 'gesture_stroke.g.dart';

/// Where a gesture must begin. Mirrors the reference add-on's start-position
/// tokens (the trailing colon is part of the canonical key prefix).
enum GestureStartPosition {
  anywhere('', 'Anywhere', MdiIcons.borderNone),
  leftEdge('L:', 'Left edge', MdiIcons.borderLeft),
  rightEdge('R:', 'Right edge', MdiIcons.borderRight),
  topEdge('T:', 'Top edge', MdiIcons.borderTop),
  bottomEdge('B:', 'Bottom edge', MdiIcons.borderBottom),
  leftHalf('W:', 'Left half', MdiIcons.borderLeftVariant),
  rightHalf('E:', 'Right half', MdiIcons.borderRightVariant);

  /// Canonical key prefix, e.g. `R:` (empty for [anywhere]).
  final String prefix;
  final String label;
  final IconData icon;

  const GestureStartPosition(this.prefix, this.label, this.icon);

  static GestureStartPosition fromPrefixLetter(String letter) {
    return GestureStartPosition.values.firstWhere(
      (position) => position.prefix == '$letter:',
      orElse: () => GestureStartPosition.anywhere,
    );
  }
}

/// A single dominant swipe direction within a gesture.
enum GestureArrow {
  up('U', '↑'),
  down('D', '↓'),
  left('L', '←'),
  right('R', '→');

  /// Canonical key token, e.g. `D`.
  final String token;

  /// Compact glyph for rendering a stroke sequence.
  final String symbol;

  const GestureArrow(this.token, this.symbol);

  static GestureArrow fromToken(String token) {
    return GestureArrow.values.firstWhere((arrow) => arrow.token == token);
  }
}

/// A configurable gesture: an ordered sequence of swipe directions, optionally
/// constrained by where the touch begins and how many fingers are used.
///
/// The canonical [key] is the on-the-wire identifier shared with the native
/// recognizer: `<start-prefix><finger-prefix><arrows joined by '-'>`, e.g.
/// `R:2:D-L`. The finger prefix is omitted for a single finger and the start
/// prefix is omitted for [GestureStartPosition.anywhere].
@CopyWith()
class GestureStroke with FastEquatable {
  final GestureStartPosition startPosition;
  final int fingers;
  final List<GestureArrow> arrows;

  GestureStroke({
    this.startPosition = GestureStartPosition.anywhere,
    this.fingers = 1,
    this.arrows = const [],
  });

  /// The canonical gesture key (see class docs).
  String get key {
    final fingerPrefix = fingers >= 2 ? '$fingers:' : '';
    final arrowPart = arrows.map((arrow) => arrow.token).join('-');
    return '${startPosition.prefix}$fingerPrefix$arrowPart';
  }

  /// Parses a canonical [key] back into a stroke.
  ///
  /// The arrow sequence is always the final colon-separated segment; preceding
  /// segments are either a single start-position letter or a finger count.
  factory GestureStroke.fromKey(String key) {
    final segments = key.split(':');
    final arrowPart = segments.removeLast();

    var startPosition = GestureStartPosition.anywhere;
    var fingers = 1;
    for (final segment in segments) {
      final asFingers = int.tryParse(segment);
      if (asFingers != null) {
        fingers = asFingers;
      } else if (segment.isNotEmpty) {
        startPosition = GestureStartPosition.fromPrefixLetter(segment);
      }
    }

    final arrows = arrowPart.isEmpty
        ? <GestureArrow>[]
        : arrowPart.split('-').map(GestureArrow.fromToken).toList();

    return GestureStroke(
      startPosition: startPosition,
      fingers: fingers,
      arrows: arrows,
    );
  }

  /// Whether this stroke is complete enough to be bound to an action.
  bool get isValid => arrows.isNotEmpty;

  /// Human-readable rendering, e.g. `Right edge · ✌ · ↓→`.
  String get displayLabel {
    final parts = <String>[
      if (startPosition != GestureStartPosition.anywhere) startPosition.label,
      if (fingers >= 2) '$fingers fingers',
      arrows.map((arrow) => arrow.symbol).join(),
    ];
    return parts.join(' · ');
  }

  @override
  List<Object?> get hashParameters => [startPosition, fingers, arrows];
}
