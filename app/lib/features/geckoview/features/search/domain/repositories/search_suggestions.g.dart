// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_suggestions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SearchSuggestionsRepository)
const searchSuggestionsRepositoryProvider =
    SearchSuggestionsRepositoryFamily._();

final class SearchSuggestionsRepositoryProvider
    extends
        $NotifierProvider<
          SearchSuggestionsRepository,
          Raw<Stream<List<String>>>
        > {
  const SearchSuggestionsRepositoryProvider._({
    required SearchSuggestionsRepositoryFamily super.from,
    required ISearchSuggestionProvider super.argument,
  }) : super(
         retry: null,
         name: r'searchSuggestionsRepositoryProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchSuggestionsRepositoryHash();

  @override
  String toString() {
    return r'searchSuggestionsRepositoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SearchSuggestionsRepository create() => SearchSuggestionsRepository();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Raw<Stream<List<String>>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Raw<Stream<List<String>>>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SearchSuggestionsRepositoryProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchSuggestionsRepositoryHash() =>
    r'be75d075c3479c3d5e462211dec8bbd21b106820';

final class SearchSuggestionsRepositoryFamily extends $Family
    with
        $ClassFamilyOverride<
          SearchSuggestionsRepository,
          Raw<Stream<List<String>>>,
          Raw<Stream<List<String>>>,
          Raw<Stream<List<String>>>,
          ISearchSuggestionProvider
        > {
  const SearchSuggestionsRepositoryFamily._()
    : super(
        retry: null,
        name: r'searchSuggestionsRepositoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  SearchSuggestionsRepositoryProvider call(
    ISearchSuggestionProvider suggestionsProvider,
  ) => SearchSuggestionsRepositoryProvider._(
    argument: suggestionsProvider,
    from: this,
  );

  @override
  String toString() => r'searchSuggestionsRepositoryProvider';
}

abstract class _$SearchSuggestionsRepository
    extends $Notifier<Raw<Stream<List<String>>>> {
  late final _$args = ref.$arg as ISearchSuggestionProvider;
  ISearchSuggestionProvider get suggestionsProvider => _$args;

  Raw<Stream<List<String>>> build(
    ISearchSuggestionProvider suggestionsProvider,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref as $Ref<Raw<Stream<List<String>>>, Raw<Stream<List<String>>>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Raw<Stream<List<String>>>, Raw<Stream<List<String>>>>,
              Raw<Stream<List<String>>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
