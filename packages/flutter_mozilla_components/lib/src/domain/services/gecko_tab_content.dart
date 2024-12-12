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
  void onContentUpdate(int timestamp, TabContent content) {
    _contentSubject.addWhenMoreRecent(timestamp, content.tabId, content);
  }

  void dispose() {
    unawaited(_contentSubject.close());
  }
}
