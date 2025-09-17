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
}
