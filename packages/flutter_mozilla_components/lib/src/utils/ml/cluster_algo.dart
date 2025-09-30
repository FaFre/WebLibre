import 'dart:math' as math;

const double _epsilon = 1e-10;

/// Performs K-Means clustering with K-Means++ initialization of centroids.
/// If an existing cluster is specified with [anchorIndices], then one of the centroids
/// is the average of the embeddings of the items in the cluster.
List<List<int>> kmeansPlusPlus({
  required List<List<double>> data,
  required int k,
  int? maxIterations,
  double Function()? randomFunc,
  List<int> anchorIndices = const [],
  List<int> preassignedIndices = const [],
  bool freezeAnchorsInZeroCluster = true,
}) {
  randomFunc ??= math.Random().nextDouble;
  maxIterations ??= 300;

  final dimensions = data[0].length;
  final centroids = initializeCentroidsSorted(
    X: data,
    k: k,
    randomFunc: randomFunc,
    anchorIndices: anchorIndices,
  );

  List<List<int>> resultClusters = [];
  final anchorSet = Set<int>.from(anchorIndices);
  final preassignedSet = Set<int>.from(preassignedIndices);

  for (int iter = 0; iter < maxIterations; iter++) {
    resultClusters = List.generate(k, (_) => <int>[]);
    bool hasChanged = false;

    // Assign each data point to the nearest centroid
    for (int i = 0; i < data.length; i++) {
      if (freezeAnchorsInZeroCluster && anchorSet.contains(i)) {
        resultClusters[0].add(i);
      } else {
        final point = data[i];
        final centroidIndex = getClosestCentroid(
          point,
          centroids,
          excludeIndex: preassignedSet.contains(i) && !anchorSet.contains(i)
              ? 0
              : -1,
        );
        resultClusters[centroidIndex].add(i);
      }
    }

    // Recompute centroids
    for (int j = 0; j < k; j++) {
      final newCentroid = _computeCentroid(resultClusters[j], data, dimensions);
      if (!_arePointsEqual(centroids[j], newCentroid)) {
        centroids[j] = newCentroid;
        hasChanged = true;
      }
    }

    // Stop if centroids don't change
    if (!hasChanged) {
      break;
    }
  }

  return resultClusters;
}

/// Kmeans++ initialization of centroids by finding ones farther than one another
List<List<double>> initializeCentroidsSorted({
  required List<List<double>> X,
  required int k,
  required double Function() randomFunc,
  int? numTrials,
  List<int> anchorIndices = const [],
}) {
  final nSamples = X.length;
  final nFeatures = X[0].length;
  final centers = List.generate(k, (_) => List<double>.filled(nFeatures, 0.0));
  numTrials ??= 2 + (math.log(k) / math.ln10).floor();

  void zeroOutAnchorItems(List<double> arr) {
    for (final a in anchorIndices) {
      arr[a] = 0;
    }
  }

  // First center is random unless anchor is specified
  int centerId;
  if (anchorIndices.length <= 1) {
    if (anchorIndices.length == 1) {
      centerId = anchorIndices[0];
    } else {
      centerId = (randomFunc() * nSamples).floor();
    }
    centers[0] = X[centerId];
  } else {
    centers[0] = vectorNormalize(
      vectorMean(anchorIndices.map((a) => X[a]).toList()),
    );
  }

  // Get closest distances
  final closestDistSq = euclideanDistancesSquared(centers[0], X);
  double sumOfDistances = closestDistSq.reduce((sum, dist) => sum + dist);

  // Pick the remaining nClusters-1 points
  for (int c = 1; c < k; c++) {
    // Choose center candidates by sampling
    final randVals = List.generate(
      numTrials,
      (_) => randomFunc() * sumOfDistances,
    );
    final closestDistSqForSamples = List<double>.from(closestDistSq);

    if (anchorIndices.length > 1) {
      zeroOutAnchorItems(closestDistSqForSamples);
    }

    final cumulativeProbs = stableCumsum(closestDistSqForSamples);
    final candidateIds = randVals
        .map((randVal) => searchSorted(cumulativeProbs, randVal))
        .where((candId) => candId < nSamples)
        .toList();

    // Compute distances to center candidates
    final distancesToCandidates = candidateIds
        .map((candidateId) => euclideanDistancesSquared(X[candidateId], X))
        .toList();

    // Update closest distances squared and potential for each candidate
    final candidatesSumOfDistances = distancesToCandidates.map((distances) {
      double sum = 0;
      for (int j = 0; j < closestDistSq.length; j++) {
        sum += math.min(closestDistSq[j], distances[j]);
      }
      return sum;
    }).toList();

    // Choose the best candidate
    int bestCandidateIdx = 0;
    for (int i = 1; i < candidatesSumOfDistances.length; i++) {
      if (candidatesSumOfDistances[i] <
          candidatesSumOfDistances[bestCandidateIdx]) {
        bestCandidateIdx = i;
      }
    }

    final bestCandidate = candidateIds[bestCandidateIdx];

    // Update closest distance and potential
    for (int i = 0; i < closestDistSq.length; i++) {
      closestDistSq[i] = math.min(
        closestDistSq[i],
        distancesToCandidates[bestCandidateIdx][i],
      );
    }
    sumOfDistances = candidatesSumOfDistances[bestCandidateIdx];

    // Pick best candidate
    centers[c] = X[bestCandidate];
  }

  return centers;
}

