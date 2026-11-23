// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_locks.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The tab lock protocol of the tab repository (L1, L2 of
/// `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`): a locked tab refuses
/// to close and is skipped by every bulk close until it is unlocked.
///
/// The lock lives in the database (what the user asked for) and natively
/// (what the engine enforces), and native's set always contains the
/// database's. So a lock goes native first, then the database, and an unlock
/// the other way round. A step that fails leaves the tab more locked, never
/// less, and [reconcile] repairs that from the database.
///
/// Every method but [isLocked], a read for choosing what to offer, runs
/// under the close lock ([tabCloseLockProvider]), which this does not take
/// itself: no close can fall between a lock's two writes, and a close's
/// preflight ([lockedAmong]) cannot disagree with native's removal.

@ProviderFor(TabLocks)
final tabLocksProvider = TabLocksProvider._();

/// The tab lock protocol of the tab repository (L1, L2 of
/// `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`): a locked tab refuses
/// to close and is skipped by every bulk close until it is unlocked.
///
/// The lock lives in the database (what the user asked for) and natively
/// (what the engine enforces), and native's set always contains the
/// database's. So a lock goes native first, then the database, and an unlock
/// the other way round. A step that fails leaves the tab more locked, never
/// less, and [reconcile] repairs that from the database.
///
/// Every method but [isLocked], a read for choosing what to offer, runs
/// under the close lock ([tabCloseLockProvider]), which this does not take
/// itself: no close can fall between a lock's two writes, and a close's
/// preflight ([lockedAmong]) cannot disagree with native's removal.
final class TabLocksProvider extends $NotifierProvider<TabLocks, void> {
  /// The tab lock protocol of the tab repository (L1, L2 of
  /// `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`): a locked tab refuses
  /// to close and is skipped by every bulk close until it is unlocked.
  ///
  /// The lock lives in the database (what the user asked for) and natively
  /// (what the engine enforces), and native's set always contains the
  /// database's. So a lock goes native first, then the database, and an unlock
  /// the other way round. A step that fails leaves the tab more locked, never
  /// less, and [reconcile] repairs that from the database.
  ///
  /// Every method but [isLocked], a read for choosing what to offer, runs
  /// under the close lock ([tabCloseLockProvider]), which this does not take
  /// itself: no close can fall between a lock's two writes, and a close's
  /// preflight ([lockedAmong]) cannot disagree with native's removal.
  TabLocksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tabLocksProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tabLocksHash();

  @$internal
  @override
  TabLocks create() => TabLocks();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$tabLocksHash() => r'828a26f8b29a2c9bbbf73c4849c4f5962dc30b30';

/// The tab lock protocol of the tab repository (L1, L2 of
/// `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`): a locked tab refuses
/// to close and is skipped by every bulk close until it is unlocked.
///
/// The lock lives in the database (what the user asked for) and natively
/// (what the engine enforces), and native's set always contains the
/// database's. So a lock goes native first, then the database, and an unlock
/// the other way round. A step that fails leaves the tab more locked, never
/// less, and [reconcile] repairs that from the database.
///
/// Every method but [isLocked], a read for choosing what to offer, runs
/// under the close lock ([tabCloseLockProvider]), which this does not take
/// itself: no close can fall between a lock's two writes, and a close's
/// preflight ([lockedAmong]) cannot disagree with native's removal.

abstract class _$TabLocks extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
