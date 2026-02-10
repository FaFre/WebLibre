/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'package:rxdart/rxdart.dart';

final _lastEventTimes = <Subject, Map<dynamic, int>>{};

extension SubjectAddRecent<T> on Subject<T> {
  /// Adds [value] to this Subject only if [sequence] is greater than
  /// the last sequence number for this [identifier].
  ///
  /// Uses atomic event sequence numbers (from native EventSequence) to ensure
  /// events are processed in order and prevent out-of-order updates.
  /// Sequence numbers are monotonically increasing integers (0, 1, 2, ...).
  void addWhenMoreRecent(int sequence, dynamic identifier, T value) {
    _lastEventTimes[this] ??= {};

    if ((_lastEventTimes[this]?[identifier] ?? 0) < sequence) {
      _lastEventTimes[this]![identifier] = sequence;
      add(value);
    }
  }

  /// Updates this BehaviorSubject only if [sequence] is greater than
  /// the last sequence number for this [identifier].
  ///
  /// Uses atomic event sequence numbers (from native EventSequence) to ensure
  /// events are processed in order and prevent out-of-order updates.
  /// Sequence numbers are monotonically increasing integers (0, 1, 2, ...).
  void updateWhenMoreRecent(
    int sequence,
    dynamic identifier,
    T Function(T? currentValue) update,
  ) {
    assert(this is BehaviorSubject, 'This only works with BehaviourSubject');

    _lastEventTimes[this] ??= {};

    if ((_lastEventTimes[this]?[identifier] ?? 0) < sequence) {
      _lastEventTimes[this]![identifier] = sequence;
      add(update((this as BehaviorSubject<T>).valueOrNull));
    }
  }
}
