/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';

class GeckoLoggingService extends GeckoLogging {
  final void Function(LogLevel level, String message) handleLog;

  GeckoLoggingService.setUp(
    this.handleLog, {
    BinaryMessenger? binaryMessenger,
    String messageChannelSuffix = '',
  }) {
    GeckoLogging.setUp(
      this,
      binaryMessenger: binaryMessenger,
      messageChannelSuffix: messageChannelSuffix,
    );
  }

  @override
  void onLog(LogLevel level, String message) {
    handleLog(level, message);
  }
}
