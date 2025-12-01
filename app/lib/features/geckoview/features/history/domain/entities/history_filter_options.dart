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
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weblibre/data/database/converters/date_time_range.dart';

part 'history_filter_options.g.dart';

@JsonSerializable()
@CopyWith()
class HistoryFilterOptions with FastEquatable {
  @DateTimeRangeConverter()
  final DateTimeRange<DateTime>? dateRange;
  final Set<VisitType> visitTypes;

  HistoryFilterOptions({required this.dateRange, required this.visitTypes});

  HistoryFilterOptions.withDefaults()
    : this(dateRange: null, visitTypes: {VisitType.link});

  @override
  List<Object?> get hashParameters => [dateRange, visitTypes];

  factory HistoryFilterOptions.fromJson(Map<String, dynamic> json) =>
      _$HistoryFilterOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$HistoryFilterOptionsToJson(this);
}
