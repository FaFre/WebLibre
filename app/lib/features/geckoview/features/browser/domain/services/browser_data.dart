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
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';

part 'browser_data.g.dart';

@Riverpod(keepAlive: true)
class BrowserDataService extends _$BrowserDataService {
  final _service = GeckoDeleteBrowserDataService();

  var _onStartDeleted = false;

  Future<void> deleteDataOnEngineStart(
    Set<DeleteBrowsingDataType>? types,
  ) async {
    if (!_onStartDeleted) {
      _onStartDeleted = true;
      return deleteData(types);
    }
  }

  Future<void> deleteData(Set<DeleteBrowsingDataType>? types) async {
    if (types != null) {
      for (final type in types) {
        switch (type) {
          case DeleteBrowsingDataType.tabs:
            await _service.deleteTabs();
          case DeleteBrowsingDataType.history:
            await _service.deleteBrowsingHistory();
          case DeleteBrowsingDataType.cookies:
            await _service.deleteCookiesAndSiteData();
          case DeleteBrowsingDataType.cache:
            await _service.deleteCachedFiles();
          case DeleteBrowsingDataType.permissions:
            await _service.deleteSitePermissions();
          case DeleteBrowsingDataType.downloads:
            await _service.deleteDownloads();
        }
      }
    }
  }

  @override
  void build() {}
}
