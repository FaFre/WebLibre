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
import 'dart:convert';

import 'package:riverpod/experimental/persist.dart';
import 'package:riverpod_annotation/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/user/data/providers.dart';

part 'extensions_expanded.g.dart';

@Riverpod(keepAlive: true)
class ExtensionsExpanded extends _$ExtensionsExpanded {
  void toggle() {
    state = !state;
  }

  @override
  bool build() {
    persist(
      ref.watch(riverpodDatabaseStorageProvider),
      key: 'ExtensionsExpanded',
      encode: (state) => jsonEncode([state]),
      decode: (encoded) => (jsonDecode(encoded) as List<dynamic>).first as bool,
    );

    return stateOrNull ?? false;
  }
}
