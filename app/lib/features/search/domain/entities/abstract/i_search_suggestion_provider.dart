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
import 'package:exceptions/exceptions.dart';
import 'package:weblibre/features/bangs/data/models/bang_group.dart';
import 'package:weblibre/features/bangs/data/models/bang_key.dart';

enum SearchSuggestionProviders {
  none('Disabled', null),
  brave('Brave', BangKey(group: BangGroup.general, trigger: 'brave')),
  ddg('DuckDuckGo', BangKey(group: BangGroup.general, trigger: 'ddg')),
  kagi('Kagi', BangKey(group: BangGroup.kagi, trigger: 'kagi')),
  qwant('Qwant', BangKey(group: BangGroup.general, trigger: 'qwant'));

  final String label;
  final BangKey? relatedBang;

  const SearchSuggestionProviders(this.label, this.relatedBang);
}

abstract interface class ISearchSuggestionProvider {
  Future<Result<List<String>>> getSuggestions(String query);
}
