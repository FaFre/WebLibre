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
import 'package:flutter/material.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod/experimental/persist.dart';
import 'package:riverpod_annotation/experimental/json_persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/history/domain/entities/history_filter_options.dart';
import 'package:weblibre/features/geckoview/features/history/domain/repositories/history.dart';
import 'package:weblibre/features/user/data/providers.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
@JsonPersist()
class HistoryFilter extends _$HistoryFilter {
  void updateVisitType(VisitType type, bool value) {
    if (value) {
      state = state.copyWith.visitTypes({...state.visitTypes, type});
    } else {
      state = state.copyWith.visitTypes({...state.visitTypes}..remove(type));
    }
  }

  void reset() {
    state = HistoryFilterOptions.withDefaults();
  }

  void setDateRange(DateTimeRange<DateTime>? range) {
    state = state.copyWith.dateRange(range);
  }

  @override
  HistoryFilterOptions build() {
    persist(
      ref.watch(riverpodDatabaseStorageProvider),
      key: 'HistoryFilterOptions',
    );

    return stateOrNull ?? HistoryFilterOptions.withDefaults();
  }
}

@Riverpod()
Future<List<VisitInfo>> browsingHistory(Ref ref) {
  final options = ref.watch(historyFilterProvider);

  return ref
      .read(historyRepositoryProvider.notifier)
      .getDetailedVisits(options);
}
