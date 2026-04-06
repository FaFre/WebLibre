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
import 'package:fast_equatable/fast_equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'feed_category.g.dart';

@JsonSerializable()
class FeedCategory with FastEquatable {
  final String id;
  final String? title;

  FeedCategory({required this.id, this.title});

  factory FeedCategory.fromJson(Map<String, dynamic> json) =>
      _$FeedCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$FeedCategoryToJson(this);

  @override
  List<Object?> get hashParameters => [id, title];
}
