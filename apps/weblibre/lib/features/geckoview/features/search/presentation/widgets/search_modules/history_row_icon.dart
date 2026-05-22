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
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/features/geckoview/utils/image_helper.dart';
import 'package:weblibre/presentation/hooks/cached_future.dart';
import 'package:weblibre/presentation/widgets/safe_raw_image.dart';

/// Leading icon for a history-style ListTile row.
///
/// Wraps the boilerplate that `combined_history_suggestions`,
/// `local_history_suggestions`, and `history_suggestions` would otherwise
/// each repeat: decode `engineIcon` bytes through the shared image
/// helper's LRU, render via [SafeRawImage], fall back to [fallback] when
/// either the bytes are null or decoding produced nothing. The
/// [RepaintBoundary] isolates per-row image swaps from the surrounding
/// list's paint cost.
class HistoryRowIcon extends HookWidget {
  const HistoryRowIcon({
    super.key,
    required this.iconBytes,
    required this.fallback,
    this.size = 24,
  });

  final Uint8List? iconBytes;
  final Widget fallback;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cachedIcon = useCachedFuture(
      () async => iconBytes.mapNotNull(tryDecodeImage),
      [iconBytes],
    );

    return RepaintBoundary(
      child: SafeRawImage(
        image: cachedIcon.data,
        height: size,
        width: size,
        fallback: fallback,
      ),
    );
  }
}
