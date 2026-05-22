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

  Future<List<HistoryHighlight>> getHistoryHighlights({
    double viewTimeWeight = 10.0,
    double frequencyWeight = 4.0,
    required int limit,
  }) {
    return _service.getHistoryHighlights(
      weights: HistoryHighlightWeights(
        viewTime: viewTimeWeight,
        frequency: frequencyWeight,
      ),
      limit: limit,
    );
  }

  Future<List<TopFrecentSiteInfo>> getTopFrecentSites({
    required int limit,
    FrecencyThresholdOption frecencyThreshold =
        FrecencyThresholdOption.skipOneTimePages,
  }) {
    return _service.getTopFrecentSites(
      limit: limit,
      frecencyThreshold: frecencyThreshold,
    );
  }

  Future<HistoryMetadata?> getLatestHistoryMetadataForUrl(String url) {
    return _service.getLatestHistoryMetadataForUrl(url);
  }

  Future<List<HistoryMetadata?>> getLatestHistoryMetadataForUrls(
    List<String> urls,
  ) {
    return _service.getLatestHistoryMetadataForUrls(urls);
  }

  Future<List<bool>> getVisited(List<String> urls) {
    return _service.getVisited(urls);
  }

  Future<List<HistorySuggestion>> getSuggestions(
    String query, {
    int limit = 10,
  }) {
    return _service.getSuggestions(query, limit: limit);
  }

  Future<List<HistoryMetadata>> queryHistoryMetadata(
    String query, {
    int limit = 10,
  }) {
    return _service.queryHistoryMetadata(query, limit: limit);
  }

  Future<void> recordObservation(
    String url, {
    String? title,
    String? previewImageUrl,
  }) {
    return _service.recordObservation(
      url,
      title: title,
      previewImageUrl: previewImageUrl,
    );
  }

  Future<void> noteViewTime(HistoryMetadataKey key, Duration viewTime) {
    return _service.noteHistoryMetadataViewTime(key, viewTime);
  }

  Future<void> noteDocumentType(
    HistoryMetadataKey key,
    DocumentType documentType,
  ) {
    return _service.noteHistoryMetadataDocumentType(key, documentType);
  }

  Future<void> deleteVisitsFor(String url) {
    return _service.deleteVisitsFor(url);
  }

  Future<void> deleteVisitsSince(DateTime since) {
    return _service.deleteVisitsSince(since);
  }

  Future<void> deleteEverything() {
    return _service.deleteEverything();
  }

  Future<void> deleteHistoryMetadataOlderThan(DateTime olderThan) {
    return _service.deleteHistoryMetadataOlderThan(olderThan);
  }

  @override
  void build() {}
}
