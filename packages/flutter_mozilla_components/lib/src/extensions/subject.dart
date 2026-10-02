/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'package:rxdart/rxdart.dart';

/// The newest sequence number accepted per identifier, per subject.
///
/// An [Expando] rather than a map keyed by subject, so a subject's entries go
/// when the subject does instead of being held for the life of the isolate.
final _lastEventTimes = Expando<Map<dynamic, int>>('lastEventTimes');

extension SubjectAddRecent<T> on Subject<T> {
  /// Adds [value] to this Subject only if [sequence] is greater than
  /// the last sequence number for this [identifier].
  ///
  /// Uses atomic event sequence numbers (from native EventSequence) to ensure
  /// events are processed in order and prevent out-of-order updates.
  /// Sequence numbers are monotonically increasing integers (0, 1, 2, ...).
  ///
  /// Returns whether [value] was added.
  bool addWhenMoreRecent(int sequence, dynamic identifier, T value) {
    final lastEventTimes = _lastEventTimes[this] ??= {};

    if ((lastEventTimes[identifier] ?? 0) < sequence) {
      lastEventTimes[identifier] = sequence;
      add(value);
      return true;
    }

    return false;
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

    final lastEventTimes = _lastEventTimes[this] ??= {};

    if ((lastEventTimes[identifier] ?? 0) < sequence) {
      lastEventTimes[identifier] = sequence;
      add(update((this as BehaviorSubject<T>).valueOrNull));
    }
  }

  /// Stops tracking the sequence numbers of [identifiers] — closed tabs, say,
  /// which would otherwise hold an entry for the rest of the session. The next
  /// event for a forgotten identifier is accepted whatever its number.
  void forgetSequences(Iterable<dynamic> identifiers) {
    final lastEventTimes = _lastEventTimes[this];
    if (lastEventTimes == null) {
      return;
    }

    for (final identifier in identifiers) {
      lastEventTimes.remove(identifier);
    }
  }
}
