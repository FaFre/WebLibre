import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/domain/entities/equatable_image.dart';
import 'package:weblibre/features/geckoview/utils/image_helper.dart';

void main() {
  testWidgets('tryDecodeImage rasterizes svg bytes at favicon size', (
    tester,
  ) async {
    // Must run outside the fake-async zone: flutter_svg's loader parses the
    // document via `compute()`, i.e. a real isolate, and that future never
    // completes while `testWidgets` controls the clock — the test would hang
    // forever rather than fail.
    await tester.runAsync(() async {
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
  });

  testWidgets('tryDecodeImage does not serve a cached decode across sizes', (
    tester,
  ) async {
    await tester.runAsync(() async {
      clearImageCache();
      final svgBytes = Uint8List.fromList(utf8.encode(_svgIcon));

      // Same bytes, different decode options. The cache is keyed on the digest
      // *and* the options, so the second call must not be answered with the
      // first call's differently-sized image.
      final sized = await tryDecodeImage(svgBytes, targetWidth: 64);
      expect(sized?.value?.width, 64);
      expect(sized?.value?.height, 64);

      final unsized = await tryDecodeImage(svgBytes);
      expect(unsized?.value?.width, 32);
      expect(unsized?.value?.height, 32);

      // Reversed order, to catch a cache that only poisons one direction.
      clearImageCache();

      final unsizedFirst = await tryDecodeImage(svgBytes);
      expect(unsizedFirst?.value?.width, 32);

      final sizedSecond = await tryDecodeImage(svgBytes, targetWidth: 64);
      expect(sizedSecond?.value?.width, 64);

      // Two decodes that differ only in size must not compare equal, or the
      // `state[id] == next` guards in the tab-state notifiers would drop a
      // genuine change.
      expect(sizedSecond, isNot(equals(unsizedFirst)));

      // ...while a repeat of the *same* request is still deduped.
      final unsizedAgain = await tryDecodeImage(svgBytes);
      expect(unsizedAgain, equals(unsizedFirst));
      expect(identical(unsizedAgain, unsizedFirst), isTrue);
    });
  });

  test('ImageIdentity compares structurally, not by a folded hash', () {
    const a = (
      digest: 0x0123456789ABCDEF,
      targetWidth: 720,
      targetHeight: null,
      allowUpscaling: false,
    );
    // Differs only in the low bits of the 64-bit content digest. Folding the
    // identity into a single hash code would truncate to 30 bits and could
    // collapse these two onto the same cache entry; structural equality can't.
    const b = (
      digest: 0x0123456789ABCDEE,
      targetWidth: 720,
      targetHeight: null,
      allowUpscaling: false,
    );

    expect(a, isNot(equals(b)));
    expect(<ImageIdentity, String>{a: 'a', b: 'b'}.length, 2);

    // Options are part of the key too.
    const sameDigestOtherWidth = (
      digest: 0x0123456789ABCDEF,
      targetWidth: 32,
      targetHeight: null,
      allowUpscaling: false,
    );
    expect(a, isNot(equals(sameDigestOtherWidth)));
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
