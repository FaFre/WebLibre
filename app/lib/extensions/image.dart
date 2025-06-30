import 'dart:ui';

import 'package:fast_equatable/hash.dart';

extension ImageHash on Image {
  Future<int?> calculateHash() async {
    final byteData = await toByteData();
    if (byteData != null) {
      final digest = secureHash(byteData);
      return digest;
    }

    return null;
  }

  // Future<EquatableImage> toEquatable() {
  //   return EquatableImage.calculate(this);
  // }
}
