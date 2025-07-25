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
