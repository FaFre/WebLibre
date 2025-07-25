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
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'article_filter.g.dart';

@Riverpod(keepAlive: true)
class ArticleFilter extends _$ArticleFilter {
  void addTag(String tagId) {
    state = {...state, tagId};
  }

  void removeTag(String tagId) {
    if (state.isNotEmpty) {
      state = {...state}..remove(tagId);
    }
  }

  @override
  Set<String> build() {
    return {};
  }
}
