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
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/gecko_inference.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab.dart';

part 'container_topic.g.dart';

@Riverpod()
class ContainerTopicController extends _$ContainerTopicController {
  Future<String?> predictDocumentTopic(String containerId) async {
    final tabData = await ref
        .read(tabDataRepositoryProvider.notifier)
        .getContainerTabsData(containerId);

    if (tabData.isEmpty) return null;

    final titles = tabData.map((t) => t.title).nonNulls.toSet();
    return _predictFromTitles(titles);
  }

  Future<String?> predictTopicFromTabIds(Set<String> tabIds) async {
    final tabStates = ref.read(tabStatesProvider);
    final titles = tabIds
        .map((tabId) => tabStates[tabId]?.title)
        .nonNulls
        .toSet();

    return _predictFromTitles(titles);
  }

  Future<String?> _predictFromTitles(Set<String> titles) async {
    if (titles.isEmpty) return null;

    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      final topicResult = await ref
          .read(geckoInferenceRepositoryProvider.notifier)
          .predictDocumentTopic(titles);

      return topicResult.fold((topic) => topic, onFailure: (_) => null);
    });

    if (ref.mounted) {
      state = result;
    }

    return result.value;
  }

  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }
}
