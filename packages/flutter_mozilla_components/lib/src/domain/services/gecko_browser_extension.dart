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
    List<String> htmlList,
  ) async {
    final markdownResult = await _apiInstance.getMarkdown(htmlList);

    final results =
        markdownResult
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
  void onFeedRequested(int timestamp, String url) {
    _feedRequest.addWhenMoreRecent(timestamp, null, url);
  }

  void dispose() {
    unawaited(_feedRequest.close());
  }
}
