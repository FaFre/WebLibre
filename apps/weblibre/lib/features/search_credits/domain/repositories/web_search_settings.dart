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
import 'package:riverpod/experimental/persist.dart';
import 'package:riverpod_annotation/experimental/json_persist.dart';
import 'package:riverpod_annotation/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:search_backend/search_backend.dart';
import 'package:weblibre/features/search_credits/data/models/web_search_settings.dart';
import 'package:weblibre/features/user/data/providers.dart';

part 'web_search_settings.g.dart';

@Riverpod(keepAlive: true)
@JsonPersist()
class WebSearchSettingsController extends _$WebSearchSettingsController {
  void setRouteThroughTor(bool value) {
    state = state.copyWith(routeThroughTor: value);
  }

  void setSearchMode(SearchMode mode) {
    state = state.copyWith(searchMode: mode);
  }

  void setLanguage(String? language) {
    state = state.copyWith(language: language);
  }

  void setRegion(String? region) {
    state = state.copyWith(region: region);
  }

  void setSafeSearch(SafeSearch? safeSearch) {
    state = state.copyWith(safeSearch: safeSearch);
  }

  void setTimeRange(TimeRange? timeRange) {
    state = state.copyWith(timeRange: timeRange);
  }

  @override
  WebSearchSettings build() {
    persist(
      ref.watch(riverpodDatabaseStorageProvider),
      key: 'WebSearchSettings',
    );

    return stateOrNull ?? WebSearchSettings.withDefaults();
  }
}
