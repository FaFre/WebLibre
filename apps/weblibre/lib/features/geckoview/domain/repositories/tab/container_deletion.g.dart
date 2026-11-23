// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container_deletion.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Deleting a container with its tabs, for the tab repository (D28, D35 of
/// `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`): its tabs are closed
/// and its row deleted, unless one of its tabs is locked.
///
/// Checked before anything is closed or deleted, against both lock sets:
/// the protocol allows a lock only native holds. The row goes only when the
/// close removed every member — the cascade on `tab.container_id` would take
/// a surviving tab's row with it — and its delete is conditional in SQL as
/// the last guard.
///
/// Holds the membership gate's deleting reservation throughout, so no tab
/// joins the container meanwhile; the lock order is the gate, then the
/// close lock ([tabCloseLockProvider]). A window one of its pages opens
/// meanwhile is closed with it (see `TabRepository.handleTabAdded`), and the
/// pending undo close is dropped when it would bring one of its tabs back.

@ProviderFor(ContainerDeletion)
final containerDeletionProvider = ContainerDeletionProvider._();

/// Deleting a container with its tabs, for the tab repository (D28, D35 of
/// `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`): its tabs are closed
/// and its row deleted, unless one of its tabs is locked.
///
/// Checked before anything is closed or deleted, against both lock sets:
/// the protocol allows a lock only native holds. The row goes only when the
/// close removed every member — the cascade on `tab.container_id` would take
/// a surviving tab's row with it — and its delete is conditional in SQL as
/// the last guard.
///
/// Holds the membership gate's deleting reservation throughout, so no tab
/// joins the container meanwhile; the lock order is the gate, then the
/// close lock ([tabCloseLockProvider]). A window one of its pages opens
/// meanwhile is closed with it (see `TabRepository.handleTabAdded`), and the
/// pending undo close is dropped when it would bring one of its tabs back.
final class ContainerDeletionProvider
    extends $NotifierProvider<ContainerDeletion, void> {
  /// Deleting a container with its tabs, for the tab repository (D28, D35 of
  /// `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`): its tabs are closed
  /// and its row deleted, unless one of its tabs is locked.
  ///
  /// Checked before anything is closed or deleted, against both lock sets:
  /// the protocol allows a lock only native holds. The row goes only when the
  /// close removed every member — the cascade on `tab.container_id` would take
  /// a surviving tab's row with it — and its delete is conditional in SQL as
  /// the last guard.
  ///
  /// Holds the membership gate's deleting reservation throughout, so no tab
  /// joins the container meanwhile; the lock order is the gate, then the
  /// close lock ([tabCloseLockProvider]). A window one of its pages opens
  /// meanwhile is closed with it (see `TabRepository.handleTabAdded`), and the
  /// pending undo close is dropped when it would bring one of its tabs back.
  ContainerDeletionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'containerDeletionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$containerDeletionHash();

  @$internal
  @override
  ContainerDeletion create() => ContainerDeletion();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$containerDeletionHash() => r'047015c9c877c7c0259fc957f9c09a80938da365';

/// Deleting a container with its tabs, for the tab repository (D28, D35 of
/// `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`): its tabs are closed
/// and its row deleted, unless one of its tabs is locked.
///
/// Checked before anything is closed or deleted, against both lock sets:
/// the protocol allows a lock only native holds. The row goes only when the
/// close removed every member — the cascade on `tab.container_id` would take
/// a surviving tab's row with it — and its delete is conditional in SQL as
/// the last guard.
///
/// Holds the membership gate's deleting reservation throughout, so no tab
/// joins the container meanwhile; the lock order is the gate, then the
/// close lock ([tabCloseLockProvider]). A window one of its pages opens
/// meanwhile is closed with it (see `TabRepository.handleTabAdded`), and the
/// pending undo close is dropped when it would bring one of its tabs back.

abstract class _$ContainerDeletion extends $Notifier<void> {
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
