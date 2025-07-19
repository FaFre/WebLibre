import 'dart:async';

import 'package:collection/collection.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:synchronized/synchronized.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/utils/lru_cache.dart';

part 'container_topic.g.dart';

@Riverpod(keepAlive: true)
class ContainerTopicRepository extends _$ContainerTopicRepository {
  final _service = GeckoMlService();

  final _lock = Lock();

  final _cache = LRUCache<Set<String>, String>(
    50,
    equals: (a, b) {
      return const DeepCollectionEquality.unordered().equals(a, b);
    },
    hashCode: (key) {
      return const DeepCollectionEquality.unordered().hash(key);
    },
  );

  Future<String?> getContainerTopic(Set<String> titles) async {
    if (titles.isNotEmpty) {
      if (_cache.get(titles) case final String title) {
        return title;
      }

      try {
        final title = await _lock.synchronized(() async {
          final title = await _service.getContainerTopic(titles);

          return _cache.set(titles, title);
        }, timeout: const Duration(seconds: 120));

        return title;
      } on TimeoutException {
        return null;
      }
    }

    return null;
  }

  @override
  void build() {}
}

@Riverpod(keepAlive: true)
Future<String?> containerTopic(Ref ref, String containerId) async {
  final titles = await ref.watch(
    containerTabsDataProvider(containerId).selectAsync(
      (tabData) =>
          EquatableValue(tabData.map((tab) => tab.title).nonNulls.toSet()),
    ),
  );

  final topic = await ref
      .read(containerTopicRepositoryProvider.notifier)
      .getContainerTopic(titles.value);

  return topic;
}
