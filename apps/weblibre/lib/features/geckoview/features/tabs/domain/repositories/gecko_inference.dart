/*
 * Copyright (c) 2024-2026 Fabian Freund.
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
import 'dart:isolate';

import 'package:collection/collection.dart';
import 'package:exceptions/exceptions.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_mozilla_components/ml_utils.dart';
import 'package:nullability/nullability.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:synchronized/synchronized.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
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

  /// Embeddings by document. Sized well past the open tab count: clustering
  /// embeds every unassigned tab on each run, and once those outnumbered the
  /// capacity, each run re-embedded everything that did not fit. An entry is a
  /// few KB.
  final _embeddingCache = LRUCache<String, List<double>>(1000);

  void markInitialLoadComplete() {
    if (!_initialLoadComplete.isCompleted) {
      _initialLoadComplete.complete();
    }
  }

  Future<Result<String?>> predictDocumentTopic(Set<String> titles) async {
    if (!ref.read(
      generalSettingsWithDefaultsProvider.select(
        (settings) => settings.enableLocalAiFeatures,
      ),
    )) {
      return Result.success(null);
    }

    if (titles.isNotEmpty) {
      if (_topicCache.get(titles) case final String title) {
        return Result.success(title);
      }

      try {
        final title = await _engineLock.synchronized(() async {
          await _initialLoadComplete.future;

          final title = await Result.fromAsync(
            () async => await _service.predictDocumentTopic(titles),
          );
          title.onSuccess((title) => _topicCache.set(titles, title));

          return title;
        }, timeout: const Duration(seconds: 120));

        return title;
      } on TimeoutException {
        return Result.failure(
          const ErrorMessage(
            source: 'Document Title Prediction',
            message: 'Timeout',
          ),
        );
      }
    }

    return Result.success(null);
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

    return embeddings.fold<List<String>?>(
      (embeddings) {
        final neighbors = embeddings.mapNotNull(
          (embeddings) =>
              findNearestNeighborsRecursive(
                    embeddings: embeddings,
                    assignedDocuments: assignedDocumentsProcessed,
                    unassignedDocuments: unassignedDocumentsProcessed,
                  )
                  .map((neighbor) => processedDocuments[neighbor] ?? neighbor)
                  .toList(),
        );

        return neighbors;
      },
      onFailure: (errorMessage) {
        logger.e(
          errorMessage.message,
          error: errorMessage.details,
          stackTrace: errorMessage.stackTrace,
        );
        return null;
      },
    );
  }

  /// Groups [unassignedDocumentsInput] (titles by tab id) into suggested
  /// containers.
  ///
  /// Stops, returning `null`, once [cancelled] completes — a newer run has
  /// replaced this one, and the clustering and the topic of each cluster are
  /// work nobody would see. A clustering under way is killed on the spot.
  Future<List<SuggestedContainer>?> suggestClusters({
    required Map<String, String> unassignedDocumentsInput,
    Future<void>? cancelled,
  }) async {
    var superseded = false;
    unawaited(cancelled?.then((_) => superseded = true));

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

    return await embeddings.fold(
      (embeddings) async {
        if (embeddings == null || superseded) {
          return null;
        }

        final indexClusters = await clusterInBackground(
          embeddings.values.toList(),
          cancelled: cancelled,
        );
        if (indexClusters == null || superseded) {
          return null;
        }

        final titles = embeddings.keys.toList();
        final clusters = indexClusters
            .map((cluster) => cluster.map((i) => titles[i]).toList())
            .toList();

        final idsByTitle = <String, List<String>>{};
        for (final MapEntry(:key, :value) in unassignedDocumentsInput.entries) {
          (idsByTitle[value] ??= []).add(key);
        }

        final clusterResult = await Future.wait(
          clusters.map((clusterTitles) async {
            final originalTitles = clusterTitles
                .map((title) => processedDocuments[title] ?? title)
                .toSet();

            final topic = await predictDocumentTopic(originalTitles);

            return (
              topic: topic.fold(
                (topic) => topic,
                onFailure: (errorMessage) {
                  logger.e(
                    errorMessage.message,
                    error: errorMessage.details,
                    stackTrace: errorMessage.stackTrace,
                  );
                  return null;
                },
              ),
              tabIds: originalTitles
                  .expand((title) => idsByTitle[title] ?? const <String>[])
                  .toList(),
            );
          }),
        );

        return clusterResult;
      },
      onFailure: (errorMessage) {
        logger.e(
          errorMessage.message,
          error: errorMessage.details,
          stackTrace: errorMessage.stackTrace,
        );
        return null;
      },
    );
  }

  Future<Result<Map<String, List<double>>?>> generateDocumentEmbeddings(
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

          final embeddings = await Result.fromAsync(
            () async =>
                await _service.generateDocumentEmbeddings(embeddingsToGenerate),
          );

          return embeddings;
        }, timeout: const Duration(seconds: 120));

        if (!generatedEmbeddings.isSuccess) {
          return Result.failure(generatedEmbeddings.error!);
        }

        final generated = generatedEmbeddings.value;
        if (generated.length != embeddingsToGenerate.length) {
          return Result.failure(
            ErrorMessage(
              source: 'Document Embeddings',
              message: 'Unexpected embedding count',
              details: {
                'expected': embeddingsToGenerate.length,
                'actual': generated.length,
              },
            ),
          );
        }

        for (var i = 0; i < embeddingsToGenerate.length; i++) {
          final embedding = generated[i];
          final document = embeddingsToGenerate[i];
          embeddings[document] = embedding;
          _embeddingCache.set(document, embedding);
        }
      }

      return Result.success({
        for (final MapEntry(:key, :value) in embeddings.entries) key: ?value,
      });
    } on TimeoutException {
      return Result.failure(
        const ErrorMessage(source: 'Document Embeddings', message: 'Timeout'),
      );
    } catch (e, s) {
      return Result.failure(
        ErrorMessage(
          source: 'Document Embeddings',
          message: e.toString(),
          details: e,
          stackTrace: s,
        ),
      );
    }
  }

  @override
  void build() {}
}

@Riverpod()
Future<String?> containerTopic(Ref ref, String containerId) async {
  final titles = await ref.watch(
    watchContainerTabsDataProvider(containerId).selectAsync(
      (tabData) =>
          EquatableValue(tabData.map((tab) => tab.title).nonNulls.toSet()),
    ),
  );

  if (!ref.mounted) return null;

  final topic = await ref.watch(topicSuggestionProvider(titles).future);

  if (ref.mounted && topic.isNotEmpty) {
    ref.keepAlive();
  }

  return topic;
}

@Riverpod()
AsyncValue<String?> tabsTopic(Ref ref, EquatableValue<Set<String>> tabIds) {
  final tabTitles = ref.watch(
    tabStatesProvider.select((states) {
      return EquatableValue(
        tabIds.value.map((tabId) => states[tabId]?.title).nonNulls.toSet(),
      );
    }),
  );

  return ref.watch(topicSuggestionProvider(tabTitles));
}

@Riverpod()
Future<String?> topicSuggestion(
  Ref ref,
  EquatableValue<Set<String>> titles,
) async {
  final topic = await ref
      .read(geckoInferenceRepositoryProvider.notifier)
      .predictDocumentTopic(titles.value);

  return topic.fold<String?>(
    (topic) {
      if (ref.mounted && topic.isNotEmpty) {
        ref.keepAlive();
      }

      return topic;
    },
    onFailure: (errorMessage) {
      logger.e(
        errorMessage.message,
        error: errorMessage.details,
        stackTrace: errorMessage.stackTrace,
      );
      return null;
    },
  );
}

/// Runs [clusterEmbeddings] on another isolate: it tries a range of cluster
/// counts, several times each, with pairwise distances between every two
/// tabs, which takes long enough to freeze the UI with a few hundred tabs.
///
/// Completes with `null` instead when [cancelled] completes first, killing the
/// isolate there and then. Left to finish, a clustering nobody will see keeps
/// a core busy and a copy of every embedding alive, and the run that replaced
/// it starts another next to it.
@visibleForTesting
Future<List<List<int>>?> clusterInBackground(
  List<List<double>> embeddings, {
  Future<void>? cancelled,
}) async {
  final result = Completer<List<List<int>>?>();
  // The first message decides: the clusters, an error, or — killed — the
  // bare exit notice.
  final port = RawReceivePort();
  port.handler = (Object? message) {
    port.close();
    switch (message) {
      case (clusters: final List<List<int>> clusters):
        result.complete(clusters);
      case [final Object? error, final Object? stackTrace]:
        result.completeError(RemoteError('$error', '$stackTrace'));
      default:
        result.complete(null);
    }
  };

  final Isolate isolate;
  try {
    isolate = await Isolate.spawn(
      _clusterIsolateMain,
      (port.sendPort, embeddings),
      onExit: port.sendPort,
      onError: port.sendPort,
    );
  } catch (_) {
    port.close();
    rethrow;
  }

  unawaited(
    cancelled?.then((_) {
      if (!result.isCompleted) {
        isolate.kill(priority: Isolate.immediate);
      }
    }),
  );

  return await result.future;
}

void _clusterIsolateMain((SendPort, List<List<double>>) message) {
  final (port, embeddings) = message;
  Isolate.exit(port, (clusters: clusterEmbeddings(embeddings: embeddings)));
}

@Riverpod()
Future<List<SuggestedContainer>?> suggestClusters(Ref ref) async {
  final unassignedTitles = await ref.watch(
    watchContainerTabsDataProvider(null).selectAsync(
      (tabData) => EquatableValue(
        Map.fromEntries(
          tabData
              .where((tab) => tab.title.isNotEmpty)
              .map((tab) => MapEntry(tab.id, tab.title!)),
        ),
      ),
    ),
  );

  // Titles change in bursts while pages load, and each change rebuilds this
  // provider: wait for them to settle rather than embed and cluster for every
  // one of them.
  await Future<void>.delayed(const Duration(milliseconds: 500));

  if (ref.mounted && unassignedTitles.value.isNotEmpty) {
    // A rebuild disposes this run before the next one starts, so cancelling
    // on disposal keeps one clustering going at most.
    final disposed = Completer<void>();
    ref.onDispose(disposed.complete);

    return await ref
        .read(geckoInferenceRepositoryProvider.notifier)
        .suggestClusters(
          unassignedDocumentsInput: unassignedTitles.value,
          cancelled: disposed.future,
        );
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

  final container = await ref.watch(
    watchContainerDataProvider(containerId).future,
  );

  if (!ref.mounted) return null;

  final assignedTitles = await ref.watch(
    watchContainerTabsDataProvider(containerId).selectAsync(
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
    watchContainerTabsDataProvider(null).selectAsync(
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
            )
            .then(
              (result) => result.fold(
                (value) => value,
                onFailure: (errorMessage) {
                  logger.e(
                    errorMessage.message,
                    error: errorMessage.details,
                    stackTrace: errorMessage.stackTrace,
                  );
                  return null;
                },
              ),
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

      final idsByTitle = <String, List<String>>{};
      for (final (id, title) in unassignedTitles.value) {
        (idsByTitle[title] ??= []).add(id);
      }

      return suggestedTitles.mapNotNull((titles) {
        final tabIds = titles
            .expand((title) => idsByTitle[title] ?? const <String>[])
            .toList();

        return tabIds.isEmpty ? null : tabIds;
      });
    }
  }

  return null;
}
