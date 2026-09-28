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
import 'package:weblibre/features/geckoview/features/history/domain/entities/history_entry.dart';
import 'package:weblibre/features/geckoview/features/history/domain/entities/history_filter_options.dart';
import 'package:weblibre/features/geckoview/features/history/domain/repositories/container_history.dart';
import 'package:weblibre/features/geckoview/features/history/domain/repositories/history.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
import 'package:weblibre/features/user/data/providers.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
@JsonPersist()
class HistoryVisitsFilter extends _$HistoryVisitsFilter {
  void updateVisitType(VisitType type, bool value) {
    if (value) {
      state = state.copyWith.visitTypes({...state.visitTypes, type});
    } else {
      state = state.copyWith.visitTypes({...state.visitTypes}..remove(type));
    }
  }

  void setContainer(String? containerId) {
    state = state.copyWith.containerId(containerId);
  }

  void reset() {
    state = HistoryFilterOptions.withDefaults();
  }

  void setDateRange(DateTimeRange<DateTime>? range) {
    state = state.copyWith.dateRange(range);
  }

  void setDistinctUrls(bool value) {
    state = state.copyWith.distinctUrls(value);
  }

  @override
  HistoryFilterOptions build() {
    persist(
      ref.watch(riverpodDatabaseStorageProvider),
      key: 'HistoryVisitsFilterOptions',
      options: const StorageOptions(
        cacheTime: StorageCacheTime(Duration(days: 7)),
      ),
    );

    return stateOrNull ?? HistoryFilterOptions.withDefaults();
  }
}

@Riverpod(keepAlive: true)
@JsonPersist()
class HistoryDownloadsFilter extends _$HistoryDownloadsFilter {
  void reset() {
    state = HistoryFilterOptions(
      dateRange: null,
      visitTypes: const {VisitType.download},
    );
  }

  void setDateRange(DateTimeRange<DateTime>? range) {
    state = state.copyWith.dateRange(range);
  }

  @override
  HistoryFilterOptions build() {
    persist(
      ref.watch(riverpodDatabaseStorageProvider),
      key: 'HistoryDownloadsFilterOptions',
      options: const StorageOptions(
        cacheTime: StorageCacheTime(Duration(days: 7)),
      ),
    );

    return stateOrNull ??
        HistoryFilterOptions(
          dateRange: null,
          visitTypes: const {VisitType.download},
        );
  }
}

@Riverpod()
Future<List<HistoryEntry>> browsingHistory(Ref ref) async {
  final options = ref.watch(historyVisitsFilterProvider);

  final visits = await ref
      .read(historyRepositoryProvider.notifier)
      .getDetailedVisits(options);

  final entries = await annotateVisitsWithContainers(
    ref.read(tabDatabaseProvider).visitContainerDao,
    visits,
    filterContainerId: options.containerId,
  );

  // Collapsed after the container filter, so a distinct row is the newest
  // visit within the container being shown.
  return options.distinctUrls ? collapseToDistinctUrls(entries) : entries;
}

@Riverpod()
Future<List<HistoryEntry>> browsingDownloads(Ref ref) async {
  final options = ref.watch(historyDownloadsFilterProvider);

  final visits = await ref
      .read(historyRepositoryProvider.notifier)
      .getDetailedVisits(options);

  // Downloads are never recorded in the visit→container relation (it is written
  // only from page-visit `onVisited` events). Do NOT run the nearest-time
  // annotation here: a download sharing a canonical URL + time window with a
  // contained page visit would otherwise steal that visit's tag, show a bogus
  // container chip, and — on delete — drop the page visit's relation row.
  return visits
      .map((visit) => HistoryEntry(visit: visit, containerIds: const []))
      .toList(growable: false);
}
