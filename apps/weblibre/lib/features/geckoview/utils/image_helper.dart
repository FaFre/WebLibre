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
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:fast_equatable/hash.dart';
import 'package:flutter_svg/flutter_svg.dart' as svg;
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/domain/entities/equatable_image.dart';
import 'package:weblibre/utils/lru_cache.dart';

final _cache = LRUCache<int, EquatableImage>(100);
const _defaultSvgIconSize = 32;

/// Clears the global image decode cache.
void clearImageCache() {
  _cache.clear();
}

Future<EquatableImage?> tryDecodeImage(
  Uint8List bytes, {
  int? targetWidth,
  int? targetHeight,
  bool allowUpscaling = true,
}) async {
  final digest = secureHash(bytes);

  final cached = _cache.get(digest);
  if (cached?.value != null) {
    return cached;
  } else if (cached != null) {
    _cache.remove(digest);
  }

  try {
    final codec = await instantiateImageCodec(
      bytes,
      targetWidth: targetWidth,
      targetHeight: targetHeight,
      allowUpscaling: allowUpscaling,
    );

    final frameInfo = await codec.getNextFrame();
    final image = EquatableImage(frameInfo.image, hash: digest);

    if (image.value != null && image.value!.width > 0) {
      _cache.set(digest, image);
      return image;
    }
  } catch (e, s) {
    if (_isLikelySvg(bytes)) {
      try {
        final svgImage = await _tryDecodeSvg(
          bytes,
          hash: digest,
          targetWidth: targetWidth,
          targetHeight: targetHeight,
        );
        if (svgImage != null) {
          _cache.set(digest, svgImage);
          return svgImage;
        }
      } catch (svgError, svgStackTrace) {
        logger.w(
          'Failed to rasterize SVG image',
          error: svgError,
          stackTrace: svgStackTrace,
        );
      }
    }

    logger.w('Failed to decode image', error: e, stackTrace: s);
  }

  return null;
}

bool _isLikelySvg(Uint8List bytes) {
  final prefix = utf8
      .decode(bytes.sublist(0, min(bytes.length, 512)), allowMalformed: true)
      .trimLeft();
  final normalized = prefix.isNotEmpty && prefix.codeUnitAt(0) == 0xFEFF
      ? prefix.substring(1)
      : prefix;
  final lower = normalized.toLowerCase();

  return lower.contains('<svg') ||
      lower.contains('<!doctype svg') ||
      (lower.contains('<?xml') && lower.contains('<svg'));
}

Future<EquatableImage?> _tryDecodeSvg(
  Uint8List bytes, {
  required int hash,
  int? targetWidth,
  int? targetHeight,
}) async {
  final pictureInfo = await svg.vg.loadPicture(svg.SvgBytesLoader(bytes), null);

  try {
    final dimensions = _resolveSvgRasterDimensions(
      pictureInfo.size,
      targetWidth: targetWidth,
      targetHeight: targetHeight,
    );

    final sourceWidth = pictureInfo.size.width > 0
        ? pictureInfo.size.width
        : dimensions.width.toDouble();
    final sourceHeight = pictureInfo.size.height > 0
        ? pictureInfo.size.height
        : dimensions.height.toDouble();
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.clipRect(
      Rect.fromLTWH(
        0,
        0,
        dimensions.width.toDouble(),
        dimensions.height.toDouble(),
      ),
    );
    canvas.scale(
      dimensions.width / sourceWidth,
      dimensions.height / sourceHeight,
    );
    canvas.drawPicture(pictureInfo.picture);

    final scaledPicture = recorder.endRecording();

    try {
      final rasterized = await scaledPicture.toImage(
        dimensions.width,
        dimensions.height,
      );
      return EquatableImage(rasterized, hash: hash);
    } finally {
      scaledPicture.dispose();
    }
  } finally {
    pictureInfo.picture.dispose();
  }
}

({int width, int height}) _resolveSvgRasterDimensions(
  Size sourceSize, {
  int? targetWidth,
  int? targetHeight,
}) {
  if (targetWidth != null && targetHeight != null) {
    return (width: max(1, targetWidth), height: max(1, targetHeight));
  }

  final fallbackSize = targetWidth ?? targetHeight ?? _defaultSvgIconSize;
  final sourceWidth = sourceSize.width > 0
      ? sourceSize.width
      : fallbackSize.toDouble();
  final sourceHeight = sourceSize.height > 0
      ? sourceSize.height
      : fallbackSize.toDouble();

  if (targetWidth != null) {
    return (
      width: max(1, targetWidth),
      height: max(1, (targetWidth * sourceHeight / sourceWidth).round()),
    );
  }

  if (targetHeight != null) {
    return (
      width: max(1, (targetHeight * sourceWidth / sourceHeight).round()),
      height: max(1, targetHeight),
    );
  }

  if (sourceWidth >= sourceHeight) {
    return (
      width: fallbackSize,
      height: max(1, (fallbackSize * sourceHeight / sourceWidth).round()),
    );
  }

  return (
    width: max(1, (fallbackSize * sourceWidth / sourceHeight).round()),
    height: fallbackSize,
  );
}
