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
  SearchModuleType.actions: 'actions',
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

String _$searchModuleOrderHash() => r'ed939be978818e7525819c22cc07b67b468c15ba';

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

/// The layout of [surface] as the screens that arrange it show and change
/// it: in the onboarding the draft's (what the commit would write), otherwise
/// the profile's ([SearchModuleOrder]).
///
/// The edit layer. A change goes into the draft while one is open, and into
/// [SearchModuleOrder] otherwise. [SearchModuleOrder] never sees the draft:
/// its `persist()` stores whatever it holds.

@ProviderFor(EditedModuleOrder)
final editedModuleOrderProvider = EditedModuleOrderFamily._();

/// The layout of [surface] as the screens that arrange it show and change
/// it: in the onboarding the draft's (what the commit would write), otherwise
/// the profile's ([SearchModuleOrder]).
///
/// The edit layer. A change goes into the draft while one is open, and into
/// [SearchModuleOrder] otherwise. [SearchModuleOrder] never sees the draft:
/// its `persist()` stores whatever it holds.
final class EditedModuleOrderProvider
    extends $NotifierProvider<EditedModuleOrder, List<ModuleOrderEntry>> {
  /// The layout of [surface] as the screens that arrange it show and change
  /// it: in the onboarding the draft's (what the commit would write), otherwise
  /// the profile's ([SearchModuleOrder]).
  ///
  /// The edit layer. A change goes into the draft while one is open, and into
  /// [SearchModuleOrder] otherwise. [SearchModuleOrder] never sees the draft:
  /// its `persist()` stores whatever it holds.
  EditedModuleOrderProvider._({
    required EditedModuleOrderFamily super.from,
    required ModuleSurface super.argument,
  }) : super(
         retry: null,
         name: r'editedModuleOrderProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$editedModuleOrderHash();

  @override
  String toString() {
    return r'editedModuleOrderProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EditedModuleOrder create() => EditedModuleOrder();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ModuleOrderEntry> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ModuleOrderEntry>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EditedModuleOrderProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$editedModuleOrderHash() => r'6f4171d01b536497c2d1bb17825e517f7a8b0d8b';

/// The layout of [surface] as the screens that arrange it show and change
/// it: in the onboarding the draft's (what the commit would write), otherwise
/// the profile's ([SearchModuleOrder]).
///
/// The edit layer. A change goes into the draft while one is open, and into
/// [SearchModuleOrder] otherwise. [SearchModuleOrder] never sees the draft:
/// its `persist()` stores whatever it holds.

final class EditedModuleOrderFamily extends $Family
    with
        $ClassFamilyOverride<
          EditedModuleOrder,
          List<ModuleOrderEntry>,
          List<ModuleOrderEntry>,
          List<ModuleOrderEntry>,
          ModuleSurface
        > {
  EditedModuleOrderFamily._()
    : super(
        retry: null,
        name: r'editedModuleOrderProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The layout of [surface] as the screens that arrange it show and change
  /// it: in the onboarding the draft's (what the commit would write), otherwise
  /// the profile's ([SearchModuleOrder]).
  ///
  /// The edit layer. A change goes into the draft while one is open, and into
  /// [SearchModuleOrder] otherwise. [SearchModuleOrder] never sees the draft:
  /// its `persist()` stores whatever it holds.

  EditedModuleOrderProvider call(ModuleSurface surface) =>
      EditedModuleOrderProvider._(argument: surface, from: this);

  @override
  String toString() => r'editedModuleOrderProvider';
}

/// The layout of [surface] as the screens that arrange it show and change
/// it: in the onboarding the draft's (what the commit would write), otherwise
/// the profile's ([SearchModuleOrder]).
///
/// The edit layer. A change goes into the draft while one is open, and into
/// [SearchModuleOrder] otherwise. [SearchModuleOrder] never sees the draft:
/// its `persist()` stores whatever it holds.

abstract class _$EditedModuleOrder extends $Notifier<List<ModuleOrderEntry>> {
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
