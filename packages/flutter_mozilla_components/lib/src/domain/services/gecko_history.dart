/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';

final _apiInstance = GeckoHistoryApi();

class GeckoHistoryService {
  final GeckoHistoryApi _api;

  GeckoHistoryService({GeckoHistoryApi? api}) : _api = api ?? _apiInstance;

  Future<List<VisitInfo>> getDetailedVisits(
    DateTime start,
    DateTime end,
    Set<VisitType> types,
  ) {
    return _api.getDetailedVisits(
      start.millisecondsSinceEpoch,
      end.millisecondsSinceEpoch,
      VisitType.values.toSet().difference(types).toList(),
    );
  }

  Future<List<VisitInfo>> getVisitsPaginated(
    int offset,
    int count,
    Set<VisitType> types,
  ) {
    return _api.getVisitsPaginated(
      offset,
      count,
      VisitType.values.toSet().difference(types).toList(),
    );
  }

  Future<void> deleteVisit(VisitInfo info) {
    switch (info.visitType) {
      case VisitType.link:
      case VisitType.typed:
      case VisitType.embed:
      case VisitType.redirectPermanent:
      case VisitType.redirectTemporary:
      case VisitType.framedLink:
      case VisitType.reload:
        return _api.deleteVisit(info.url, info.visitTime);
      case VisitType.download:
        return _api.deleteDownload(info.contentId!);
      case VisitType.bookmark:
        throw UnimplementedError('VisitType.bookmark deletion not implemented');
    }
  }

  Future<void> deleteVisitsBetween(DateTime start, DateTime end) {
    return _api.deleteVisitsBetween(
      start.millisecondsSinceEpoch,
      end.millisecondsSinceEpoch,
    );
  }
}
