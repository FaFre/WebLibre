// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_suggestions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$searchSuggestionsRepositoryHash() =>
    r'be75d075c3479c3d5e462211dec8bbd21b106820';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$SearchSuggestionsRepository
    extends BuildlessNotifier<Raw<Stream<List<String>>>> {
  late final ISearchSuggestionProvider suggestionsProvider;

  Raw<Stream<List<String>>> build(
    ISearchSuggestionProvider suggestionsProvider,
  );
}

/// See also [SearchSuggestionsRepository].
@ProviderFor(SearchSuggestionsRepository)
const searchSuggestionsRepositoryProvider = SearchSuggestionsRepositoryFamily();

/// See also [SearchSuggestionsRepository].
class SearchSuggestionsRepositoryFamily
    extends Family<Raw<Stream<List<String>>>> {
  /// See also [SearchSuggestionsRepository].
  const SearchSuggestionsRepositoryFamily();

  /// See also [SearchSuggestionsRepository].
  SearchSuggestionsRepositoryProvider call(
    ISearchSuggestionProvider suggestionsProvider,
  ) {
    return SearchSuggestionsRepositoryProvider(
      suggestionsProvider,
    );
  }

  @override
  SearchSuggestionsRepositoryProvider getProviderOverride(
    covariant SearchSuggestionsRepositoryProvider provider,
  ) {
    return call(
      provider.suggestionsProvider,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'searchSuggestionsRepositoryProvider';
}

/// See also [SearchSuggestionsRepository].
class SearchSuggestionsRepositoryProvider extends NotifierProviderImpl<
    SearchSuggestionsRepository, Raw<Stream<List<String>>>> {
  /// See also [SearchSuggestionsRepository].
  SearchSuggestionsRepositoryProvider(
    ISearchSuggestionProvider suggestionsProvider,
  ) : this._internal(
          () => SearchSuggestionsRepository()
            ..suggestionsProvider = suggestionsProvider,
          from: searchSuggestionsRepositoryProvider,
          name: r'searchSuggestionsRepositoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$searchSuggestionsRepositoryHash,
          dependencies: SearchSuggestionsRepositoryFamily._dependencies,
          allTransitiveDependencies:
              SearchSuggestionsRepositoryFamily._allTransitiveDependencies,
          suggestionsProvider: suggestionsProvider,
        );

  SearchSuggestionsRepositoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.suggestionsProvider,
  }) : super.internal();

  final ISearchSuggestionProvider suggestionsProvider;

  @override
  Raw<Stream<List<String>>> runNotifierBuild(
    covariant SearchSuggestionsRepository notifier,
  ) {
    return notifier.build(
      suggestionsProvider,
    );
  }

  @override
  Override overrideWith(SearchSuggestionsRepository Function() create) {
    return ProviderOverride(
      origin: this,
      override: SearchSuggestionsRepositoryProvider._internal(
        () => create()..suggestionsProvider = suggestionsProvider,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        suggestionsProvider: suggestionsProvider,
      ),
    );
  }

  @override
  NotifierProviderElement<SearchSuggestionsRepository,
      Raw<Stream<List<String>>>> createElement() {
    return _SearchSuggestionsRepositoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchSuggestionsRepositoryProvider &&
        other.suggestionsProvider == suggestionsProvider;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, suggestionsProvider.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SearchSuggestionsRepositoryRef
    on NotifierProviderRef<Raw<Stream<List<String>>>> {
  /// The parameter `suggestionsProvider` of this provider.
  ISearchSuggestionProvider get suggestionsProvider;
}

class _SearchSuggestionsRepositoryProviderElement
    extends NotifierProviderElement<SearchSuggestionsRepository,
        Raw<Stream<List<String>>>> with SearchSuggestionsRepositoryRef {
  _SearchSuggestionsRepositoryProviderElement(super.provider);

  @override
  ISearchSuggestionProvider get suggestionsProvider =>
      (origin as SearchSuggestionsRepositoryProvider).suggestionsProvider;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
