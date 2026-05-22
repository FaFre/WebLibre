import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/geckoview/utils/image_helper.dart';

void main() {
  testWidgets('tryDecodeImage rasterizes svg bytes at favicon size', (
    tester,
  ) async {
    clearImageCache();
    final svgBytes = Uint8List.fromList(utf8.encode(_svgIcon));

    final image = await tryDecodeImage(svgBytes);

    expect(image, isNotNull);
    expect(image!.value, isNotNull);
    expect(image.value!.width, 32);
    expect(image.value!.height, 32);

    final byteData = await image.value!.toByteData(
      format: ImageByteFormat.rawRgba,
    );
    expect(byteData, isNotNull);

    // A pixel in the right half should be painted once the SVG is scaled
    // to the requested raster size instead of being left in the top-left.
    expect(_rgbaAt(byteData!, width: 32, x: 24, y: 16), [47, 128, 237, 255]);
  });
}

List<int> _rgbaAt(
  ByteData data, {
  required int width,
  required int x,
  required int y,
}) {
  final offset = (y * width + x) * 4;
  return [
    data.getUint8(offset),
    data.getUint8(offset + 1),
    data.getUint8(offset + 2),
    data.getUint8(offset + 3),
  ];
}

const _svgIcon = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16">
  <rect width="16" height="16" rx="3" fill="#2F80ED"/>
  <circle cx="8" cy="8" r="4" fill="#FFFFFF"/>
</svg>
''';
