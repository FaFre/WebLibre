// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_search.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Search the local history content index. Mirrors `TabSearchRepository`'s
/// shape so the two integrate symmetrically into the search UI.
///
/// Visit metadata is fetched from Places at query time and folded into the
/// score before emitting state. The DAO returns rows ordered by raw BM25;
/// Places adds the frecency / recency signal we don't track locally.

@ProviderFor(HistorySearchRepository)
final historySearchRepositoryProvider = HistorySearchRepositoryProvider._();

/// Search the local history content index. Mirrors `TabSearchRepository`'s
/// shape so the two integrate symmetrically into the search UI.
///
/// Visit metadata is fetched from Places at query time and folded into the
/// score before emitting state. The DAO returns rows ordered by raw BM25;
/// Places adds the frecency / recency signal we don't track locally.
final class HistorySearchRepositoryProvider
    extends
        $AsyncNotifierProvider<
          HistorySearchRepository,
          ({String query, List<HistoryQueryResult> results})?
        > {
  /// Search the local history content index. Mirrors `TabSearchRepository`'s
  /// shape so the two integrate symmetrically into the search UI.
  ///
  /// Visit metadata is fetched from Places at query time and folded into the
  /// score before emitting state. The DAO returns rows ordered by raw BM25;
  /// Places adds the frecency / recency signal we don't track locally.
  HistorySearchRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historySearchRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historySearchRepositoryHash();

  @$internal
  @override
  HistorySearchRepository create() => HistorySearchRepository();
}

String _$historySearchRepositoryHash() =>
    r'd999bfaf32268363f51a3c6831fffa1b14420b07';

/// Search the local history content index. Mirrors `TabSearchRepository`'s
/// shape so the two integrate symmetrically into the search UI.
///
/// Visit metadata is fetched from Places at query time and folded into the
/// score before emitting state. The DAO returns rows ordered by raw BM25;
/// Places adds the frecency / recency signal we don't track locally.

abstract class _$HistorySearchRepository
    extends
        $AsyncNotifier<({String query, List<HistoryQueryResult> results})?> {
  FutureOr<({String query, List<HistoryQueryResult> results})?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<({String query, List<HistoryQueryResult> results})?>,
              ({String query, List<HistoryQueryResult> results})?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<({String query, List<HistoryQueryResult> results})?>,
                ({String query, List<HistoryQueryResult> results})?
              >,
              AsyncValue<({String query, List<HistoryQueryResult> results})?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
