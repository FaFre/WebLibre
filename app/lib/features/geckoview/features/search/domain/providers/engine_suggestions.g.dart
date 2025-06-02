// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'engine_suggestions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$engineHistorySuggestionsHash() =>
    r'7e6c17e6a2df98098ca1a683a438d1c261ccabdf';

/// See also [engineHistorySuggestions].
@ProviderFor(engineHistorySuggestions)
final engineHistorySuggestionsProvider =
    AutoDisposeProvider<AsyncValue<List<GeckoSuggestion>>>.internal(
      engineHistorySuggestions,
      name: r'engineHistorySuggestionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$engineHistorySuggestionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EngineHistorySuggestionsRef =
    AutoDisposeProviderRef<AsyncValue<List<GeckoSuggestion>>>;
String _$engineSuggestionsHash() => r'ba2c2d7f0a5e99fd9e639acd020b8cf3016c6126';

/// See also [EngineSuggestions].
@ProviderFor(EngineSuggestions)
final engineSuggestionsProvider =
    AutoDisposeStreamNotifierProvider<
      EngineSuggestions,
      List<GeckoSuggestion>
    >.internal(
      EngineSuggestions.new,
      name: r'engineSuggestionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$engineSuggestionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$EngineSuggestions = AutoDisposeStreamNotifier<List<GeckoSuggestion>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
