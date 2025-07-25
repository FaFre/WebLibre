/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
