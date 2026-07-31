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
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:fast_equatable/hash.dart';
import 'package:flutter_svg/flutter_svg.dart' as svg;
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/domain/entities/equatable_image.dart';
import 'package:weblibre/utils/lru_cache.dart';

final _cache = LRUCache<ImageIdentity, EquatableImage>(100);
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
  // The decode options are part of the identity of the result, not just of the
  // request: the same bytes decoded at a thumbnail's target width and at an
  // icon's native size are different images. Keying on the content digest
  // alone would both hand back a wrongly-sized image to whichever caller ran
  // second, and make two genuinely different decodes compare equal.
  final identity = (
    digest: secureHash(bytes),
    targetWidth: targetWidth,
    targetHeight: targetHeight,
    allowUpscaling: allowUpscaling,
  );

  final cached = _cache.get(identity);
  if (cached?.value != null) {
    return cached;
  } else if (cached != null) {
    _cache.remove(identity);
  }

  try {
    final codec = await instantiateImageCodec(
      bytes,
      targetWidth: targetWidth,
      targetHeight: targetHeight,
      allowUpscaling: allowUpscaling,
    );

    final frameInfo = await codec.getNextFrame();
    final image = EquatableImage(frameInfo.image, identity: identity);

    if (image.value != null && image.value!.width > 0) {
      _cache.set(identity, image);
      return image;
    }
  } catch (e, s) {
    if (_isLikelySvg(bytes)) {
      try {
        final svgImage = await _tryDecodeSvg(
          bytes,
          identity: identity,
          targetWidth: targetWidth,
          targetHeight: targetHeight,
        );
        if (svgImage != null) {
          _cache.set(identity, svgImage);
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

/// Transcodes a native screenshot (delivered as WebP) to PNG off the main
/// isolate.
///
/// Decoding a full-resolution screenshot and re-encoding it as PNG costs tens
/// of milliseconds on the UI thread, and every caller does it right as a share
/// sheet or file picker is animating in — so the cost lands as a visible hitch.
/// dart:ui's codec APIs are usable from background isolates, so the whole
/// transcode runs there; if that ever fails we fall back to doing it inline
/// rather than losing the feature.
Future<Uint8List?> encodeScreenshotAsPng(Uint8List screenshot) async {
  try {
    return await Isolate.run(() => _transcodeToPng(screenshot));
  } catch (e, s) {
    logger.w(
      'Screenshot PNG transcode failed in background isolate, retrying inline',
      error: e,
      stackTrace: s,
    );

    return _transcodeToPng(screenshot);
  }
}

Future<Uint8List?> _transcodeToPng(Uint8List bytes) async {
  final codec = await instantiateImageCodec(bytes);

  try {
    final frameInfo = await codec.getNextFrame();

    try {
      final png = await frameInfo.image.toByteData(format: ImageByteFormat.png);
      return png?.buffer.asUint8List();
    } finally {
      frameInfo.image.dispose();
    }
  } finally {
    codec.dispose();
  }
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
  required ImageIdentity identity,
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
      return EquatableImage(rasterized, identity: identity);
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
