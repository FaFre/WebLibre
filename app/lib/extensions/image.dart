import 'dart:ui';

import 'package:xxh3/xxh3.dart';

extension ImageHash on Image {
  Future<int?> calculateHash() async {
    final bytes = await toByteData();
    if (bytes != null) {
      final digest = xxh3(bytes.buffer.asUint8List());
      return digest;
    }

    return null;
  }

  // Future<EquatableImage> toEquatable() {
  //   return EquatableImage.calculate(this);
  // }
}
