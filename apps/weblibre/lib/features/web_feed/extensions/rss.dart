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
import 'package:nullability/nullability.dart';
import 'package:rss_dart/dart_rss.dart';
import 'package:rss_dart/domain/dublin_core/dublin_core.dart';
import 'package:weblibre/features/web_feed/data/models/feed_category.dart';

extension ParseDublinCategory on DublinCore {
  List<FeedCategory> toFeedCategories() {
    return subjects
        .where((subject) => subject.isNotEmpty)
        .map((subject) => FeedCategory(id: subject))
        .toList();
  }
}

extension ParseRssCategory on List<RssCategory> {
  List<FeedCategory> toFeedCategories() {
    return where((category) => category.value.isNotEmpty)
        .map(
          (category) => FeedCategory(
            id: '${category.domain ?? ''} ${category.value ?? ''}'.trim(),
          ),
        )
        .toList();
  }
}
