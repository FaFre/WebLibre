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
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/search/domain/entities/search_source_policy.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

part 'search_source_policy.g.dart';

/// The [SearchSourcePolicy] for a search typed into a private tab or not.
@Riverpod()
SearchSourcePolicy searchSourcePolicy(Ref ref, {required bool privateMode}) {
  final historySuggestionsEnabled = ref.watch(
    generalSettingsWithDefaultsProvider.select(
      (s) => s.historySuggestionsEnabled,
    ),
  );

  // Only a private search depends on it, so a regular one does not rebuild
  // when it changes.
  final privateSearchSuggestionsEnabled =
      privateMode &&
      ref.watch(
        generalSettingsWithDefaultsProvider.select(
          (s) => s.privateSearchSuggestionsEnabled,
        ),
      );

  return SearchSourcePolicy.resolve(
    privateMode: privateMode,
    historySuggestionsEnabled: historySuggestionsEnabled,
    privateSearchSuggestionsEnabled: privateSearchSuggestionsEnabled,
  );
}
