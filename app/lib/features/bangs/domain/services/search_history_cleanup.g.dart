// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_history_cleanup.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Service that listens to maxSearchHistoryEntries setting changes
/// and cleans up search history when the limit is reduced.

@ProviderFor(SearchHistoryCleanupService)
final searchHistoryCleanupServiceProvider =
    SearchHistoryCleanupServiceProvider._();

/// Service that listens to maxSearchHistoryEntries setting changes
/// and cleans up search history when the limit is reduced.
final class SearchHistoryCleanupServiceProvider
    extends $NotifierProvider<SearchHistoryCleanupService, void> {
  /// Service that listens to maxSearchHistoryEntries setting changes
  /// and cleans up search history when the limit is reduced.
  SearchHistoryCleanupServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchHistoryCleanupServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchHistoryCleanupServiceHash();

  @$internal
  @override
  SearchHistoryCleanupService create() => SearchHistoryCleanupService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$searchHistoryCleanupServiceHash() =>
    r'4e84ab50fa2ad55c615bb63a667c95383715570b';

/// Service that listens to maxSearchHistoryEntries setting changes
/// and cleans up search history when the limit is reduced.

abstract class _$SearchHistoryCleanupService extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
