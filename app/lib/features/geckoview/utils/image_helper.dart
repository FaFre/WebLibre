import 'dart:typed_data';
import 'dart:ui';

import 'package:fast_equatable/hash.dart';
import 'package:lensai/domain/entities/equatable_image.dart';
import 'package:lensai/utils/lru_cache.dart';

final _cache = LRUCache<int, EquatableImage>(100);

Future<EquatableImage?> tryDecodeImage(
  Uint8List bytes, {
  int? targetWidth,
  int? targetHeight,
  bool allowUpscaling = true,
}) async {
  final digest = secureHash(bytes);

  final cached = _cache.get(digest);
  if (cached != null) {
    return cached;
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

    if (image.value.width > 0) {
      _cache.set(digest, image);
      return image;
    }
  } catch (e) {
    //swallow
  }

  return null;
}
