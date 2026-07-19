// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(pushService)
final pushServiceProvider = PushServiceProvider._();

final class PushServiceProvider
    extends
        $FunctionalProvider<
          GeckoPushService,
          GeckoPushService,
          GeckoPushService
        >
    with $Provider<GeckoPushService> {
  PushServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushServiceHash();

  @$internal
  @override
  $ProviderElement<GeckoPushService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GeckoPushService create(Ref ref) {
    return pushService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GeckoPushService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GeckoPushService>(value),
    );
  }
}

String _$pushServiceHash() => r'762a7893d6f0520cda6f566bdd1ac1679156286d';

/// Current distributor selection and availability.
///
/// Re-reads native state whenever the distributor acknowledges registration or
/// is uninstalled, so a distributor removed while this screen is open does not
/// leave a stale "configured" reading on screen.
///
/// The native event stream is subscribed to *before* the initial snapshot is
/// requested: `statusChanges` does not replay, so a PENDING → READY transition
/// landing between the two would otherwise be lost and leave the screen stale.
/// If an event wins that race the snapshot is discarded rather than emitted
/// after it, since the snapshot is by then the older value.

@ProviderFor(pushStatus)
final pushStatusProvider = PushStatusProvider._();

/// Current distributor selection and availability.
///
/// Re-reads native state whenever the distributor acknowledges registration or
/// is uninstalled, so a distributor removed while this screen is open does not
/// leave a stale "configured" reading on screen.
///
/// The native event stream is subscribed to *before* the initial snapshot is
/// requested: `statusChanges` does not replay, so a PENDING → READY transition
/// landing between the two would otherwise be lost and leave the screen stale.
/// If an event wins that race the snapshot is discarded rather than emitted
/// after it, since the snapshot is by then the older value.

final class PushStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<PushStatus>,
          PushStatus,
          Stream<PushStatus>
        >
    with $FutureModifier<PushStatus>, $StreamProvider<PushStatus> {
  /// Current distributor selection and availability.
  ///
  /// Re-reads native state whenever the distributor acknowledges registration or
  /// is uninstalled, so a distributor removed while this screen is open does not
  /// leave a stale "configured" reading on screen.
  ///
  /// The native event stream is subscribed to *before* the initial snapshot is
  /// requested: `statusChanges` does not replay, so a PENDING → READY transition
  /// landing between the two would otherwise be lost and leave the screen stale.
  /// If an event wins that race the snapshot is discarded rather than emitted
  /// after it, since the snapshot is by then the older value.
  PushStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushStatusHash();

  @$internal
  @override
  $StreamProviderElement<PushStatus> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<PushStatus> create(Ref ref) {
    return pushStatus(ref);
  }
}

String _$pushStatusHash() => r'406cf2a28628d5e5456758afc961cafb8c938b6e';

/// Subscriptions Gecko has created, keyed by site origin.
///
/// Read-only: Gecko owns subscription state and exposes no revocation channel
/// to the app, so entries disappear only when the site itself unsubscribes or
/// its notification permission is revoked.
///
/// Refetches only when [pushStatusProvider] emits (distributor change, endpoint
/// assigned, registration failure). There is no event for a subscription that is
/// created but still awaiting an endpoint, so such an entry only appears the next
/// time this provider is rebuilt — e.g. when the screen is reopened.

@ProviderFor(pushSubscriptions)
final pushSubscriptionsProvider = PushSubscriptionsProvider._();

/// Subscriptions Gecko has created, keyed by site origin.
///
/// Read-only: Gecko owns subscription state and exposes no revocation channel
/// to the app, so entries disappear only when the site itself unsubscribes or
/// its notification permission is revoked.
///
/// Refetches only when [pushStatusProvider] emits (distributor change, endpoint
/// assigned, registration failure). There is no event for a subscription that is
/// created but still awaiting an endpoint, so such an entry only appears the next
/// time this provider is rebuilt — e.g. when the screen is reopened.

final class PushSubscriptionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PushSubscription>>,
          List<PushSubscription>,
          FutureOr<List<PushSubscription>>
        >
    with
        $FutureModifier<List<PushSubscription>>,
        $FutureProvider<List<PushSubscription>> {
  /// Subscriptions Gecko has created, keyed by site origin.
  ///
  /// Read-only: Gecko owns subscription state and exposes no revocation channel
  /// to the app, so entries disappear only when the site itself unsubscribes or
  /// its notification permission is revoked.
  ///
  /// Refetches only when [pushStatusProvider] emits (distributor change, endpoint
  /// assigned, registration failure). There is no event for a subscription that is
  /// created but still awaiting an endpoint, so such an entry only appears the next
  /// time this provider is rebuilt — e.g. when the screen is reopened.
  PushSubscriptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushSubscriptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushSubscriptionsHash();

  @$internal
  @override
  $FutureProviderElement<List<PushSubscription>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PushSubscription>> create(Ref ref) {
    return pushSubscriptions(ref);
  }
}

String _$pushSubscriptionsHash() => r'bebbaf964fbd48ddf56cf69af4a1d44a74e0f288';

@ProviderFor(PushDistributorMutation)
final pushDistributorMutationProvider = PushDistributorMutationProvider._();

final class PushDistributorMutationProvider
    extends $AsyncNotifierProvider<PushDistributorMutation, void> {
  PushDistributorMutationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushDistributorMutationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushDistributorMutationHash();

  @$internal
  @override
  PushDistributorMutation create() => PushDistributorMutation();
}

String _$pushDistributorMutationHash() =>
    r'5797ca731c90c1e06e089fb71ad602aecda59634';

abstract class _$PushDistributorMutation extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(notificationPermissionService)
final notificationPermissionServiceProvider =
    NotificationPermissionServiceProvider._();

final class NotificationPermissionServiceProvider
    extends
        $FunctionalProvider<
          NotificationPermissionService,
          NotificationPermissionService,
          NotificationPermissionService
        >
    with $Provider<NotificationPermissionService> {
  NotificationPermissionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationPermissionServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationPermissionServiceHash();

  @$internal
  @override
  $ProviderElement<NotificationPermissionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationPermissionService create(Ref ref) {
    return notificationPermissionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationPermissionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationPermissionService>(
        value,
      ),
    );
  }
}

String _$notificationPermissionServiceHash() =>
    r'f6c55f04ace1145f0925adc73c3a13b93a3afea1';

/// Whether the OS-level notification permission is granted. Without it a push
/// message still arrives but Gecko cannot display the resulting notification.

@ProviderFor(notificationPermissionGranted)
final notificationPermissionGrantedProvider =
    NotificationPermissionGrantedProvider._();

/// Whether the OS-level notification permission is granted. Without it a push
/// message still arrives but Gecko cannot display the resulting notification.

final class NotificationPermissionGrantedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether the OS-level notification permission is granted. Without it a push
  /// message still arrives but Gecko cannot display the resulting notification.
  NotificationPermissionGrantedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationPermissionGrantedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationPermissionGrantedHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return notificationPermissionGranted(ref);
  }
}

String _$notificationPermissionGrantedHash() =>
    r'3344fb6996f7577cddb5c1dc24ae262f2724750e';
