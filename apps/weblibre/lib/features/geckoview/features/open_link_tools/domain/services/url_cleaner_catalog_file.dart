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
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'url_cleaner_catalog_file.g.dart';

@Riverpod(keepAlive: true)
class UrlCleanerCatalogFileService extends _$UrlCleanerCatalogFileService {
  late final _catalogFileFuture = path_provider
      .getApplicationSupportDirectory()
      .then((dir) => File(p.join(dir.path, 'url_cleaner_data.minify.json')));

  Future<DateTime?> lastUpdate() async {
    final catalogFile = await _catalogFileFuture;
    if (!await catalogFile.exists()) {
      return null;
    }

    return catalogFile.lastModified();
  }

  Future<void> writeCatalog(String catalogJson) async {
    final catalogFile = await _catalogFileFuture;
    await catalogFile.writeAsString(catalogJson, flush: true);
  }

  Future<String?> readCatalog() async {
    final catalogFile = await _catalogFileFuture;
    if (!await catalogFile.exists()) {
      return null;
    }

    return catalogFile.readAsString();
  }

  Future<void> deleteCatalog() async {
    final catalogFile = await _catalogFileFuture;
    if (await catalogFile.exists()) {
      await catalogFile.delete();
    }
  }

  @override
  void build() {}
}
