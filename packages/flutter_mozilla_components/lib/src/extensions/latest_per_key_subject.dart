/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'dart:async';

import 'package:flutter_mozilla_components/src/extensions/subject.dart';
import 'package:rxdart/rxdart.dart';

/// A [Subject] that replays to each new listener only the latest event per
/// key, in the order those events arrived.
///
/// For streams of per-tab state. A [ReplaySubject] would hold every event of
/// the session — each load progress tick, each copy of a tab's back/forward
/// list — when all a late listener needs is where each tab stands now.
class LatestPerKeySubject<K, T> extends Subject<T> {
  final K Function(T event) _keyOf;
  final Map<K, T> _latest;
  final _addedSinceRetain = <K>{};

  /// The keys the previous [retainKeys] call was given.
  var _live = <K>{};

  factory LatestPerKeySubject(K Function(T event) keyOf) {
    // ignore: close_sinks
    final controller = StreamController<T>.broadcast();
    final latest = <K, T>{};

    return LatestPerKeySubject._(
      controller,
      Rx.defer(
        () => controller.stream.startWithMany(
          latest.values.toList(growable: false),
        ),
        reusable: true,
      ),
      keyOf,
      latest,
    );
  }

  LatestPerKeySubject._(
    super.controller,
    super.stream,
    this._keyOf,
    this._latest,
  );

  /// The events a new listener receives first, oldest first.
  List<T> get values => _latest.values.toList(growable: false);

  @override
  void onAdd(T event) {
    final key = _keyOf(event);

    // Removed first so that re-inserting moves the key to the end: replay
    // follows the order the latest events arrived in.
    _latest.remove(key);
    _latest[key] = event;
    _addedSinceRetain.add(key);
  }

  /// Drops what is held for keys not in [live], together with their sequence
  /// numbers (see [SubjectAddRecent.addWhenMoreRecent]).
  ///
  /// A key missing from [live] that received an event since the previous call
  /// is kept for one more call, unless that call listed it. A new tab's first
  /// events can arrive before the tab list that includes it; a tab that was
  /// listed and no longer is has closed, whatever it reported on the way out,
  /// and no further call may come to drop it: an unchanged list is not
  /// re-sent.
  void retainKeys(Set<K> live) {
    final dropped = [
      for (final key in _latest.keys)
        if (!live.contains(key) &&
            (_live.contains(key) || !_addedSinceRetain.contains(key)))
          key,
    ];
    _live = live;
    _addedSinceRetain.clear();

    if (dropped.isEmpty) {
      return;
    }

    for (final key in dropped) {
      _latest.remove(key);
    }
    forgetSequences(dropped);
  }
}
