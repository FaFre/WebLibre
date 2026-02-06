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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/history/domain/entities/history_filter_options.dart';

part 'history.g.dart';

@Riverpod(keepAlive: true)
class HistoryRepository extends _$HistoryRepository {
  final _service = GeckoHistoryService();

  Future<void> deleteVisitsBetween(DateTime start, DateTime end) {
    return _service.deleteVisitsBetween(start, end);
  }

  Future<List<VisitInfo>> getDetailedVisits(HistoryFilterOptions options) {
    return _service
        .getDetailedVisits(
          options.dateRange?.start ?? DateTime(0),
          options.dateRange?.end ?? DateTime(9999),
          options.visitTypes,
        )
        .then(
          (visits) =>
              visits..sort((a, b) => b.visitTime.compareTo(a.visitTime)),
        );
  }

  Future<List<VisitInfo>> getVisitsPaginated({
    required int count,
    int offset = 0,
    Set<VisitType> types = const {VisitType.link},
  }) {
    return _service.getVisitsPaginated(offset, count, types);
  }

  Future<void> deleteVisit(VisitInfo info) {
    return _service.deleteVisit(info);
  }

  @override
  void build() {}
}
