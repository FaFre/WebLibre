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