/// Helper function to find closest centroid for a given point
int getClosestCentroid(
  List<double> point,
  List<List<double>> centroids, {
  int excludeIndex = -1,
}) {
  double minDistance = double.infinity;
  int closestIndex = -1;

  for (int i = 0; i < centroids.length; i++) {
    final distance = euclideanDistance(point, centroids[i]);
    if (distance < minDistance && i != excludeIndex) {
      minDistance = distance;
      closestIndex = i;
    }
  }

  return closestIndex;
}

/// Helper function to compute Euclidean distance between two points
double euclideanDistance(
  List<double> point1,
  List<double> point2, {
  bool squareResult = false,
}) {
  double sum = 0;
  for (int i = 0; i < point1.length; i++) {
    final diff = point1[i] - point2[i];
    sum += diff * diff;
  }
  return squareResult ? sum : math.sqrt(sum);
}

/// Normalize a vector
List<double> vectorNormalize(List<double> vector) {
  final magnitude = math.sqrt(vector.fold(0.0, (sum, c) => sum + c * c));
  if (magnitude == 0) {
    return List<double>.filled(vector.length, 0.0);
  }
  return vector.map((c) => c / magnitude).toList();
}

/// Find average of two vectors
List<double> vectorMean(List<List<double>> vectors) {
  if (vectors.isEmpty) {
    return [];
  }
  final dims = vectors[0].length;
  final sum = List<double>.filled(dims, 0.0);

  for (final vector in vectors) {
    for (int i = 0; i < dims; i++) {
      sum[i] += vector[i];
    }
  }

  return sum.map((a) => a / vectors.length).toList();
}

/// Find distances from a single point to a list of points
List<double> euclideanDistancesSquared(
  List<double> point,
  List<List<double>> X,
) {
  return X.map((row) {
    double distSq = 0;
    for (int i = 0; i < row.length; i++) {
      final diff = row[i] - point[i];
      distSq += diff * diff;
    }
    return distSq;
  }).toList();
}

/// Cumulative sum for an array
List<double> stableCumsum(List<double> arr) {
  double sum = 0;
  return arr.map((value) => sum += value).toList();
}

/// Binary search
int searchSorted(List<double> arr, double val) {
  int low = 0;
  int high = arr.length;

  while (low < high) {
    final mid = (low + high) ~/ 2;
    if (arr[mid] < val) {
      low = mid + 1;
    } else {
      high = mid;
    }
  }

  return low;
}

/// Compute centroid of a cluster by reference
List<double> _computeCentroid(
  List<int> cluster,
  List<List<double>> data,
  int dimensions,
) {
  if (cluster.isEmpty) {
    return List<double>.filled(dimensions, 0.0);
  }

  final centroid = List<double>.filled(dimensions, 0.0);

  for (final index in cluster) {
    final point = data[index];
    for (int i = 0; i < dimensions; i++) {
      centroid[i] += point[i];
    }
  }

  for (int p = 0; p < dimensions; p++) {
    centroid[p] /= cluster.length;
  }

  return centroid;
}

/// Returns true if both points have equal values
bool _arePointsEqual(List<double> point1, List<double> point2) {
  if (point1.length != point2.length) return false;
  for (int i = 0; i < point1.length; i++) {
    if ((point1[i] - point2[i]).abs() > _epsilon) return false;
  }
  return true;
}
