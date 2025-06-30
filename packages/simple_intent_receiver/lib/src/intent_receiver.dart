import 'dart:async';

import 'package:flutter/services.dart';
import 'package:simple_intent_receiver/src/pigeons/intent.g.dart';

class IntentReceiver extends IntentEvents {
  final _controller = StreamController<Intent>();
  int? _lastAdded;

  Stream<Intent> get events => _controller.stream;

  @override
  void onIntentReceived(int timestamp, Intent intent) {
    if (_lastAdded == null || timestamp > _lastAdded!) {
      _controller.add(intent);
    }
  }

  IntentReceiver.setUp({
    BinaryMessenger? binaryMessenger,
    String messageChannelSuffix = '',
  }) {
    IntentEvents.setUp(
      this,
      binaryMessenger: binaryMessenger,
      messageChannelSuffix: messageChannelSuffix,
    );
  }

  Future<void> dispose() async {
    await _controller.close();
  }
}
