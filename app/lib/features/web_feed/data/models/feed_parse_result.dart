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
import 'package:json_annotation/json_annotation.dart';
import 'package:weblibre/features/web_feed/data/database/converters/feed_data.dart';
import 'package:weblibre/features/web_feed/data/database/definitions.drift.dart';
import 'package:weblibre/features/web_feed/data/models/feed_article.dart';

part 'feed_parse_result.g.dart';

@JsonSerializable()
class FeedParseResult {
  @FeedDataConverter()
  final FeedData feedData;
  final List<FeedArticle> articleData;

  FeedParseResult({required this.feedData, required this.articleData});

  factory FeedParseResult.fromJson(Map<String, dynamic> json) =>
      _$FeedParseResultFromJson(json);

  Map<String, dynamic> toJson() => _$FeedParseResultToJson(this);
}
