/*
 * Copyright (c) 2024-2025 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'dart:async';

import 'package:collection/collection.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_mozilla_components/ml_utils.dart';
import 'package:nullability/nullability.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:synchronized/synchronized.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/utils/lru_cache.dart';

part 'gecko_inference.g.dart';

typedef SuggestedContainer = ({List<String> tabIds, String? topic});

@Riverpod(keepAlive: true)
class GeckoInferenceRepository extends _$GeckoInferenceRepository {
  final _service = GeckoMlService();

  //Wait for first complete page laod of any website after startup to ensure everything is ready
  final _initialLoadComplete = Completer();
  final _engineLock = Lock();

  final _topicCache = LRUCache<Set<String>, String>(
    50,
    equals: (a, b) {
      return const DeepCollectionEquality.unordered().equals(a, b);
    },
    hashCode: (key) {
      return const DeepCollectionEquality.unordered().hash(key);
    },
  );

  final _embeddingCache = LRUCache<String, List<double>>(100);

  void markInitialLoadComplete() {
    if (!_initialLoadComplete.isCompleted) {
      _initialLoadComplete.complete();
    }
  }

  Future<String?> predictDocumentTopic(Set<String> titles) async {
    if (!ref.read(
      generalSettingsWithDefaultsProvider.select(
        (settings) => settings.enableLocalAiFeatures,
      ),
    )) {
      return null;
    }

    if (titles.isNotEmpty) {
      if (_topicCache.get(titles) case final String title) {
        return title;
      }

      try {
        final title = await _engineLock.synchronized(() async {
          await _initialLoadComplete.future;

          final title = await _service.predictDocumentTopic(titles);

          return _topicCache.set(titles, title);
        }, timeout: const Duration(seconds: 120));

        return title;
      } on TimeoutException {
        return null;
      }
    }

    return null;
  }

  Future<List<String>?> suggestDocuments({
    required String topic,
    required List<String> assignedDocumentsInput,
    required List<String> unassignedDocumentsInput,
  }) async {
    if (!ref.read(
      generalSettingsWithDefaultsProvider.select(
        (settings) => settings.enableLocalAiFeatures,
      ),
    )) {
      return null;
    }

    final processedDocuments = <String, String>{};
    final unassignedDocumentsProcessed = unassignedDocumentsInput.map((doc) {
      final processed = preprocessText(doc);
      if (processed != doc) {
        processedDocuments[processed] = doc;
      }

      return processed;
    }).toList();

    final assignedDocumentsProcessed = assignedDocumentsInput
        .map((doc) => '$topic. ${preprocessText(doc)}')
        .toList();

    final embeddings = await generateDocumentEmbeddings([
      ...unassignedDocumentsProcessed,
      ...assignedDocumentsProcessed,
    ]);

    final neighbors = embeddings.mapNotNull(
      (embeddings) => findNearestNeighborsRecursive(
        embeddings: embeddings,
        assignedDocuments: assignedDocumentsProcessed,
        unassignedDocuments: unassignedDocumentsProcessed,
      ).map((neighbor) => processedDocuments[neighbor] ?? neighbor).toList(),
    );

    return neighbors;
  }

  Future<List<SuggestedContainer>?> suggestClusters({
    required Map<String, String> unassignedDocumentsInput,
  }) async {
    if (!ref.read(
      generalSettingsWithDefaultsProvider.select(
        (settings) => settings.enableLocalAiFeatures,
      ),
    )) {
      return null;
    }

    final processedDocuments = <String, String>{};
    final unassignedDocumentsProcessed = unassignedDocumentsInput.values.map((
      doc,
    ) {
      final processed = preprocessText(doc);
      if (processed != doc) {
        processedDocuments[processed] = doc;
      }

      return processed;
    }).toList();

    final embeddings = await generateDocumentEmbeddings(
      unassignedDocumentsProcessed,
    );

    final clusters = embeddings.mapNotNull(
      (embeddings) => clusterEmbeddings(embeddings: embeddings.values.toList())
          .map(
            (cluster) =>
                cluster.map((i) => embeddings.keys.elementAt(i)).toList(),
          )
          .toList(),
    );

    final clusterResult = await clusters.mapNotNull(
      (cluster) => Future.wait(
        cluster.map((clusterTitles) async {
          final originalTitles = clusterTitles
              .map((title) => processedDocuments[title] ?? title)
              .toSet();

          final topic = await predictDocumentTopic(originalTitles);

          return (
            topic: topic,
            tabIds: originalTitles
                .map(
                  (title) => unassignedDocumentsInput.entries
                      .firstWhere((entry) => entry.value == title)
                      .key,
                )
                .toList(),
          );
        }),
      ),
    );

    return clusterResult;
  }

  Future<Map<String, List<double>>?> generateDocumentEmbeddings(
    List<String> documents,
  ) async {
    try {
      final embeddings = Map.fromEntries(
        documents.map((doc) => MapEntry(doc, _embeddingCache.get(doc))),
      );

      final embeddingsToGenerate = embeddings.entries
          .where((e) => e.value == null)
          .map((e) => e.key)
          .toList();

      if (embeddingsToGenerate.isNotEmpty) {
        final generatedEmbeddings = await _engineLock.synchronized(() async {
          await _initialLoadComplete.future;

          final embeddings = await _service.generateDocumentEmbeddings(
            documents,
          );

          return embeddings;
        }, timeout: const Duration(seconds: 120));

        for (var i = 0; i < embeddingsToGenerate.length; i++) {
          embeddings[embeddingsToGenerate[i]] = generatedEmbeddings[i];
        }
      }

      return {
        for (final MapEntry(:key, :value) in embeddings.entries)
          if (value != null) key: value,
      };
    } on TimeoutException {
      return null;
    }
  }

  @override
  void build() {}
}

@Riverpod()
Future<String?> containerTopic(Ref ref, String containerId) async {
  final titles = await ref.watch(
    containerTabsDataProvider(containerId).selectAsync(
      (tabData) =>
          EquatableValue(tabData.map((tab) => tab.title).nonNulls.toSet()),
    ),
  );

  if (!ref.mounted) return null;

  final topic = await ref
      .read(geckoInferenceRepositoryProvider.notifier)
      .predictDocumentTopic(titles.value);

  if (ref.mounted && topic.isNotEmpty) {
    ref.keepAlive();
  }

  return topic;
}

@Riverpod()
Future<List<SuggestedContainer>?> suggestClusters(Ref ref) async {
  final unassignedTitles = await ref.watch(
    containerTabsDataProvider(null).selectAsync(
      (tabData) => EquatableValue(
        Map.fromEntries(
          tabData
              .where((tab) => tab.title.isNotEmpty)
              .map((tab) => MapEntry(tab.id, tab.title!)),
        ),
      ),
    ),
  );

  if (ref.mounted && unassignedTitles.value.isNotEmpty) {
    return await ref
        .read(geckoInferenceRepositoryProvider.notifier)
        .suggestClusters(unassignedDocumentsInput: unassignedTitles.value);
  }

  return null;
}

@Riverpod()
Future<List<String>?> containerTabSuggestions(
  Ref ref,
  String? containerId,
) async {
  if (containerId == null) {
    return null;
  }

  final container = await ref.watch(containerDataProvider(containerId).future);

  if (!ref.mounted) return null;

  final assignedTitles = await ref.watch(
    containerTabsDataProvider(containerId).selectAsync(
      (tabData) => EquatableValue(
        tabData
            .where((tab) => tab.title.isNotEmpty)
            .map((tab) => (tab.id, tab.title!))
            .toSet(),
      ),
    ),
  );

  if (!ref.mounted) return null;

  final unassignedTitles = await ref.watch(
    containerTabsDataProvider(null).selectAsync(
      (tabData) => EquatableValue(
        tabData
            .where((tab) => tab.title.isNotEmpty)
            .map((tab) => (tab.id, tab.title!))
            .toSet(),
      ),
    ),
  );

  if (ref.mounted &&
      assignedTitles.value.isNotEmpty &&
      unassignedTitles.value.isNotEmpty) {
    final topic =
        container?.name ??
        await ref
            .read(geckoInferenceRepositoryProvider.notifier)
            .predictDocumentTopic(
              assignedTitles.value.map((tab) => tab.$2).toSet(),
            );

    if (ref.mounted && topic != null) {
      final suggestedTitles = await ref
          .read(geckoInferenceRepositoryProvider.notifier)
          .suggestDocuments(
            topic: topic,
            assignedDocumentsInput: assignedTitles.value
                .map((tab) => tab.$2)
                .toList(),
            unassignedDocumentsInput: unassignedTitles.value
                .map((tab) => tab.$2)
                .toList(),
          );

      return suggestedTitles.mapNotNull(
        (titles) => titles
            .map(
              (title) => unassignedTitles.value
                  .firstWhere((tab) => tab.$2 == title)
                  .$1,
            )
            .toList(),
      );
    }
  }

  return null;
}
