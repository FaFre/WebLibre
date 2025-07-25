/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'package:collection/collection.dart';
import 'package:flutter_mozilla_components/src/utils/ml/cosine_similarity.dart';

List<String> findNearestNeighborsRecursive({
  required Map<String, List<double>> embeddings,
  required List<String> assignedDocuments,
  required List<String> unassignedDocuments,
  int thresholdMills = 275,
  int maxAssignedCount = 4,
  int depth = 0,
}) {
  final closestTabs = <(String, double)>[];
  final similarTabsIndices = <String>[];

  for (final unassigned in unassignedDocuments) {
    double? closestScore;
    for (final assigned in assignedDocuments.take(maxAssignedCount)) {
      final cosineSim = cosSim(embeddings[unassigned]!, embeddings[assigned]!);

      if (closestScore == null || cosineSim > closestScore) {
        closestScore = cosineSim;
      }
    }

    // threshold could also be set via a nimbus experiment, in which case
    // it will be an int <= 1000
    if (closestScore != null && closestScore > thresholdMills / 1000) {
      closestTabs.add((unassigned, closestScore));
      similarTabsIndices.add(unassigned);
    }
  }

  closestTabs.sort((a, b) => b.$2.compareTo(a.$2));

  final result = closestTabs.map((t) => t.$1).toList();

  // recurse once if the initial call only had a single tab
  // and we found at least 1 similar tab - this improves recall
  if (assignedDocuments.length == 1 && closestTabs.isNotEmpty && depth == 1) {
    final recurseSimilarTabs = findNearestNeighborsRecursive(
      unassignedDocuments: unassignedDocuments
          .whereNot(similarTabsIndices.contains)
          .toList(),
      assignedDocuments: similarTabsIndices,
      thresholdMills: thresholdMills,
      embeddings: embeddings,
      depth: depth - 1,
    );

    result.addAll(recurseSimilarTabs);
  }

  return result;
}
