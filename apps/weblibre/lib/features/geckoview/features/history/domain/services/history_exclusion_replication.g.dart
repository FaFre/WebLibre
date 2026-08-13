// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_exclusion_replication.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The tab → container map from the latest snapshot, for consumers that need to
/// resolve a tab synchronously.

@ProviderFor(tabContainerIds)
final tabContainerIdsProvider = TabContainerIdsProvider._();

/// The tab → container map from the latest snapshot, for consumers that need to
/// resolve a tab synchronously.

final class TabContainerIdsProvider
    extends
        $FunctionalProvider<
          Map<String, String?>,
          Map<String, String?>,
          Map<String, String?>
        >
    with $Provider<Map<String, String?>> {
  /// The tab → container map from the latest snapshot, for consumers that need to
  /// resolve a tab synchronously.
  TabContainerIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tabContainerIdsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tabContainerIdsHash();

  @$internal
  @override
  $ProviderElement<Map<String, String?>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<String, String?> create(Ref ref) {
    return tabContainerIds(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, String?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, String?>>(value),
    );
  }
}

String _$tabContainerIdsHash() => r'210ec2be7ae857667fba43c892667089f6084051';

/// The single subscription to the tab↔container projection; both the native
/// snapshot and [tabContainerIds] are derived from it.
///
/// Emits on every tab or container change, skipping repeats — the tab table is
/// written far more often (content, timestamps) than any of this changes. The
/// underlying query joins `container`, so flipping the setting on a container
/// re-runs it without touching any tab.
///
/// The wasted scans are deliberate. Coalescing tab writes (throttled table-update
/// ticks instead of `watch()`) does cut them, but a tab's `container_id` moving
/// into an excluded container *is* one of those writes, and it is indistinguishable
/// from a title or timestamp write until the projection has been read. Any delay
/// is therefore a window in which native still holds the pre-move exclusion state
/// and a load in that tab reaches Places — paying for a background query with a
/// leak, which is the wrong trade for this projection.

@ProviderFor(watchHistoryExclusionSnapshot)
final watchHistoryExclusionSnapshotProvider =
    WatchHistoryExclusionSnapshotProvider._();

/// The single subscription to the tab↔container projection; both the native
/// snapshot and [tabContainerIds] are derived from it.
///
/// Emits on every tab or container change, skipping repeats — the tab table is
/// written far more often (content, timestamps) than any of this changes. The
/// underlying query joins `container`, so flipping the setting on a container
/// re-runs it without touching any tab.
///
/// The wasted scans are deliberate. Coalescing tab writes (throttled table-update
/// ticks instead of `watch()`) does cut them, but a tab's `container_id` moving
/// into an excluded container *is* one of those writes, and it is indistinguishable
/// from a title or timestamp write until the projection has been read. Any delay
/// is therefore a window in which native still holds the pre-move exclusion state
/// and a load in that tab reaches Places — paying for a background query with a
/// leak, which is the wrong trade for this projection.

final class WatchHistoryExclusionSnapshotProvider
    extends
        $FunctionalProvider<
          AsyncValue<HistoryExclusionSnapshot>,
          HistoryExclusionSnapshot,
          Stream<HistoryExclusionSnapshot>
        >
    with
        $FutureModifier<HistoryExclusionSnapshot>,
        $StreamProvider<HistoryExclusionSnapshot> {
  /// The single subscription to the tab↔container projection; both the native
  /// snapshot and [tabContainerIds] are derived from it.
  ///
  /// Emits on every tab or container change, skipping repeats — the tab table is
  /// written far more often (content, timestamps) than any of this changes. The
  /// underlying query joins `container`, so flipping the setting on a container
  /// re-runs it without touching any tab.
  ///
  /// The wasted scans are deliberate. Coalescing tab writes (throttled table-update
  /// ticks instead of `watch()`) does cut them, but a tab's `container_id` moving
  /// into an excluded container *is* one of those writes, and it is indistinguishable
  /// from a title or timestamp write until the projection has been read. Any delay
  /// is therefore a window in which native still holds the pre-move exclusion state
  /// and a load in that tab reaches Places — paying for a background query with a
  /// leak, which is the wrong trade for this projection.
  WatchHistoryExclusionSnapshotProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchHistoryExclusionSnapshotProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchHistoryExclusionSnapshotHash();

  @$internal
  @override
  $StreamProviderElement<HistoryExclusionSnapshot> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<HistoryExclusionSnapshot> create(Ref ref) {
    return watchHistoryExclusionSnapshot(ref);
  }
}

String _$watchHistoryExclusionSnapshotHash() =>
    r'073ec4248f1e0e6f9df8f3a1e8d27196652a308a';

/// Keeps native's exclude-from-history snapshot in sync with WebLibre's
/// containers and tabs. Activated eagerly at startup (and pushed once more
/// before engine init) so an excluded container never leaks a restored tab's
/// visit to Places.

@ProviderFor(historyExclusionReplication)
final historyExclusionReplicationProvider =
    HistoryExclusionReplicationProvider._();

/// Keeps native's exclude-from-history snapshot in sync with WebLibre's
/// containers and tabs. Activated eagerly at startup (and pushed once more
/// before engine init) so an excluded container never leaks a restored tab's
/// visit to Places.

final class HistoryExclusionReplicationProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Keeps native's exclude-from-history snapshot in sync with WebLibre's
  /// containers and tabs. Activated eagerly at startup (and pushed once more
  /// before engine init) so an excluded container never leaks a restored tab's
  /// visit to Places.
  HistoryExclusionReplicationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historyExclusionReplicationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historyExclusionReplicationHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return historyExclusionReplication(ref);
  }
}

String _$historyExclusionReplicationHash() =>
    r'0dacc3b6c49bd70deefa7187bbde35ee15d26485';
