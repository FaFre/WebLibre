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
import 'package:json_annotation/json_annotation.dart';
import 'package:weblibre/features/web_feed/data/database/definitions.drift.dart';

class FeedDataConverter extends JsonConverter<FeedData, Map<String, dynamic>> {
  const FeedDataConverter();

  @override
  FeedData fromJson(Map<String, dynamic> json) {
    return FeedData.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(FeedData object) {
    return object.toJson();
  }
}
