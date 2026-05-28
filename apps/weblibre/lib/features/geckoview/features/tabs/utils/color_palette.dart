/*
 * Copyright (c) 2024-2026 Fabian Freund.
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
import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';

const int _hueCount = 24;
const double _seedChroma = 60.0;
const double _seedTone = 60.0;

// Evenly spaced HCT hues. ColorScheme.fromSeed extracts the seed's hue and
// normalizes tone, so spacing in HCT (not HSL) guarantees each swatch yields
// a perceptually distinct primaryContainer.
final List<Color> containerSeedColors = List<Color>.unmodifiable(
  List.generate(_hueCount, (i) {
    final hue = i * 360.0 / _hueCount;
    return Color(Hct.from(hue, _seedChroma, _seedTone).toInt());
  }),
);
