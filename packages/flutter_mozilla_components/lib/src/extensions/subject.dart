/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'package:rxdart/rxdart.dart';

final _lastEventTimes = <Subject, Map<dynamic, int>>{};

extension SubjectAddRecent<T> on Subject<T> {
  void addWhenMoreRecent(int timestamp, dynamic identifier, T value) {
    _lastEventTimes[this] ??= {};

    if ((_lastEventTimes[this]?[identifier] ?? 0) < timestamp) {
      _lastEventTimes[this]![identifier] = timestamp;
      add(value);
    }
  }

  void updateWhenMoreRecent(
    int timestamp,
    dynamic identifier,
    T Function(T? currentValue) update,
  ) {
    assert(this is BehaviorSubject, 'This only works with BehaviourSubject');

    _lastEventTimes[this] ??= {};

    if ((_lastEventTimes[this]?[identifier] ?? 0) < timestamp) {
      _lastEventTimes[this]![identifier] = timestamp;
      add(update((this as BehaviorSubject<T>).valueOrNull));
    }
  }
}
