// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'engine_suggestions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EngineSuggestions)
final engineSuggestionsProvider = EngineSuggestionsProvider._();

final class EngineSuggestionsProvider
    extends $StreamNotifierProvider<EngineSuggestions, List<GeckoSuggestion>> {
  EngineSuggestionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'engineSuggestionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$engineSuggestionsHash();

  @$internal
  @override
  EngineSuggestions create() => EngineSuggestions();
}

String _$engineSuggestionsHash() => r'ba2c2d7f0a5e99fd9e639acd020b8cf3016c6126';

abstract class _$EngineSuggestions
    extends $StreamNotifier<List<GeckoSuggestion>> {
  Stream<List<GeckoSuggestion>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<GeckoSuggestion>>, List<GeckoSuggestion>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<GeckoSuggestion>>,
                List<GeckoSuggestion>
              >,
              AsyncValue<List<GeckoSuggestion>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(engineHistorySuggestions)
final engineHistorySuggestionsProvider = EngineHistorySuggestionsProvider._();

final class EngineHistorySuggestionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GeckoSuggestion>>,
          AsyncValue<List<GeckoSuggestion>>,
          AsyncValue<List<GeckoSuggestion>>
        >
    with $Provider<AsyncValue<List<GeckoSuggestion>>> {
  EngineHistorySuggestionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'engineHistorySuggestionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$engineHistorySuggestionsHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<GeckoSuggestion>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<GeckoSuggestion>> create(Ref ref) {
    return engineHistorySuggestions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<GeckoSuggestion>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<GeckoSuggestion>>>(
        value,
      ),
    );
  }
}

String _$engineHistorySuggestionsHash() =>
    r'7e6c17e6a2df98098ca1a683a438d1c261ccabdf';
