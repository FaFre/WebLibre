/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/src/domain/entities/turndown_result.dart';
import 'package:flutter_mozilla_components/src/extensions/subject.dart';
import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';
import 'package:rxdart/rxdart.dart';

final _apiInstance = GeckoBrowserExtensionApi();

class GeckoBrowserExtensionService extends BrowserExtensionEvents {
  final _feedRequest = BehaviorSubject<String>();

  Stream<String> get feedRequested => _feedRequest.stream;

  static Future<List<TurndownResults>> turndownHtml(
    List<String> htmlList, {
    Duration timeout = const Duration(seconds: 1),
  }) async {
    if (htmlList.isEmpty) {
      return [];
    }

    final markdownResult = await _apiInstance
        .getMarkdown(htmlList)
        .timeout(timeout);

    final results = markdownResult
        .cast()
        .map(
          (result) => TurndownResults(
            // ignore: avoid_dynamic_calls valid
            markdown: result['fullContentMarkdown'] as String,
            // ignore: avoid_dynamic_calls valid
            plain: result['fullContentPlain'] as String,
          ),
        )
        .toList();

    return results;
  }

  GeckoBrowserExtensionService.setUp({
    BinaryMessenger? binaryMessenger,
    String messageChannelSuffix = '',
  }) {
    BrowserExtensionEvents.setUp(
      this,
      binaryMessenger: binaryMessenger,
      messageChannelSuffix: messageChannelSuffix,
    );
  }

  @override
  void onFeedRequested(int sequence, String url) {
    _feedRequest.addWhenMoreRecent(sequence, null, url);
  }

  void dispose() {
    unawaited(_feedRequest.close());
  }
}
