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
import 'package:collection/collection.dart';
import 'package:nullability/nullability.dart';
import 'package:rss_dart/dart_rss.dart';
import 'package:weblibre/features/web_feed/data/models/feed_author.dart';
import 'package:weblibre/features/web_feed/data/models/feed_category.dart';
import 'package:weblibre/features/web_feed/data/models/feed_link.dart';

extension ParseAtomLink on List<AtomLink> {
  List<FeedLink> toFeedLinks() {
    return map((link) {
      final uri = link.href.mapNotNull(Uri.tryParse);
      if (uri == null) {
        return null;
      }

      final relation = link.rel.mapNotNull(
        (rel) => FeedLinkRelation.values.firstWhereOrNull((e) => e.name == rel),
      );

      return FeedLink(
        uri: uri,
        relation: relation,
        title: link.title.whenNotEmpty,
      );
    }).nonNulls.toList();
  }
}

extension SelectFeedLink on List<FeedLink> {
  FeedLink? getRelation(FeedLinkRelation? relation) {
    return firstWhereOrNull((link) => link.relation == relation);
  }
}

extension ParseAtomCategory on List<AtomCategory> {
  List<FeedCategory> toFeedCategories() {
    return where((category) => category.term.isNotEmpty)
        .map(
          (category) => FeedCategory(
            id: category.term!,
            title: category.label.whenNotEmpty,
          ),
        )
        .toList();
  }
}

extension ParseAtomPerson on List<AtomPerson> {
  List<FeedAuthor> toFeedAuthors() {
    return where(
          (author) =>
              author.name.whenNotEmpty != null ||
              author.email.whenNotEmpty != null,
        )
        .map(
          (author) => FeedAuthor(
            name: author.name.whenNotEmpty,
            email: author.email.whenNotEmpty,
          ),
        )
        .toList();
  }
}
