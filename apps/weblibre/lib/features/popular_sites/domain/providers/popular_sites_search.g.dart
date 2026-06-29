// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'popular_sites_search.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds the current popular-domain prefix completions for the omnibar
/// "Popular Sites" module. Mirrors the bookmark/tab search-result notifiers:
/// the widget watches the state list and pushes new queries through [search].

@ProviderFor(PopularSitesSearchResults)
final popularSitesSearchResultsProvider = PopularSitesSearchResultsProvider._();

/// Holds the current popular-domain prefix completions for the omnibar
/// "Popular Sites" module. Mirrors the bookmark/tab search-result notifiers:
/// the widget watches the state list and pushes new queries through [search].
final class PopularSitesSearchResultsProvider
    extends $NotifierProvider<PopularSitesSearchResults, List<Site>> {
  /// Holds the current popular-domain prefix completions for the omnibar
  /// "Popular Sites" module. Mirrors the bookmark/tab search-result notifiers:
  /// the widget watches the state list and pushes new queries through [search].
  PopularSitesSearchResultsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'popularSitesSearchResultsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$popularSitesSearchResultsHash();

  @$internal
  @override
  PopularSitesSearchResults create() => PopularSitesSearchResults();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Site> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Site>>(value),
    );
  }
}

String _$popularSitesSearchResultsHash() =>
    r'107396362aa70acf898b75137df42717ac52f1b3';

/// Holds the current popular-domain prefix completions for the omnibar
/// "Popular Sites" module. Mirrors the bookmark/tab search-result notifiers:
/// the widget watches the state list and pushes new queries through [search].

abstract class _$PopularSitesSearchResults extends $Notifier<List<Site>> {
  List<Site> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<Site>, List<Site>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Site>, List<Site>>,
              List<Site>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
