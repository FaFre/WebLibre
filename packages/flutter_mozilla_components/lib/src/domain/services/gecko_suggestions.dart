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

final _apiInstance = GeckoSuggestionApi();

class GeckoSuggestionsService extends GeckoSuggestionEvents {
  final GeckoSuggestionApi _api;
  final _suggestionsSubject = PublishSubject<List<GeckoSuggestion>>();

  Stream<List<GeckoSuggestion>> get suggestionsStream =>
      _suggestionsSubject.stream;

  GeckoSuggestionsService.setUp({
    BinaryMessenger? binaryMessenger,
    String messageChannelSuffix = '',
    GeckoSuggestionApi? api,
  }) : _api = api ?? _apiInstance {
    GeckoSuggestionEvents.setUp(
      this,
      binaryMessenger: binaryMessenger,
      messageChannelSuffix: messageChannelSuffix,
    );
  }

  Future<void> querySuggestions(
    String text, {
    List<GeckoSuggestionType> providers = const [
      GeckoSuggestionType.session,
      GeckoSuggestionType.clipboard,
      GeckoSuggestionType.history,
    ],
  }) {
    return _api.querySuggestions(text, providers);
  }

  Future<AutocompleteResult?> getAutocompleteSuggestion(String query) {
    return _api.getAutocompleteSuggestion(query);
  }

  @override
  void onSuggestionResult(
    int timestamp,
    GeckoSuggestionType suggestionType,
    List<GeckoSuggestion> suggestions,
  ) {
    _suggestionsSubject.addWhenMoreRecent(
      timestamp,
      suggestionType,
      suggestions,
    );
  }

  void dispose() {
    unawaited(_suggestionsSubject.close());
  }
}
