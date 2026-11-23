// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container_membership_gate.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Coordinates operations that change which tabs belong to a container with
/// the operations that need that membership to hold still: deleting a
/// container, and freezing or resuming one (5.7 of the tab lock and freeze
/// plan).
///
/// **Deletion.** Every operation that adds a tab to a
/// container, restores one into it or moves one in or out holds a **change**
/// reservation on it from its decision until its row is written
/// ([whileChanging]). A deletion takes a **deleting** reservation
/// ([whileDeleting]) only while no change is in flight, and while it holds
/// one no change can start. So no tab can join a container after its deletion
/// read the members, and lose its row to the cascade: a check before the
/// addition would not do, since the addition goes on after it.
///
/// **Freeze** (D19, D21, D27). The gate knows which containers native
/// restricts from a revisioned snapshot of native's registry
/// ([GeckoTabLifecycleService.lifecycleSnapshot]), read before it decides
/// anything ([seed]), and a freeze or Resume holds an **operation**
/// reservation on its container while it runs ([whileOperating]). A container
/// is restricted while the snapshot says so, while an operation holds it, or
/// while native is in recovery mode (every container then). Changes of kind
/// [ContainerChange.membership] are refused for a restricted container
/// ([ContainerFrozenException]); regular additions are not. When an operation
/// ends, the gate reads a fresh snapshot, while the reservation still holds
/// the container; if that read fails, every container counts as restricted
/// until a read succeeds. Native's own changes (a background relift, a
/// release, the start-time reconciliation) arrive as snapshots on
/// [GeckoEventService.contextFreezeEvents]. Every snapshot, read or reported,
/// is taken only when its revision is not older than the one held, so a
/// delayed one cannot undo a newer Resume or freeze. Operation replies never
/// set the gate's state.
///
/// A deletion refuses rather than waits, and a change nested in another's
/// reservation (a move that reopens the tab with `addTab`) passes: the outer
/// reservation already keeps the deletion from starting.
///
/// Two kinds of change cannot simply be refused:
///
/// - A tab the engine opened by itself from one of the container's pages (a
///   popup) exists already. Its refusal is recorded ([whileChanging]'s
///   `openedTabId`), the deletion closes it with the container's own tabs
///   ([tabsOpenedDuringDeletion]), and its owner settles what is left once
///   the deletion is over ([deletionFinished]).
///   Its own windows, and any window whose opener's row is gone by the time
///   the engine reports it, belong to the container as well: the gate keeps
///   the tabs a deletion took or refused ([deletionLineageOf]), so that the
///   tab repository can file them with it.
/// - An undo close restores tabs whose containers are known only once they
///   are back. It holds off every deletion ([whileChangingAnywhere]) until
///   their rows are written, and a Resume's release of isolation groups
///   ([whileReleasing]) with it: neither starts while the other runs.
///
/// Lock order, everywhere: this gate first, then the tab repository's close
/// lock. The gate's decisions are synchronous and never wait on the engine,
/// so a slow or hung engine call cannot hold up another decision.

@ProviderFor(ContainerMembershipGate)
final containerMembershipGateProvider = ContainerMembershipGateProvider._();

