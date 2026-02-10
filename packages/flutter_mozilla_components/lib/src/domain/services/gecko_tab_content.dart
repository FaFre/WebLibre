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

class GeckoTabContentService extends GeckoTabContentEvents {
  final _contentSubject = BehaviorSubject<TabContent>();

  Stream<TabContent> get tabContentStream => _contentSubject.stream;

  GeckoTabContentService.setUp({
    BinaryMessenger? binaryMessenger,
    String messageChannelSuffix = '',
  }) {
    GeckoTabContentEvents.setUp(
      this,
      binaryMessenger: binaryMessenger,
      messageChannelSuffix: messageChannelSuffix,
    );
  }

  @override
  void onContentUpdate(int sequence, TabContent content) {
    _contentSubject.addWhenMoreRecent(sequence, content.tabId, content);
  }

  Future<void> dispose() async {
    await _contentSubject.close();
  }
}
