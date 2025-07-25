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

import 'package:drift/drift.dart';
import 'package:weblibre/features/web_feed/data/models/feed_category.dart';

class FeedCategoriesConverter
    extends TypeConverter<List<FeedCategory>, String> {
  const FeedCategoriesConverter();

  @override
  List<FeedCategory> fromSql(String fromDb) {
    final categories = jsonDecode(fromDb) as List<dynamic>;
    return categories
        .map(
          (category) => FeedCategory.fromJson(category as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  String toSql(List<FeedCategory> value) {
    return jsonEncode(value.map((category) => category.toJson()).toList());
  }
}
