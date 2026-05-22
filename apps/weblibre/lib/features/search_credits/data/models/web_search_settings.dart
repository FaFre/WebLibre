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
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:search_backend/search_backend.dart';

part 'web_search_settings.g.dart';

@CopyWith()
@JsonSerializable(includeIfNull: true, constructor: 'withDefaults')
class WebSearchSettings with FastEquatable {
  final bool routeThroughTor;
  final SearchMode searchMode;

  /// ISO 639-1 language code (e.g. `en`, `de`). `null` means "use backend
  /// default" (currently English).
  final String? language;

  /// ISO 3166-1 alpha-2 region/country code (e.g. `US`, `DE`). `null`
  /// means "no region preference" — engines won't apply region boosts.
  final String? region;

  /// Safe-search level. `null` defers to the server default (moderate).
  final SafeSearch? safeSearch;

  /// Freshness filter. `null` means "any time".
  final TimeRange? timeRange;

  WebSearchSettings({
    required this.routeThroughTor,
    required this.searchMode,
    required this.language,
    required this.region,
    required this.safeSearch,
    required this.timeRange,
  });

  WebSearchSettings.withDefaults({
    bool? routeThroughTor,
    SearchMode? searchMode,
    this.language,
    this.region,
    this.safeSearch,
    this.timeRange,
  }) : routeThroughTor = routeThroughTor ?? false,
       searchMode = searchMode ?? SearchMode.general;

  factory WebSearchSettings.fromJson(Map<String, dynamic> json) =>
      _$WebSearchSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$WebSearchSettingsToJson(this);

  @override
  List<Object?> get hashParameters => [
    routeThroughTor,
    searchMode,
    language,
    region,
    safeSearch,
    timeRange,
  ];
}
