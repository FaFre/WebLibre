import 'dart:ui';

class EquatableImage {
  final Image value;
  final int? _imageHash;

  EquatableImage(this.value, {required int? hash}) : _imageHash = hash;

  //For now we only calculate the has from encoded image on decoding

  // static Future<EquatableImage> calculate(Image image) async {
  //   final imageHash = await image.calculateHash();

  //   return EquatableImage(image, hash: imageHash);
  // }

  @override
  int get hashCode => _imageHash.hashCode;

  @override
  bool operator ==(Object other) {
    return other is EquatableImage && other._imageHash == _imageHash;
  }
}
