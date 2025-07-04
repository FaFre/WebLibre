import 'dart:typed_data';
import 'dart:ui';

import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:weblibre/domain/entities/equatable_image.dart';
import 'package:weblibre/features/geckoview/utils/image_helper.dart';

class BrowserIcon with FastEquatable {
  final EquatableImage image;

  final Color? dominantColor;
  final IconSource source;

  static Future<BrowserIcon> fromBytes(
    Uint8List bytes, {
    required Color? dominantColor,
    required IconSource source,
  }) async {
    final image = await tryDecodeImage(bytes);

    return BrowserIcon(
      image: image!,
      dominantColor: dominantColor,
      source: source,
    );
  }

  BrowserIcon({
    required this.image,
    required this.dominantColor,
    required this.source,
  });

  @override
  List<Object?> get hashParameters => [image, dominantColor, source];
}
