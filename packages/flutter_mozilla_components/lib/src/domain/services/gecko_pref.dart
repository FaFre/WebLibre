/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';

final _apiInstance = GeckoPrefApi();

class GeckoPrefService {
  Future<List<String>> getPrefList() {
    return _apiInstance.getPrefList();
  }

  Future<Map<String, GeckoPref>> getAllPrefs() async {
    return _apiInstance.getPrefs(await getPrefList());
  }

  Future<Map<String, GeckoPref>> getPrefs(List<String> prefs) {
    return _apiInstance.getPrefs(prefs);
  }

  Future<Map<String, GeckoPref>> applyPrefs(Map<String, Object> prefs) {
    return _apiInstance.applyPrefs(prefs);
  }

  Future<void> resetPrefs(List<String> prefs) {
    return _apiInstance.resetPrefs(prefs);
  }

  Future<void> startObserveChanges() {
    return _apiInstance.startObserveChanges();
  }

  Future<void> stopObserveChanges() {
    return _apiInstance.stopObserveChanges();
  }

  Future<void> registerPrefForObservation(String name) {
    return _apiInstance.registerPrefForObservation(name);
  }

  Future<void> unregisterPrefForObservation(String name) {
    return _apiInstance.unregisterPrefForObservation(name);
  }
}
