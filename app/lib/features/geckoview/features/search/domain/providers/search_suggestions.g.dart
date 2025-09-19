// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_suggestions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(defaultSearchSuggestions)
const defaultSearchSuggestionsProvider = DefaultSearchSuggestionsProvider._();

final class DefaultSearchSuggestionsProvider
    extends
        $FunctionalProvider<
          ISearchSuggestionProvider,
          ISearchSuggestionProvider,
          ISearchSuggestionProvider
        >
    with $Provider<ISearchSuggestionProvider> {
  const DefaultSearchSuggestionsProvider._()
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
const searchSuggestionsProvider = SearchSuggestionsFamily._();

final class SearchSuggestionsProvider
    extends $StreamNotifierProvider<SearchSuggestions, List<String>> {
  const SearchSuggestionsProvider._({
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

String _$searchSuggestionsHash() => r'8d1fb72cab374491a53f7a814f87af6a26356f42';

final class SearchSuggestionsFamily extends $Family
    with
        $ClassFamilyOverride<
          SearchSuggestions,
          AsyncValue<List<String>>,
          List<String>,
          Stream<List<String>>,
          ISearchSuggestionProvider?
        > {
  const SearchSuggestionsFamily._()
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
  void runBuild() {
    final created = build(suggestionsProvider: _$args);
    final ref = this.ref as $Ref<AsyncValue<List<String>>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<String>>, List<String>>,
              AsyncValue<List<String>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
