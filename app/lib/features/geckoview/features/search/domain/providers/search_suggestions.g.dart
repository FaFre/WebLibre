// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_suggestions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$defaultSearchSuggestionsHash() =>
    r'56514064baa64acf0a28ec34cfad957dd863538b';

/// See also [defaultSearchSuggestions].
@ProviderFor(defaultSearchSuggestions)
final defaultSearchSuggestionsProvider =
    Provider<ISearchSuggestionProvider>.internal(
      defaultSearchSuggestions,
      name: r'defaultSearchSuggestionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$defaultSearchSuggestionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DefaultSearchSuggestionsRef = ProviderRef<ISearchSuggestionProvider>;
String _$searchSuggestionsHash() => r'8d1fb72cab374491a53f7a814f87af6a26356f42';

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

abstract class _$SearchSuggestions
    extends BuildlessAutoDisposeStreamNotifier<List<String>> {
  late final ISearchSuggestionProvider? suggestionsProvider;

  Stream<List<String>> build({ISearchSuggestionProvider? suggestionsProvider});
}

/// See also [SearchSuggestions].
@ProviderFor(SearchSuggestions)
const searchSuggestionsProvider = SearchSuggestionsFamily();

/// See also [SearchSuggestions].
class SearchSuggestionsFamily extends Family<AsyncValue<List<String>>> {
  /// See also [SearchSuggestions].
  const SearchSuggestionsFamily();

  /// See also [SearchSuggestions].
  SearchSuggestionsProvider call({
    ISearchSuggestionProvider? suggestionsProvider,
  }) {
    return SearchSuggestionsProvider(suggestionsProvider: suggestionsProvider);
  }

  @override
  SearchSuggestionsProvider getProviderOverride(
    covariant SearchSuggestionsProvider provider,
  ) {
    return call(suggestionsProvider: provider.suggestionsProvider);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'searchSuggestionsProvider';
}

/// See also [SearchSuggestions].
class SearchSuggestionsProvider
    extends
        AutoDisposeStreamNotifierProviderImpl<SearchSuggestions, List<String>> {
  /// See also [SearchSuggestions].
  SearchSuggestionsProvider({ISearchSuggestionProvider? suggestionsProvider})
    : this._internal(
        () => SearchSuggestions()..suggestionsProvider = suggestionsProvider,
        from: searchSuggestionsProvider,
        name: r'searchSuggestionsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$searchSuggestionsHash,
        dependencies: SearchSuggestionsFamily._dependencies,
        allTransitiveDependencies:
            SearchSuggestionsFamily._allTransitiveDependencies,
        suggestionsProvider: suggestionsProvider,
      );

  SearchSuggestionsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.suggestionsProvider,
  }) : super.internal();

  final ISearchSuggestionProvider? suggestionsProvider;

  @override
  Stream<List<String>> runNotifierBuild(covariant SearchSuggestions notifier) {
    return notifier.build(suggestionsProvider: suggestionsProvider);
  }

  @override
  Override overrideWith(SearchSuggestions Function() create) {
    return ProviderOverride(
      origin: this,
      override: SearchSuggestionsProvider._internal(
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
  AutoDisposeStreamNotifierProviderElement<SearchSuggestions, List<String>>
  createElement() {
    return _SearchSuggestionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchSuggestionsProvider &&
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
mixin SearchSuggestionsRef
    on AutoDisposeStreamNotifierProviderRef<List<String>> {
  /// The parameter `suggestionsProvider` of this provider.
  ISearchSuggestionProvider? get suggestionsProvider;
}

class _SearchSuggestionsProviderElement
    extends
        AutoDisposeStreamNotifierProviderElement<
          SearchSuggestions,
          List<String>
        >
    with SearchSuggestionsRef {
  _SearchSuggestionsProviderElement(super.provider);

  @override
  ISearchSuggestionProvider? get suggestionsProvider =>
      (origin as SearchSuggestionsProvider).suggestionsProvider;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
