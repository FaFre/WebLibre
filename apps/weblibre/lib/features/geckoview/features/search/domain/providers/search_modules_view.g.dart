// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_modules_view.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SearchModuleDisplayStateController)
final searchModuleDisplayStateControllerProvider =
    SearchModuleDisplayStateControllerFamily._();

final class SearchModuleDisplayStateControllerProvider
    extends
        $NotifierProvider<
          SearchModuleDisplayStateController,
          SearchModuleDisplayState
        > {
  SearchModuleDisplayStateControllerProvider._({
    required SearchModuleDisplayStateControllerFamily super.from,
    required (ModuleSurface, SearchModuleType) super.argument,
  }) : super(
         retry: null,
         name: r'searchModuleDisplayStateControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$searchModuleDisplayStateControllerHash();

  @override
  String toString() {
    return r'searchModuleDisplayStateControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  SearchModuleDisplayStateController create() =>
      SearchModuleDisplayStateController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchModuleDisplayState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchModuleDisplayState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SearchModuleDisplayStateControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchModuleDisplayStateControllerHash() =>
    r'6e17f17c4dee1ad560560b81e9c4c9cade8aeec4';

final class SearchModuleDisplayStateControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          SearchModuleDisplayStateController,
          SearchModuleDisplayState,
          SearchModuleDisplayState,
          SearchModuleDisplayState,
          (ModuleSurface, SearchModuleType)
        > {
  SearchModuleDisplayStateControllerFamily._()
    : super(
        retry: null,
        name: r'searchModuleDisplayStateControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SearchModuleDisplayStateControllerProvider call(
    ModuleSurface surface,
    SearchModuleType module,
  ) => SearchModuleDisplayStateControllerProvider._(
    argument: (surface, module),
    from: this,
  );

  @override
  String toString() => r'searchModuleDisplayStateControllerProvider';
}

abstract class _$SearchModuleDisplayStateController
    extends $Notifier<SearchModuleDisplayState> {
  late final _$args = ref.$arg as (ModuleSurface, SearchModuleType);
  ModuleSurface get surface => _$args.$1;
  SearchModuleType get module => _$args.$2;

  SearchModuleDisplayState build(
    ModuleSurface surface,
    SearchModuleType module,
  );
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<SearchModuleDisplayState, SearchModuleDisplayState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SearchModuleDisplayState, SearchModuleDisplayState>,
              SearchModuleDisplayState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}

@ProviderFor(SearchReorderMode)
final searchReorderModeProvider = SearchReorderModeFamily._();

final class SearchReorderModeProvider
    extends $NotifierProvider<SearchReorderMode, bool> {
  SearchReorderModeProvider._({
    required SearchReorderModeFamily super.from,
    required ModuleSurface super.argument,
  }) : super(
         retry: null,
         name: r'searchReorderModeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchReorderModeHash();

  @override
  String toString() {
    return r'searchReorderModeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SearchReorderMode create() => SearchReorderMode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SearchReorderModeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchReorderModeHash() => r'2fda7e61b9c67e04e39254733e0ba957ff5de35a';

final class SearchReorderModeFamily extends $Family
    with
        $ClassFamilyOverride<
          SearchReorderMode,
          bool,
          bool,
          bool,
          ModuleSurface
        > {
  SearchReorderModeFamily._()
    : super(
        retry: null,
        name: r'searchReorderModeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SearchReorderModeProvider call(ModuleSurface surface) =>
      SearchReorderModeProvider._(argument: surface, from: this);

  @override
  String toString() => r'searchReorderModeProvider';
}

abstract class _$SearchReorderMode extends $Notifier<bool> {
  late final _$args = ref.$arg as ModuleSurface;
  ModuleSurface get surface => _$args;

  bool build(ModuleSurface surface);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
