import 'package:fast_equatable/fast_equatable.dart';
import 'package:nullability/nullability.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/bangs/data/models/bang_data.dart';
import 'package:weblibre/features/bangs/domain/repositories/data.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_list.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/search/domain/entities/tab_preview.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/container_filter.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_entity.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/tab_search.dart';

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

    ref.onDispose(() async {
      await subscription.cancel();
    });

    return null;
  }
}

@Riverpod()
EquatableValue<List<String>> availableTabIds(
  Ref ref,
  ContainerFilter containerFilter,
) {
  final containerTabs = ref.watch(
    containerTabIdsProvider(
      containerFilter,
    ).select((value) => value.valueOrNull),
  );
  final tabList = ref.watch(tabListProvider);

  return EquatableValue(
    containerTabs?.where((tabId) => tabList.value.contains(tabId)).toList() ??
        [],
  );
}

@Riverpod()
EquatableValue<Map<String, TabState>> availableTabStates(
  Ref ref,
  ContainerFilter containerFilter,
) {
  final availableTabs = ref.watch(availableTabIdsProvider(containerFilter));
  final tabStates = ref.watch(tabStatesProvider);

  return EquatableValue({
    for (final tabId in availableTabs.value)
      if (tabStates.containsKey(tabId)) tabId: tabStates[tabId]!,
  });
}

@Riverpod()
EquatableValue<List<TabEntity>> seamlessFilteredTabEntities(
  Ref ref, {
  required TabSearchPartition searchPartition,
  required ContainerFilter containerFilter,
  required bool groupTrees,
}) {
  final tabSearchResults = ref
      .watch(
        tabSearchRepositoryProvider(searchPartition).select(
          (value) => EquatableValue(
            value.valueOrNull.mapNotNull(
              (result) => result.results
                  .map(
                    (tab) => SearchResultTabEntity(
                      tabId: tab.id,
                      searchQuery: result.query,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      )
      .value;

  final availableTabs = ref.watch(
    availableTabIdsProvider(containerFilter).select(
      (value) => EquatableValue(
        value.value.map((tab) => DefaultTabEntity(tabId: tab)).toList(),
      ),
    ),
  );

  if (tabSearchResults == null) {
    if (groupTrees) {
      final trees = ref.watch(
        tabTreesProvider.select(
          (value) => EquatableValue(
            value.valueOrNull
                    ?.map(
                      (tree) => TabTreeEntity(
                        tabId: tree.latestTabId,
                        rootId: tree.rootTabId,
                        totalTabs: tree.totalTabs,
                      ),
                    )
                    .toList() ??
                [],
          ),
        ),
      );

      return EquatableValue(
        trees.value
            .where(
              (tree) => availableTabs.value.any(
                (available) => available.tabId == tree.tabId,
              ),
            )
            .toList(),
      );
    }

    return availableTabs;
  }

  return EquatableValue(
    tabSearchResults
        .where(
          (tab) => availableTabs.value.any(
            (available) => available.tabId == tab.tabId,
          ),
        )
        .toList(),
  );
}

@Riverpod()
EquatableValue<List<TabPreview>> seamlessFilteredTabPreviews(
  Ref ref,
  TabSearchPartition searchPartition,
  ContainerFilter containerFilter,
) {
  final tabSearchResults = ref
      .watch(
        tabSearchRepositoryProvider(
          searchPartition,
        ).select((value) => EquatableValue(value.valueOrNull)),
      )
      .value;

  final availableTabStates = ref.watch(
    availableTabStatesProvider(containerFilter),
  );

  if (tabSearchResults == null) {
    return EquatableValue(
      availableTabStates.value.values
          .map(
            (state) => TabPreview(
              id: state.id,
              title: state.title,
              icon: state.icon,
              url: state.url,
              highlightedUrl: null,
              content: null,
              sourceSearchQuery: null,
            ),
          )
          .toList(),
    );
  }

  return EquatableValue(
    tabSearchResults.results
        .where((tab) => availableTabStates.value.containsKey(tab.id))
        .map((tab) {
          return TabPreview(
            id: tab.id,
            title: tab.title ?? availableTabStates.value[tab.id]!.title,
            icon: null,
            url: tab.cleanUrl ?? availableTabStates.value[tab.id]!.url,
            highlightedUrl: tab.url,
            content: tab.extractedContent ?? tab.fullContent,
            sourceSearchQuery: tabSearchResults.query,
          );
        })
        .whereType<TabPreview>()
        .toList(),
  );
}
