import 'dart:math' as math;

import 'package:flutter_mozilla_components/src/utils/ml/cluster_algo.dart';

/// Clusters embeddings using K-means algorithm with configurable parameters
List<List<int>> clusterEmbeddings({
  required List<List<double>> embeddings,
  int? k,
  double Function()? randomFunc,
  int clusteringTriesPerK = 3,
}) {
  k ??= 0;
  int startK = k;
  int endK = k + 1;

  if (k == 0) {
    startK = 2;
    // Find a reasonable max # of clusters
    endK =
        math.min(
          (math.log(embeddings.length) * 2.0).floor(),
          embeddings.length,
        ) +
        1;
  }

  List<List<int>>? bestResult;
  double bestResultSilScore = -100.0;

  for (int curK = startK; curK < endK; curK++) {
    List<List<int>>? bestItemsForK;
    double bestInertiaForK = 500000000000;

    for (int j = 0; j < clusteringTriesPerK; j++) {
      final allItems = kmeansPlusPlus(
        data: embeddings,
        k: curK,
        randomFunc: randomFunc,
        freezeAnchorsInZeroCluster: false, // Not needed since no anchors
      );

      final inertia = _getCentroidInertia(allItems, embeddings);
      if (inertia < bestInertiaForK) {
        bestInertiaForK = inertia;
        bestItemsForK = allItems;
      }
    }

    if (bestItemsForK != null) {
      final silScores = silhouetteCoefficients(embeddings, bestItemsForK);
      final avgSil = silScores.reduce((a, b) => a + b) / silScores.length;

      if (avgSil > bestResultSilScore) {
        bestResultSilScore = avgSil;
        bestResult = bestItemsForK;
      }
    }
  }

  return bestResult ?? [];
}

/// Computes the inertia (sum of squared distances to centroids) for clusters
double _getCentroidInertia(
  List<List<int>> clusters,
  List<List<double>> embeddings,
) {
  double totalDistance = 0.0;

  for (final cluster in clusters) {
    if (cluster.isEmpty) continue;

    // Compute centroid
    final dimensions = embeddings[0].length;
    final centroid = List<double>.filled(dimensions, 0.0);

    for (final index in cluster) {
      final point = embeddings[index];
      for (int i = 0; i < dimensions; i++) {
        centroid[i] += point[i];
      }
    }

    for (int i = 0; i < dimensions; i++) {
      centroid[i] /= cluster.length;
    }

    // Compute sum of squared distances to centroid
    for (final index in cluster) {
      final point = embeddings[index];
      double distanceSquared = 0.0;
      for (int i = 0; i < dimensions; i++) {
        distanceSquared += math.pow(point[i] - centroid[i], 2);
      }
      totalDistance += distanceSquared;
    }
  }

  return totalDistance;
}

/// Computes silhouette coefficients for clusters
List<double> silhouetteCoefficients(
  List<List<double>> embeddings,
  List<List<int>> clusters,
) {
  final silhouettes = <double>[];

  for (int clusterIdx = 0; clusterIdx < clusters.length; clusterIdx++) {
    final cluster = clusters[clusterIdx];
    if (cluster.length <= 1) {
      silhouettes.add(0.0);
      continue;
    }

    double clusterSilhouette = 0.0;

    for (final pointIdx in cluster) {
      final point = embeddings[pointIdx];

      // Compute average intra-cluster distance (a)
      double intraDistance = 0.0;
      for (final otherIdx in cluster) {
        if (pointIdx != otherIdx) {
          intraDistance += euclideanDistance(point, embeddings[otherIdx]);
        }
      }
      final a = cluster.length > 1 ? intraDistance / (cluster.length - 1) : 0.0;

      // Compute minimum average inter-cluster distance (b)
      double minInterDistance = double.infinity;
      for (
        int otherClusterIdx = 0;
        otherClusterIdx < clusters.length;
        otherClusterIdx++
      ) {
        if (otherClusterIdx == clusterIdx) continue;

        final otherCluster = clusters[otherClusterIdx];
        if (otherCluster.isEmpty) continue;

        double interDistance = 0.0;
        for (final otherIdx in otherCluster) {
          interDistance += euclideanDistance(point, embeddings[otherIdx]);
        }
        final avgInterDistance = interDistance / otherCluster.length;
        minInterDistance = math.min(minInterDistance, avgInterDistance);
      }

      final b = minInterDistance == double.infinity ? 0.0 : minInterDistance;

      // Compute silhouette for this point
      final silhouette = (a == 0.0 && b == 0.0)
          ? 0.0
          : (b - a) / math.max(a, b);
      clusterSilhouette += silhouette;
    }

    silhouettes.add(clusterSilhouette / cluster.length);
  }

  return silhouettes;
}
