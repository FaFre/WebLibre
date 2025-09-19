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
import 'package:flutter/material.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/history/domain/entities/history_filter_options.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
class HistoryFilter extends _$HistoryFilter {
  void updateVisitType(VisitType type, bool value) {
    if (value) {
      state = state.copyWith.visitTypes({...state.visitTypes, type});
    } else {
      state = state.copyWith.visitTypes({...state.visitTypes}..remove(type));
    }
  }

  void setDateRange(DateTimeRange<DateTime>? range) {
    state = state.copyWith.dateRange(range);
  }

  @override
  HistoryFilterOptions build() {
    return HistoryFilterOptions.withDefaults();
  }
}

@Riverpod()
Future<List<VisitInfo>> browsingHistory(Ref ref) {
  final options = ref.watch(historyFilterProvider);

  final service = GeckoHistoryService();
  return service
      .getDetailedVisits(
        options.dateRange?.start ?? DateTime(0),
        options.dateRange?.end ?? DateTime(9999),
        options.visitTypes,
      )
      .then(
        (visits) => visits..sort((a, b) => b.visitTime.compareTo(a.visitTime)),
      );
}
