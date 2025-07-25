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
import 'package:fast_equatable/fast_equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'feed_link.g.dart';

enum FeedLinkRelation {
  ///an alternate representation of the entry or feed, for example a permalink to the html version of the entry, or the front page of the weblog.
  alternate,

  ///a related resource which is potentially large in size and might require special handling, for example an audio or video recording.
  enclosure,

  ///an document related to the entry or feed.
  related,

  ///the feed itself.
  self,

  ///the source of the information provided in the entry.
  via,
}

@JsonSerializable()
class FeedLink with FastEquatable {
  final Uri uri;
  final FeedLinkRelation? relation;
  final String? title;

  FeedLink({required this.uri, this.relation, this.title});

  factory FeedLink.fromJson(Map<String, dynamic> json) =>
      _$FeedLinkFromJson(json);

  Map<String, dynamic> toJson() => _$FeedLinkToJson(this);

  @override
  List<Object?> get hashParameters => [uri, relation, title];
}
