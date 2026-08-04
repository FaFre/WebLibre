// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_module_order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ModuleOrderEntry _$ModuleOrderEntryFromJson(Map<String, dynamic> json) =>
    ModuleOrderEntry(
      type: $enumDecode(_$SearchModuleTypeEnumMap, json['type']),
      visible: json['visible'] as bool,
    );

Map<String, dynamic> _$ModuleOrderEntryToJson(ModuleOrderEntry instance) =>
    <String, dynamic>{
      'type': _$SearchModuleTypeEnumMap[instance.type]!,
      'visible': instance.visible,
    };

const _$SearchModuleTypeEnumMap = {
  SearchModuleType.recentSearches: 'recentSearches',
  SearchModuleType.searchProviders: 'searchProviders',
  SearchModuleType.searchSuggestions: 'searchSuggestions',
  SearchModuleType.tabs: 'tabs',
  SearchModuleType.articles: 'articles',
  SearchModuleType.bookmarks: 'bookmarks',
  SearchModuleType.history: 'history',
  SearchModuleType.localHistory: 'localHistory',
  SearchModuleType.combinedHistory: 'combinedHistory',
  SearchModuleType.popularSites: 'popularSites',
  SearchModuleType.historyHighlights: 'historyHighlights',
  SearchModuleType.topSites: 'topSites',
  SearchModuleType.recentHistory: 'recentHistory',
  SearchModuleType.recentArticles: 'recentArticles',
  SearchModuleType.recentTabs: 'recentTabs',
  SearchModuleType.containers: 'containers',
  SearchModuleType.frequentBangs: 'frequentBangs',
  SearchModuleType.quote: 'quote',
  SearchModuleType.quickActions: 'quickActions',
};

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SearchModuleOrder)
final searchModuleOrderProvider = SearchModuleOrderFamily._();

final class SearchModuleOrderProvider
    extends $NotifierProvider<SearchModuleOrder, List<ModuleOrderEntry>> {
  SearchModuleOrderProvider._({
    required SearchModuleOrderFamily super.from,
    required ModuleSurface super.argument,
  }) : super(
         retry: null,
         name: r'searchModuleOrderProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchModuleOrderHash();

  @override
  String toString() {
    return r'searchModuleOrderProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SearchModuleOrder create() => SearchModuleOrder();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ModuleOrderEntry> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ModuleOrderEntry>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SearchModuleOrderProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchModuleOrderHash() => r'ef43bc259db7a07ca1accab9d7ae803c376e76b4';

final class SearchModuleOrderFamily extends $Family
    with
        $ClassFamilyOverride<
          SearchModuleOrder,
          List<ModuleOrderEntry>,
          List<ModuleOrderEntry>,
          List<ModuleOrderEntry>,
          ModuleSurface
        > {
  SearchModuleOrderFamily._()
    : super(
        retry: null,
        name: r'searchModuleOrderProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  SearchModuleOrderProvider call(ModuleSurface surface) =>
      SearchModuleOrderProvider._(argument: surface, from: this);

  @override
  String toString() => r'searchModuleOrderProvider';
}

abstract class _$SearchModuleOrder extends $Notifier<List<ModuleOrderEntry>> {
  late final _$args = ref.$arg as ModuleSurface;
  ModuleSurface get surface => _$args;

  List<ModuleOrderEntry> build(ModuleSurface surface);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<List<ModuleOrderEntry>, List<ModuleOrderEntry>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<ModuleOrderEntry>, List<ModuleOrderEntry>>,
              List<ModuleOrderEntry>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
