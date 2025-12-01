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
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/user/data/models/rfp_target.dart';

part 'fingerprinting.g.dart';

@Riverpod(keepAlive: true)
Future<List<RFPTarget>> fingerprintTargets(Ref ref) async {
  final json =
      await rootBundle
              .loadString('assets/preferences/rfp_targets.json')
              .then(jsonDecode)
          as List<dynamic>;

  return json
      .map((e) => RFPTarget.fromJson(e as Map<String, dynamic>))
      .toList();
}
