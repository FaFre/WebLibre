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

  /// [PlatformException.code] of a [turndownHtml] call made before the
  /// extension listens. Nothing was converted; worth retrying later.
  static const unavailableErrorCode = 'unavailable';

  /// Converts each of [htmlList] to markdown and plain text, in order.
  ///
  /// An entry is `null` when the extension failed to convert that document;
  /// the others are unaffected.
  static Future<List<TurndownResults?>> turndownHtml(
    List<String> htmlList, {
    Duration timeout = const Duration(seconds: 1),
  }) async {
    if (htmlList.isEmpty) {
      return [];
    }

    final markdownResult = await _apiInstance
        .getMarkdown(htmlList)
        .timeout(timeout);

    final results = markdownResult.map((result) {
      final document = result as Map<Object?, Object?>;
      final markdown = document['fullContentMarkdown'];
      final plain = document['fullContentPlain'];
      if (markdown is! String || plain is! String) {
        return null;
      }

      return TurndownResults(markdown: markdown, plain: plain);
    }).toList();

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
  Future<void> onFeedRequested(int sequence, String url) async {
    _feedRequest.addWhenMoreRecent(sequence, null, url);
  }

  void dispose() {
    unawaited(_feedRequest.close());
  }
}
