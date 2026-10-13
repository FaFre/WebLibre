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
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/utils/url_canonical.dart';

part 'hidden_history_suggestions.g.dart';

/// The key a history suggestion for [url] is hidden by: its canonical URL, so
/// the engine's row and the local index's row for one page go together.
String historySuggestionKey(String url) =>
    canonicalizeUrl(url)?.canonical ?? url;

/// History suggestions deleted during this search, by [historySuggestionKey].
///
/// A deleted page leaves the list at once but its visits go only when the
/// Undo for it is gone, as in Fenix: Places cannot take back a deleted visit.
@Riverpod()
class HiddenHistorySuggestions extends _$HiddenHistorySuggestions {
  void hide(String key) {
    state = {...state, key};
  }

  /// Shows the suggestion again after an Undo. The search may have closed
  /// since, and then there is nothing to show it in.
  void unhide(String key) {
    if (!ref.mounted) return;
    state = {...state}..remove(key);
  }

  @override
  Set<String> build() => const {};
}
