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
    required SearchModuleType super.argument,
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
        '($argument)';
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
    r'c3f1c93b618eec76e86c1c9cf0bf8fbdfdcb1430';

final class SearchModuleDisplayStateControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          SearchModuleDisplayStateController,
          SearchModuleDisplayState,
          SearchModuleDisplayState,
          SearchModuleDisplayState,
          SearchModuleType
        > {
  SearchModuleDisplayStateControllerFamily._()
    : super(
        retry: null,
        name: r'searchModuleDisplayStateControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SearchModuleDisplayStateControllerProvider call(SearchModuleType module) =>
      SearchModuleDisplayStateControllerProvider._(
        argument: module,
        from: this,
      );

  @override
  String toString() => r'searchModuleDisplayStateControllerProvider';
}

abstract class _$SearchModuleDisplayStateController
    extends $Notifier<SearchModuleDisplayState> {
  late final _$args = ref.$arg as SearchModuleType;
  SearchModuleType get module => _$args;

  SearchModuleDisplayState build(SearchModuleType module);
  @$mustCallSuper
  @override
  void runBuild() {
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
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(SearchReorderMode)
final searchReorderModeProvider = SearchReorderModeProvider._();

final class SearchReorderModeProvider
    extends $NotifierProvider<SearchReorderMode, SearchModuleGroup?> {
  SearchReorderModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchReorderModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchReorderModeHash();

  @$internal
  @override
  SearchReorderMode create() => SearchReorderMode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchModuleGroup? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchModuleGroup?>(value),
    );
  }
}

String _$searchReorderModeHash() => r'eda188e53e5b5f1a331ce94c3cb8808c79e358d3';

abstract class _$SearchReorderMode extends $Notifier<SearchModuleGroup?> {
  SearchModuleGroup? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SearchModuleGroup?, SearchModuleGroup?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SearchModuleGroup?, SearchModuleGroup?>,
              SearchModuleGroup?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
