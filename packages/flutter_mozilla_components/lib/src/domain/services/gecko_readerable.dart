/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/src/extensions/subject.dart';
import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';
import 'package:rxdart/rxdart.dart';

class GeckoReaderableService extends ReaderViewController {
  final ReaderViewEvents _events;

  final _appearanceVisibility = BehaviorSubject<bool>();

  Stream<bool> get appearanceVisibility => _appearanceVisibility.stream;

  Future<void> toggleReaderView(bool enable) {
    return _events.onToggleReaderView(enable);
  }

  Future<void> onAppearanceButtonTap() {
    return _events.onAppearanceButtonTap();
  }

  @override
  void appearanceButtonVisibility(int timestamp, bool visible) {
    _appearanceVisibility.addWhenMoreRecent(timestamp, null, visible);
  }

  GeckoReaderableService.setUp({
    ReaderViewEvents? readerEvents,
    BinaryMessenger? binaryMessenger,
    String messageChannelSuffix = '',
  }) : _events =
           readerEvents ??
           ReaderViewEvents(
             binaryMessenger: binaryMessenger,
             messageChannelSuffix: messageChannelSuffix,
           ) {
    ReaderViewController.setUp(
      this,
      binaryMessenger: binaryMessenger,
      messageChannelSuffix: messageChannelSuffix,
    );
  }

  Future<void> dispose() async {
    await _appearanceVisibility.close();
  }
}