/// Coordinates operations that change which tabs belong to a container with
/// the operations that need that membership to hold still: deleting a
/// container, and freezing or resuming one (5.7 of the tab lock and freeze
/// plan).
///
/// **Deletion.** Every operation that adds a tab to a
/// container, restores one into it or moves one in or out holds a **change**
/// reservation on it from its decision until its row is written
/// ([whileChanging]). A deletion takes a **deleting** reservation
/// ([whileDeleting]) only while no change is in flight, and while it holds
/// one no change can start. So no tab can join a container after its deletion
/// read the members, and lose its row to the cascade: a check before the
/// addition would not do, since the addition goes on after it.
///
/// **Freeze** (D19, D21, D27). The gate knows which containers native
/// restricts from a revisioned snapshot of native's registry
/// ([GeckoTabLifecycleService.lifecycleSnapshot]), read before it decides
/// anything ([seed]), and a freeze or Resume holds an **operation**
/// reservation on its container while it runs ([whileOperating]). A container
/// is restricted while the snapshot says so, while an operation holds it, or
/// while native is in recovery mode (every container then). Changes of kind
/// [ContainerChange.membership] are refused for a restricted container
/// ([ContainerFrozenException]); regular additions are not. When an operation
/// ends, the gate reads a fresh snapshot, while the reservation still holds
/// the container; if that read fails, every container counts as restricted
/// until a read succeeds. Native's own changes (a background relift, a
/// release, the start-time reconciliation) arrive as snapshots on
/// [GeckoEventService.contextFreezeEvents]. Every snapshot, read or reported,
/// is taken only when its revision is not older than the one held, so a
/// delayed one cannot undo a newer Resume or freeze. Operation replies never
/// set the gate's state.
///
/// A deletion refuses rather than waits, and a change nested in another's
/// reservation (a move that reopens the tab with `addTab`) passes: the outer
/// reservation already keeps the deletion from starting.
///
/// Two kinds of change cannot simply be refused:
///
/// - A tab the engine opened by itself from one of the container's pages (a
///   popup) exists already. Its refusal is recorded ([whileChanging]'s
///   `openedTabId`), the deletion closes it with the container's own tabs
///   ([tabsOpenedDuringDeletion]), and its owner settles what is left once
///   the deletion is over ([deletionFinished]).
///   Its own windows, and any window whose opener's row is gone by the time
///   the engine reports it, belong to the container as well: the gate keeps
///   the tabs a deletion took or refused ([deletionLineageOf]), so that the
///   tab repository can file them with it.
/// - An undo close restores tabs whose containers are known only once they
///   are back. It holds off every deletion ([whileChangingAnywhere]) until
///   their rows are written, and a Resume's release of isolation groups
///   ([whileReleasing]) with it: neither starts while the other runs.
///
/// Lock order, everywhere: this gate first, then the tab repository's close
/// lock. The gate's decisions are synchronous and never wait on the engine,
/// so a slow or hung engine call cannot hold up another decision.
final class ContainerMembershipGateProvider
    extends $NotifierProvider<ContainerMembershipGate, void> {
  /// Coordinates operations that change which tabs belong to a container with
  /// the operations that need that membership to hold still: deleting a
  /// container, and freezing or resuming one (5.7 of the tab lock and freeze
  /// plan).
  ///
  /// **Deletion.** Every operation that adds a tab to a
  /// container, restores one into it or moves one in or out holds a **change**
  /// reservation on it from its decision until its row is written
  /// ([whileChanging]). A deletion takes a **deleting** reservation
  /// ([whileDeleting]) only while no change is in flight, and while it holds
  /// one no change can start. So no tab can join a container after its deletion
  /// read the members, and lose its row to the cascade: a check before the
  /// addition would not do, since the addition goes on after it.
  ///
  /// **Freeze** (D19, D21, D27). The gate knows which containers native
  /// restricts from a revisioned snapshot of native's registry
  /// ([GeckoTabLifecycleService.lifecycleSnapshot]), read before it decides
  /// anything ([seed]), and a freeze or Resume holds an **operation**
  /// reservation on its container while it runs ([whileOperating]). A container
  /// is restricted while the snapshot says so, while an operation holds it, or
  /// while native is in recovery mode (every container then). Changes of kind
  /// [ContainerChange.membership] are refused for a restricted container
  /// ([ContainerFrozenException]); regular additions are not. When an operation
  /// ends, the gate reads a fresh snapshot, while the reservation still holds
  /// the container; if that read fails, every container counts as restricted
  /// until a read succeeds. Native's own changes (a background relift, a
  /// release, the start-time reconciliation) arrive as snapshots on
  /// [GeckoEventService.contextFreezeEvents]. Every snapshot, read or reported,
  /// is taken only when its revision is not older than the one held, so a
  /// delayed one cannot undo a newer Resume or freeze. Operation replies never
  /// set the gate's state.
  ///
  /// A deletion refuses rather than waits, and a change nested in another's
  /// reservation (a move that reopens the tab with `addTab`) passes: the outer
  /// reservation already keeps the deletion from starting.
  ///
  /// Two kinds of change cannot simply be refused:
  ///
  /// - A tab the engine opened by itself from one of the container's pages (a
  ///   popup) exists already. Its refusal is recorded ([whileChanging]'s
  ///   `openedTabId`), the deletion closes it with the container's own tabs
  ///   ([tabsOpenedDuringDeletion]), and its owner settles what is left once
  ///   the deletion is over ([deletionFinished]).
  ///   Its own windows, and any window whose opener's row is gone by the time
  ///   the engine reports it, belong to the container as well: the gate keeps
  ///   the tabs a deletion took or refused ([deletionLineageOf]), so that the
  ///   tab repository can file them with it.
  /// - An undo close restores tabs whose containers are known only once they
  ///   are back. It holds off every deletion ([whileChangingAnywhere]) until
  ///   their rows are written, and a Resume's release of isolation groups
  ///   ([whileReleasing]) with it: neither starts while the other runs.
  ///
  /// Lock order, everywhere: this gate first, then the tab repository's close
  /// lock. The gate's decisions are synchronous and never wait on the engine,
  /// so a slow or hung engine call cannot hold up another decision.
  ContainerMembershipGateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'containerMembershipGateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$containerMembershipGateHash();

  @$internal
  @override
  ContainerMembershipGate create() => ContainerMembershipGate();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$containerMembershipGateHash() =>
    r'5b77466272a4b4fbe57d319449139d49b797f839';

/// Coordinates operations that change which tabs belong to a container with
/// the operations that need that membership to hold still: deleting a
/// container, and freezing or resuming one (5.7 of the tab lock and freeze
/// plan).
///
/// **Deletion.** Every operation that adds a tab to a
/// container, restores one into it or moves one in or out holds a **change**
/// reservation on it from its decision until its row is written
/// ([whileChanging]). A deletion takes a **deleting** reservation
/// ([whileDeleting]) only while no change is in flight, and while it holds
/// one no change can start. So no tab can join a container after its deletion
/// read the members, and lose its row to the cascade: a check before the
/// addition would not do, since the addition goes on after it.
///
/// **Freeze** (D19, D21, D27). The gate knows which containers native
/// restricts from a revisioned snapshot of native's registry
/// ([GeckoTabLifecycleService.lifecycleSnapshot]), read before it decides
/// anything ([seed]), and a freeze or Resume holds an **operation**
/// reservation on its container while it runs ([whileOperating]). A container
/// is restricted while the snapshot says so, while an operation holds it, or
/// while native is in recovery mode (every container then). Changes of kind
/// [ContainerChange.membership] are refused for a restricted container
/// ([ContainerFrozenException]); regular additions are not. When an operation
/// ends, the gate reads a fresh snapshot, while the reservation still holds
/// the container; if that read fails, every container counts as restricted
/// until a read succeeds. Native's own changes (a background relift, a
/// release, the start-time reconciliation) arrive as snapshots on
/// [GeckoEventService.contextFreezeEvents]. Every snapshot, read or reported,
/// is taken only when its revision is not older than the one held, so a
/// delayed one cannot undo a newer Resume or freeze. Operation replies never
/// set the gate's state.
///
/// A deletion refuses rather than waits, and a change nested in another's
/// reservation (a move that reopens the tab with `addTab`) passes: the outer
/// reservation already keeps the deletion from starting.
///
/// Two kinds of change cannot simply be refused:
///
/// - A tab the engine opened by itself from one of the container's pages (a
///   popup) exists already. Its refusal is recorded ([whileChanging]'s
///   `openedTabId`), the deletion closes it with the container's own tabs
///   ([tabsOpenedDuringDeletion]), and its owner settles what is left once
///   the deletion is over ([deletionFinished]).
///   Its own windows, and any window whose opener's row is gone by the time
///   the engine reports it, belong to the container as well: the gate keeps
///   the tabs a deletion took or refused ([deletionLineageOf]), so that the
///   tab repository can file them with it.
/// - An undo close restores tabs whose containers are known only once they
///   are back. It holds off every deletion ([whileChangingAnywhere]) until
///   their rows are written, and a Resume's release of isolation groups
///   ([whileReleasing]) with it: neither starts while the other runs.
///
/// Lock order, everywhere: this gate first, then the tab repository's close
/// lock. The gate's decisions are synchronous and never wait on the engine,
/// so a slow or hung engine call cannot hold up another decision.

abstract class _$ContainerMembershipGate extends $Notifier<void> {
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
