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

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:pluggable_transports_proxy/pluggable_transports_proxy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:universal_io/io.dart';

part 'builtin_bridges.g.dart';

@Riverpod(keepAlive: true)
class BuiltinBridgesService extends _$BuiltinBridgesService {
  late final _bridgeFileFuture = path_provider
      .getApplicationSupportDirectory()
      .then((dir) => File(p.join(dir.path, 'builtin-bridges.json')));

  Future<DateTime?> lastUpdate() async {
    final bridgeFile = await _bridgeFileFuture;
    if (!await bridgeFile.exists()) {
      return null;
    }

    return bridgeFile.lastModified();
  }

  Future<void> updateStoredBuiltinBridges(BuiltInBridges bridges) async {
    final bridgeFile = await _bridgeFileFuture;
    await bridgeFile.writeAsString(jsonEncode(bridges.toJson()), flush: true);
  }

  Future<BuiltInBridges?> getStoredBuiltinBridges() async {
    final bridgeFile = await _bridgeFileFuture;
    if (!await bridgeFile.exists()) {
      return null;
    }

    final content = await bridgeFile.readAsString();
    return BuiltInBridges.fromJson(jsonDecode(content) as Map<String, dynamic>);
  }

  Future<BuiltInBridges> getBundledBuiltinBridges() async {
    final content = await rootBundle.loadString(
      'assets/preferences/builtin-bridges.json',
    );
    return BuiltInBridges.fromJson(jsonDecode(content) as Map<String, dynamic>);
  }

  @override
  void build() {
    return;
  }
}
