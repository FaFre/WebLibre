// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_index_pruner.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drops local history rows that the engine no longer remembers (the user
/// cleared browsing data, the engine's own retention pruned them, etc.).
///
/// Triggered manually — call `prune()` from a periodic timer (cold-start
/// once per app launch is enough). The sweep walks the whole table in batches
/// so stale rows don't get stranded behind an always-valid oldest page.

@ProviderFor(LocalIndexPruner)
final localIndexPrunerProvider = LocalIndexPrunerProvider._();

/// Drops local history rows that the engine no longer remembers (the user
/// cleared browsing data, the engine's own retention pruned them, etc.).
///
/// Triggered manually — call `prune()` from a periodic timer (cold-start
/// once per app launch is enough). The sweep walks the whole table in batches
/// so stale rows don't get stranded behind an always-valid oldest page.
final class LocalIndexPrunerProvider
    extends $NotifierProvider<LocalIndexPruner, void> {
  /// Drops local history rows that the engine no longer remembers (the user
  /// cleared browsing data, the engine's own retention pruned them, etc.).
  ///
  /// Triggered manually — call `prune()` from a periodic timer (cold-start
  /// once per app launch is enough). The sweep walks the whole table in batches
  /// so stale rows don't get stranded behind an always-valid oldest page.
  LocalIndexPrunerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localIndexPrunerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localIndexPrunerHash();

  @$internal
  @override
  LocalIndexPruner create() => LocalIndexPruner();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$localIndexPrunerHash() => r'471b82b87fdc9e075d7afed042682c9592c8735a';

/// Drops local history rows that the engine no longer remembers (the user
/// cleared browsing data, the engine's own retention pruned them, etc.).
///
/// Triggered manually — call `prune()` from a periodic timer (cold-start
/// once per app launch is enough). The sweep walks the whole table in batches
/// so stale rows don't get stranded behind an always-valid oldest page.

abstract class _$LocalIndexPruner extends $Notifier<void> {
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
