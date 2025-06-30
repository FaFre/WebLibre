/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'dart:convert';

import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';

final _apiInstance = GeckoPrefApi();

class GeckoPrefService {
  Future<Map<String, Object>> getAllPrefs() {
    return _apiInstance.getPrefs(null);
  }

  Future<Map<String, Object>> getPrefs(List<String> prefs) {
    return _apiInstance.getPrefs(prefs);
  }

  Future<Map<String, Object>> applyPrefs(Map<String, Object> prefs) {
    final buffer = prefs.entries.map((pref) {
      final value = switch (pref.value) {
        final bool x => '$x',
        final int x => '$x',
        final String x => jsonEncode(x),
        _ => throw Exception('Unknow pref type'),
      };

      return 'user_pref("${pref.key}", $value);';
    }).join();

    return _apiInstance.applyPrefs(buffer);
  }

  Future<void> resetPrefs(List<String> prefs) {
    return _apiInstance.resetPrefs(prefs);
  }
}
