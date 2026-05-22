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
/// Shared fixtures for web_search presentation tests.
///
/// `UrlIcon` (used by every result card / preview / infobox) reaches into
/// `userDatabaseProvider` → `cacheRepositoryProvider` and
/// `geckoIconServiceProvider`. Both touch native code that isn't available in
/// the test runtime, so we wire in-memory + no-op fakes via this helper to
/// keep individual test setup small.
library;

import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/experimental/persist.dart';
import 'package:riverpod/misc.dart' show Override;
import 'package:weblibre/data/database/functions/lexo_rank_functions.dart';
import 'package:weblibre/domain/services/generic_website.dart';
import 'package:weblibre/features/user/data/database/database.dart';
import 'package:weblibre/features/user/data/providers.dart';

/// Builds the standard set of overrides that any web_search presentation test
/// needs to render `UrlIcon` / settings-backed widgets without touching the
/// real filesystem profile databases. Registers `addTearDown` for the
/// in-memory drift db so the caller doesn't have to.
List<Override> webSearchTestOverrides() {
  final userDb = UserDatabase(
    NativeDatabase.memory(
      setup: (database) => registerLexorankFunctions(database),
    ),
  );
  addTearDown(userDb.close);

  return [
    userDatabaseProvider.overrideWith((ref) => userDb),
    riverpodDatabaseStorageProvider.overrideWith((ref) => Storage.inMemory()),
    geckoIconServiceProvider.overrideWithValue(_FakeGeckoIconService()),
  ];
}

/// No-op GeckoIconService — returns a generator-source icon with empty bytes
/// so the cacheOnly branch in UrlIcon falls through to the MdiIcons.web
/// fallback. The real service is a platform-channel adapter and would crash
/// in the test runtime.
final class _FakeGeckoIconService extends GeckoIconService {
  @override
  Future<IconResult> loadIcon({
    required Uri url,
    List<Resource> resources = const [],
    IconSize size = IconSize.defaultSize,
    bool isPrivate = false,
    bool waitOnNetworkLoad = true,
  }) async {
    return IconResult(
      image: Uint8List(0),
      color: null,
      source: IconSource.generator,
      maskable: false,
    );
  }
}
