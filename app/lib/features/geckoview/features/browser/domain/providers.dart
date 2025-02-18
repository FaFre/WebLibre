import 'dart:async';

import 'package:lensai/data/models/equatable_iterable.dart';
import 'package:lensai/extensions/nullable.dart';
import 'package:lensai/features/bangs/data/models/bang_data.dart';
import 'package:lensai/features/bangs/domain/repositories/data.dart';
import 'package:lensai/features/geckoview/domain/entities/tab_state.dart';
import 'package:lensai/features/geckoview/domain/providers/tab_list.dart';
import 'package:lensai/features/geckoview/domain/providers/tab_state.dart';
import 'package:lensai/features/geckoview/features/search/domain/entities/tab_preview.dart';
import 'package:lensai/features/geckoview/features/tabs/data/entities/container_filter.dart';
import 'package:lensai/features/geckoview/features/tabs/domain/providers.dart';
import 'package:lensai/features/geckoview/features/tabs/domain/repositories/tab_search.dart';
import 'package:lensai/features/kagi/data/entities/modes.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
class SelectedBangTrigger extends _$SelectedBangTrigger {
  // ignore: document_ignores api decision
  // ignore: use_setters_to_change_properties
  void setTrigger(String trigger) {
    state = trigger;
  }

  void clearTrigger() {
    state = null;
  }

  @override
  String? build({String? domain}) {
    return null;
  }
}

@Riverpod()
class SelectedBangData extends _$SelectedBangData {
  @override
  BangData? build({String? domain}) {
    final repository = ref.watch(bangDataRepositoryProvider.notifier);
    final selectedBangTrigger = ref.watch(
      selectedBangTriggerProvider(domain: domain),
    );

    final subscription = repository.watchBang(selectedBangTrigger).listen((
      value,
    ) {
      state = value;
    });

    ref.onDispose(() {
      unawaited(subscription.cancel());
    });

    return null;
  }
}

@Riverpod(keepAlive: true)
class LastUsedAssistantMode extends _$LastUsedAssistantMode {
  // ignore: document_ignores api decision
  // ignore: use_setters_to_change_properties
  void update(AssistantMode mode) {
    state = mode;
  }

  @override
  AssistantMode build() {
    return AssistantMode.research;
  }
}

@Riverpod(keepAlive: true)
class ActiveResearchVariant extends _$ActiveResearchVariant {
  // ignore: document_ignores api decision
  // ignore: use_setters_to_change_properties
  void update(ResearchVariant mode) {
    state = mode;
  }

  @override
  ResearchVariant build() {
    return ResearchVariant.expert;
  }
}

@Riverpod(keepAlive: true)
class ActiveChatModel extends _$ActiveChatModel {
  // ignore: document_ignores api decision
  // ignore: use_setters_to_change_properties
  void update(ChatModel model) {
    state = model;
  }

  @override
  ChatModel build() {
    return ChatModel.gpt4o;
  }
}

@Riverpod(keepAlive: true)
class ShowFindInPage extends _$ShowFindInPage {
  // ignore: document_ignores api decision
  // ignore: use_setters_to_change_properties
  void update(bool show) {
    state = show;
  }

  @override
  bool build() {
    return false;
  }
}

@Riverpod()
EquatableCollection<List<String>> availableTabIds(
  Ref ref,
  ContainerFilter containerFilter,
) {
  final containerTabs = ref.watch(
    containerTabIdsProvider(
      containerFilter,
    ).select((value) => value.valueOrNull),
  );
  final tabList = ref.watch(tabListProvider);

  return EquatableCollection(
    containerTabs?.where((tabId) => tabList.contains(tabId)).toList() ?? [],
    immutable: true,
  );
}

@Riverpod()
EquatableCollection<Map<String, TabState>> availableTabStates(
  Ref ref,
  ContainerFilter containerFilter,
) {
  final availableTabs = ref.watch(availableTabIdsProvider(containerFilter));
  final tabStates = ref.watch(tabStatesProvider);

  return EquatableCollection({
    for (final tabId in availableTabs.collection)
      if (tabStates.containsKey(tabId)) tabId: tabStates[tabId]!,
  }, immutable: true);
}

@Riverpod()
EquatableCollection<List<String>> seamlessFilteredTabIds(
  Ref ref,
  TabSearchPartition searchPartition,
  ContainerFilter containerFilter,
) {
  final tabSearchResults =
      ref
          .watch(
            tabSearchRepositoryProvider(searchPartition).select(
              (value) => EquatableCollection(
                value.valueOrNull?.map((tab) => tab.id).toList(),
                immutable: true,
              ),
            ),
          )
          .collection;

  final availableTabs = ref.watch(availableTabIdsProvider(containerFilter));

  if (tabSearchResults == null) {
    return availableTabs;
  }

  return EquatableCollection(
    tabSearchResults
        .where((tab) => availableTabs.collection.contains(tab))
        .toList(),
    immutable: true,
  );
}

@Riverpod()
EquatableCollection<List<TabPreview>> seamlessFilteredTabPreviews(
  Ref ref,
  TabSearchPartition searchPartition,
  ContainerFilter containerFilter,
) {
  final tabSearchResults =
      ref
          .watch(
            tabSearchRepositoryProvider(searchPartition).select(
              (value) =>
                  EquatableCollection(value.valueOrNull, immutable: true),
            ),
          )
          .collection;

  final availableTabStates = ref.watch(
    availableTabStatesProvider(containerFilter),
  );

  if (tabSearchResults == null) {
    return EquatableCollection(
      availableTabStates.collection.values
          .map(
            (state) => TabPreview(
              id: state.id,
              title: state.title,
              icon: state.icon,
              url: state.url,
              highlightedUrl: null,
              content: null,
            ),
          )
          .toList(),
      immutable: true,
    );
  }

  return EquatableCollection(
    tabSearchResults
        .where((tab) => availableTabStates.collection.containsKey(tab.id))
        .map((tab) {
          return TabPreview(
            id: tab.id,
            title: tab.title ?? availableTabStates.collection[tab.id]!.title,
            icon: null,
            url:
                tab.cleanUrl.mapNotNull(Uri.tryParse) ??
                availableTabStates.collection[tab.id]!.url,
            highlightedUrl: tab.url,
            content: tab.extractedContent ?? tab.fullContent,
          );
        })
        .whereType<TabPreview>()
        .toList(),
    immutable: true,
  );
}
