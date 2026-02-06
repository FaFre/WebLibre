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
import 'dart:ui';

import 'package:fast_equatable/hash.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/domain/entities/equatable_image.dart';
import 'package:weblibre/utils/lru_cache.dart';

final _cache = LRUCache<int, EquatableImage>(
  100,
  onEvict: (image) => image.dispose(),
);

/// Clears the global image cache, disposing all cached images.
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
    logger.w('Failed to decode image', error: e, stackTrace: s);
  }

  return null;
}
