import 'dart:ui';

class EquatableImage {
  final Image value;
  final int _imageHash;

  EquatableImage(this.value, {required int hash}) : _imageHash = hash;

  @override
  int get hashCode => _imageHash.hashCode;

  @override
  bool operator ==(Object other) {
    return other is EquatableImage && other._imageHash == _imageHash;
  }
}
