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
import 'package:rss_dart/dart_rss.dart';

extension WebFeedJson on WebFeed {
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'links': links.where((link) => link != null).toList(),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  static WebFeed fromJson(Map<String, dynamic> json) {
    return WebFeed(
      title: json['title'] as String,
      description: json['description'] as String,
      links: (json['links'] as List).cast<String?>(),
      items: (json['items'] as List)
          .map((item) => WebFeedItemJson.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

extension WebFeedItemJson on WebFeedItem {
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'links': links.where((link) => link != null).toList(),
      'updated': updated?.toIso8601String(),
    };
  }

  static WebFeedItem fromJson(Map<String, dynamic> json) {
    return WebFeedItem(
      title: json['title'] as String,
      body: json['body'] as String,
      links: (json['links'] as List).cast<String?>(),
      updated: json['updated'] != null
          ? DateTime.parse(json['updated'] as String)
          : null,
    );
  }
}
