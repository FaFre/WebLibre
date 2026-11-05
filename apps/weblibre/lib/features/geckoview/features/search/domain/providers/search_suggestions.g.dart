// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_suggestions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(defaultSearchSuggestions)
final defaultSearchSuggestionsProvider = DefaultSearchSuggestionsProvider._();

final class DefaultSearchSuggestionsProvider
    extends
        $FunctionalProvider<
          ISearchSuggestionProvider,
          ISearchSuggestionProvider,
          ISearchSuggestionProvider
        >
    with $Provider<ISearchSuggestionProvider> {
  DefaultSearchSuggestionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'defaultSearchSuggestionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$defaultSearchSuggestionsHash();

  @$internal
  @override
  $ProviderElement<ISearchSuggestionProvider> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ISearchSuggestionProvider create(Ref ref) {
    return defaultSearchSuggestions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ISearchSuggestionProvider value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ISearchSuggestionProvider>(value),
    );
  }
}

String _$defaultSearchSuggestionsHash() =>
    r'6d7a387c7daeb790a4c9a5cdc105d2a2bdbacd2b';

@ProviderFor(SearchSuggestions)
final searchSuggestionsProvider = SearchSuggestionsFamily._();

final class SearchSuggestionsProvider
    extends $StreamNotifierProvider<SearchSuggestions, List<String>> {
  SearchSuggestionsProvider._({
    required SearchSuggestionsFamily super.from,
    required ISearchSuggestionProvider? super.argument,
  }) : super(
         retry: null,
         name: r'searchSuggestionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchSuggestionsHash();

  @override
  String toString() {
    return r'searchSuggestionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SearchSuggestions create() => SearchSuggestions();

  @override
  bool operator ==(Object other) {
    return other is SearchSuggestionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchSuggestionsHash() => r'1942092e576de694fe6066fe8f64d5c59b0c33d8';

final class SearchSuggestionsFamily extends $Family
    with
        $ClassFamilyOverride<
          SearchSuggestions,
          AsyncValue<List<String>>,
          List<String>,
          Stream<List<String>>,
          ISearchSuggestionProvider?
        > {
  SearchSuggestionsFamily._()
    : super(
        retry: null,
        name: r'searchSuggestionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SearchSuggestionsProvider call({
    ISearchSuggestionProvider? suggestionsProvider,
  }) => SearchSuggestionsProvider._(argument: suggestionsProvider, from: this);

  @override
  String toString() => r'searchSuggestionsProvider';
}

abstract class _$SearchSuggestions extends $StreamNotifier<List<String>> {
  late final _$args = ref.$arg as ISearchSuggestionProvider?;
  ISearchSuggestionProvider? get suggestionsProvider => _$args;

  Stream<List<String>> build({ISearchSuggestionProvider? suggestionsProvider});
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<String>>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<String>>, List<String>>,
              AsyncValue<List<String>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(suggestionsProvider: _$args));
  }
}

/// The default provider's search suggestions where remote suggestions are
/// fetched ([enabled]); none otherwise, without setting up the provider.

@ProviderFor(remoteSearchSuggestions)
final remoteSearchSuggestionsProvider = RemoteSearchSuggestionsFamily._();

/// The default provider's search suggestions where remote suggestions are
/// fetched ([enabled]); none otherwise, without setting up the provider.

final class RemoteSearchSuggestionsProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  /// The default provider's search suggestions where remote suggestions are
  /// fetched ([enabled]); none otherwise, without setting up the provider.
  RemoteSearchSuggestionsProvider._({
    required RemoteSearchSuggestionsFamily super.from,
    required bool super.argument,
  }) : super(
         retry: null,
         name: r'remoteSearchSuggestionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$remoteSearchSuggestionsHash();

  @override
  String toString() {
    return r'remoteSearchSuggestionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    final argument = this.argument as bool;
    return remoteSearchSuggestions(ref, enabled: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RemoteSearchSuggestionsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$remoteSearchSuggestionsHash() =>
    r'5805712586c45eb16822ec0f229090eb60b4ba65';

/// The default provider's search suggestions where remote suggestions are
/// fetched ([enabled]); none otherwise, without setting up the provider.

final class RemoteSearchSuggestionsFamily extends $Family
    with $FunctionalFamilyOverride<List<String>, bool> {
  RemoteSearchSuggestionsFamily._()
    : super(
        retry: null,
        name: r'remoteSearchSuggestionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The default provider's search suggestions where remote suggestions are
  /// fetched ([enabled]); none otherwise, without setting up the provider.

  RemoteSearchSuggestionsProvider call({required bool enabled}) =>
      RemoteSearchSuggestionsProvider._(argument: enabled, from: this);

  @override
  String toString() => r'remoteSearchSuggestionsProvider';
}
