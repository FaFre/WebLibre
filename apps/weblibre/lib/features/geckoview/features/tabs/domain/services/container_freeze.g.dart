// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container_freeze.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Container freeze on Dart's side (5.3, 5.5, 5.7 of
/// `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`): the only way a freeze
/// starts (D21), Resume with its routing check (D34), and the start-time
/// reconciliation that seeds the membership gate (5.5, 5.6).
///
/// Every freeze and Resume runs under the gate's operation reservation
/// ([ContainerMembershipGate.whileOperating]), so no membership change of the
/// container gets in while it runs, and the gate re-reads native's registry
/// afterwards.
///
/// keepAlive and started from main.dart: the placeholders' Resume buttons and
/// the reconciliation must work whatever screen is up.

@ProviderFor(ContainerFreezeService)
final containerFreezeServiceProvider = ContainerFreezeServiceProvider._();

/// Container freeze on Dart's side (5.3, 5.5, 5.7 of
/// `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`): the only way a freeze
/// starts (D21), Resume with its routing check (D34), and the start-time
/// reconciliation that seeds the membership gate (5.5, 5.6).
///
/// Every freeze and Resume runs under the gate's operation reservation
/// ([ContainerMembershipGate.whileOperating]), so no membership change of the
/// container gets in while it runs, and the gate re-reads native's registry
/// afterwards.
///
/// keepAlive and started from main.dart: the placeholders' Resume buttons and
/// the reconciliation must work whatever screen is up.
final class ContainerFreezeServiceProvider
    extends $NotifierProvider<ContainerFreezeService, void> {
  /// Container freeze on Dart's side (5.3, 5.5, 5.7 of
  /// `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`): the only way a freeze
  /// starts (D21), Resume with its routing check (D34), and the start-time
  /// reconciliation that seeds the membership gate (5.5, 5.6).
  ///
  /// Every freeze and Resume runs under the gate's operation reservation
  /// ([ContainerMembershipGate.whileOperating]), so no membership change of the
  /// container gets in while it runs, and the gate re-reads native's registry
  /// afterwards.
  ///
  /// keepAlive and started from main.dart: the placeholders' Resume buttons and
  /// the reconciliation must work whatever screen is up.
  ContainerFreezeServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'containerFreezeServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$containerFreezeServiceHash();

  @$internal
  @override
  ContainerFreezeService create() => ContainerFreezeService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$containerFreezeServiceHash() =>
    r'810f1e8783ae36e97dd3f57aafffe52a22ecb791';

/// Container freeze on Dart's side (5.3, 5.5, 5.7 of
/// `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`): the only way a freeze
/// starts (D21), Resume with its routing check (D34), and the start-time
/// reconciliation that seeds the membership gate (5.5, 5.6).
///
/// Every freeze and Resume runs under the gate's operation reservation
/// ([ContainerMembershipGate.whileOperating]), so no membership change of the
/// container gets in while it runs, and the gate re-reads native's registry
/// afterwards.
///
/// keepAlive and started from main.dart: the placeholders' Resume buttons and
/// the reconciliation must work whatever screen is up.

abstract class _$ContainerFreezeService extends $Notifier<void> {
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
