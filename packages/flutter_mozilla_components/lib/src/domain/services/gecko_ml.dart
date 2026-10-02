/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'dart:typed_data';

import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';

final _apiInstance = GeckoMlApi();

class GeckoMlService {
  Future<String> predictDocumentTopic(Set<String> titles, {int maxCount = 10}) {
    var selectedTitles = titles.toList();
    if (selectedTitles.length > maxCount) {
      //TODO: Randomize for now, maybe use clusters later
      selectedTitles = (selectedTitles..shuffle()).take(maxCount).toList();
    }

    return _apiInstance.predictDocumentTopic(selectedTitles);
  }

  /// One embedding per document, in order.
  ///
  /// Copied into [Float64List]s: what arrives is a list of boxed doubles, and
  /// a cast view over it type-checks every element read in the clustering and
  /// similarity loops, which read each one many times.
  Future<List<List<double>>> generateDocumentEmbeddings(
    List<String> documents,
  ) async {
    final embeddings = await _apiInstance.generateDocumentEmbeddings(documents);

    return embeddings
        .map((values) => Float64List.fromList((values! as List).cast()))
        .toList();
  }

  Future<void> clearMlCache() {
    return _apiInstance.clearMlCache();
  }
}
