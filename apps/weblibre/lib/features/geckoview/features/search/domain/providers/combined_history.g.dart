// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'combined_history.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Engine suggestions, augmented per-row with local snippet/highlight when
/// available, then padded with local-only matches.
///
/// Implementation note: kept as a synchronous Riverpod provider that derives
/// its data from `engineSuggestionsProvider` + `historySearchRepositoryProvider`.
/// Both upstream providers are responsible for kicking off their own queries
/// when the search text changes; this one just reacts.

@ProviderFor(combinedHistorySuggestions)
final combinedHistorySuggestionsProvider =
    CombinedHistorySuggestionsProvider._();

/// Engine suggestions, augmented per-row with local snippet/highlight when
/// available, then padded with local-only matches.
///
/// Implementation note: kept as a synchronous Riverpod provider that derives
/// its data from `engineSuggestionsProvider` + `historySearchRepositoryProvider`.
/// Both upstream providers are responsible for kicking off their own queries
/// when the search text changes; this one just reacts.

final class CombinedHistorySuggestionsProvider
    extends
        $FunctionalProvider<
          List<CombinedHistoryItem>,
          List<CombinedHistoryItem>,
          List<CombinedHistoryItem>
        >
    with $Provider<List<CombinedHistoryItem>> {
  /// Engine suggestions, augmented per-row with local snippet/highlight when
  /// available, then padded with local-only matches.
  ///
  /// Implementation note: kept as a synchronous Riverpod provider that derives
  /// its data from `engineSuggestionsProvider` + `historySearchRepositoryProvider`.
  /// Both upstream providers are responsible for kicking off their own queries
  /// when the search text changes; this one just reacts.
  CombinedHistorySuggestionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'combinedHistorySuggestionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$combinedHistorySuggestionsHash();

  @$internal
  @override
  $ProviderElement<List<CombinedHistoryItem>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<CombinedHistoryItem> create(Ref ref) {
    return combinedHistorySuggestions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<CombinedHistoryItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<CombinedHistoryItem>>(value),
    );
  }
}

String _$combinedHistorySuggestionsHash() =>
    r'a2cc2bc57529cb60e9ac75e83e3a7babb7f950ea';
