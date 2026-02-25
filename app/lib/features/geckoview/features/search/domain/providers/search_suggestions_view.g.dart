// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_suggestions_view.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SearchSuggestionsExpanded)
final searchSuggestionsExpandedProvider = SearchSuggestionsExpandedProvider._();

final class SearchSuggestionsExpandedProvider
    extends $NotifierProvider<SearchSuggestionsExpanded, bool> {
  SearchSuggestionsExpandedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchSuggestionsExpandedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchSuggestionsExpandedHash();

  @$internal
  @override
  SearchSuggestionsExpanded create() => SearchSuggestionsExpanded();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$searchSuggestionsExpandedHash() =>
    r'520bcdb9ef624c2ebe5a570d4dab034de5b4f475';

abstract class _$SearchSuggestionsExpanded extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
