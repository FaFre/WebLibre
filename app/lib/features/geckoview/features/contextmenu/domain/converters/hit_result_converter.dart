import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';

class HitResultConverter {
  const HitResultConverter();

  Map<String, dynamic> encode(HitResult input) {
    final (type, data) = switch (input) {
      final UnknownHitResult result => (result.runtimeType, result.encode()),
      final ImageHitResult result => (result.runtimeType, result.encode()),
      final VideoHitResult result => (result.runtimeType, result.encode()),
      final AudioHitResult result => (result.runtimeType, result.encode()),
      final ImageSrcHitResult result => (result.runtimeType, result.encode()),
      final PhoneHitResult result => (result.runtimeType, result.encode()),
      final EmailHitResult result => (result.runtimeType, result.encode()),
      final GeoHitResult result => (result.runtimeType, result.encode()),
    };

    return {'type': type.toString(), 'data': data};
  }

  HitResult decode(Map<String, dynamic> input) {
    final {'type': String type, 'data': List<Object?> data} = input;

    switch (type) {
      case 'UnknownHitResult':
        return UnknownHitResult.decode(data);
      case 'ImageHitResult':
        return ImageHitResult.decode(data);
      case 'VideoHitResult':
        return VideoHitResult.decode(data);
      case 'AudioHitResult':
        return AudioHitResult.decode(data);
      case 'ImageSrcHitResult':
        return ImageSrcHitResult.decode(data);
      case 'PhoneHitResult':
        return PhoneHitResult.decode(data);
      case 'EmailHitResult':
        return EmailHitResult.decode(data);
      case 'GeoHitResult':
        return GeoHitResult.decode(data);
      default:
        throw FormatException('Unknown HitResult type: $type');
    }
  }
}
