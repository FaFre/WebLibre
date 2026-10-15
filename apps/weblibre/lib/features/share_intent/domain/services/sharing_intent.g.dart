// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sharing_intent.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Native intent receiver, consumed only by [intentBus]. Sharing and account
/// callback handlers subscribe to [allIntents], not directly to this receiver.

@ProviderFor(intentReceiver)
final intentReceiverProvider = IntentReceiverProvider._();

/// Native intent receiver, consumed only by [intentBus]. Sharing and account
/// callback handlers subscribe to [allIntents], not directly to this receiver.

final class IntentReceiverProvider
    extends
        $FunctionalProvider<
          Raw<IntentReceiver>,
          Raw<IntentReceiver>,
          Raw<IntentReceiver>
        >
    with $Provider<Raw<IntentReceiver>> {
  /// Native intent receiver, consumed only by [intentBus]. Sharing and account
  /// callback handlers subscribe to [allIntents], not directly to this receiver.
  IntentReceiverProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'intentReceiverProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$intentReceiverHash();

  @$internal
  @override
  $ProviderElement<Raw<IntentReceiver>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Raw<IntentReceiver> create(Ref ref) {
    return intentReceiver(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Raw<IntentReceiver> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Raw<IntentReceiver>>(value),
    );
  }
}

String _$intentReceiverHash() => r'61527e0581f56e82a8eec830ad541c8593502df3';

@ProviderFor(intentBus)
final intentBusProvider = IntentBusProvider._();

final class IntentBusProvider
    extends $FunctionalProvider<Raw<IntentBus>, Raw<IntentBus>, Raw<IntentBus>>
    with $Provider<Raw<IntentBus>> {
  IntentBusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'intentBusProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$intentBusHash();

  @$internal
  @override
  $ProviderElement<Raw<IntentBus>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Raw<IntentBus> create(Ref ref) {
    return intentBus(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Raw<IntentBus> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Raw<IntentBus>>(value),
    );
  }
}

String _$intentBusHash() => r'e54020cc2c4d5706191b1218e99b2d16a5149aa8';

/// Every intent this app acts on: the live ones, plus the ones that arrived
/// before it existed.
///
/// The plugin sends a live intent straight to Dart over Pigeon, which works only
/// when something is already listening. During profile selection, maintenance
/// and restart teardown nothing is, and those launches used to vanish without a
/// trace. The native broker holds them instead, and they are replayed into this
/// same stream, so a replayed launch meets exactly the handlers a live one does.
///
/// The broker is not the same thing as the plugin's own hold, and the two do not
/// overlap. The broker takes launches `MainActivity` never passes on, because no
/// profile is committed yet; the plugin holds the ones it *is* given while this
/// isolate has not yet reached [intentReceiver]. Both end up here.

@ProviderFor(allIntents)
final allIntentsProvider = AllIntentsProvider._();

/// Every intent this app acts on: the live ones, plus the ones that arrived
/// before it existed.
///
/// The plugin sends a live intent straight to Dart over Pigeon, which works only
/// when something is already listening. During profile selection, maintenance
/// and restart teardown nothing is, and those launches used to vanish without a
/// trace. The native broker holds them instead, and they are replayed into this
/// same stream, so a replayed launch meets exactly the handlers a live one does.
///
/// The broker is not the same thing as the plugin's own hold, and the two do not
/// overlap. The broker takes launches `MainActivity` never passes on, because no
/// profile is committed yet; the plugin holds the ones it *is* given while this
/// isolate has not yet reached [intentReceiver]. Both end up here.

final class AllIntentsProvider
    extends
        $FunctionalProvider<
          Raw<Stream<Intent>>,
          Raw<Stream<Intent>>,
          Raw<Stream<Intent>>
        >
    with $Provider<Raw<Stream<Intent>>> {
  /// Every intent this app acts on: the live ones, plus the ones that arrived
  /// before it existed.
  ///
  /// The plugin sends a live intent straight to Dart over Pigeon, which works only
  /// when something is already listening. During profile selection, maintenance
  /// and restart teardown nothing is, and those launches used to vanish without a
  /// trace. The native broker holds them instead, and they are replayed into this
  /// same stream, so a replayed launch meets exactly the handlers a live one does.
  ///
  /// The broker is not the same thing as the plugin's own hold, and the two do not
  /// overlap. The broker takes launches `MainActivity` never passes on, because no
  /// profile is committed yet; the plugin holds the ones it *is* given while this
  /// isolate has not yet reached [intentReceiver]. Both end up here.
  AllIntentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allIntentsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allIntentsHash();

  @$internal
  @override
  $ProviderElement<Raw<Stream<Intent>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Raw<Stream<Intent>> create(Ref ref) {
    return allIntents(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Raw<Stream<Intent>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Raw<Stream<Intent>>>(value),
    );
  }
}

String _$allIntentsHash() => r'd31004c83658da57e8b63ce055126bf7b34192e1';

/// Replays the launches the native broker held, once.
///
/// Deliberately not part of [allIntents]. The bus holds native cold-start events
/// until this provider starts delivery, then the broker retires entries as soon as
/// this sink accepts them. Draining as a side effect of building the stream would
/// therefore acknowledge launches before all semantic consumers existed.
///
/// So delivery and the drain are one explicit step, and the caller runs it only
/// after reading every consumer of [allIntents]. Those consumers buffer (see
/// [bufferedIntentStream]), which covers the second half of the problem: the
/// widget that finally acts on a replayed launch mounts later still.

@ProviderFor(brokeredIntentDelivery)
final brokeredIntentDeliveryProvider = BrokeredIntentDeliveryProvider._();

/// Replays the launches the native broker held, once.
///
/// Deliberately not part of [allIntents]. The bus holds native cold-start events
/// until this provider starts delivery, then the broker retires entries as soon as
/// this sink accepts them. Draining as a side effect of building the stream would
/// therefore acknowledge launches before all semantic consumers existed.
///
/// So delivery and the drain are one explicit step, and the caller runs it only
/// after reading every consumer of [allIntents]. Those consumers buffer (see
/// [bufferedIntentStream]), which covers the second half of the problem: the
/// widget that finally acts on a replayed launch mounts later still.

final class BrokeredIntentDeliveryProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Replays the launches the native broker held, once.
  ///
  /// Deliberately not part of [allIntents]. The bus holds native cold-start events
  /// until this provider starts delivery, then the broker retires entries as soon as
  /// this sink accepts them. Draining as a side effect of building the stream would
  /// therefore acknowledge launches before all semantic consumers existed.
  ///
  /// So delivery and the drain are one explicit step, and the caller runs it only
  /// after reading every consumer of [allIntents]. Those consumers buffer (see
  /// [bufferedIntentStream]), which covers the second half of the problem: the
  /// widget that finally acts on a replayed launch mounts later still.
  BrokeredIntentDeliveryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'brokeredIntentDeliveryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$brokeredIntentDeliveryHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return brokeredIntentDelivery(ref);
  }
}

String _$brokeredIntentDeliveryHash() =>
    r'0b1eb748c4001f6f07ae08bf6ae540da4b9d227a';

/// The broker's queue, claimed ahead of its delivery.
///
/// Startup claims it before the router mounts, to know whether a launch is on
/// its way while the profile picker held it (`StartupLaunchCover` in the
/// browser); [brokeredIntentDelivery] takes the same claim later and delivers
/// it. Claimed at most once per delivery: [take] hands the claim over and
/// forgets it, so a later delivery claims afresh rather than replaying.

@ProviderFor(BrokeredLaunchClaim)
final brokeredLaunchClaimProvider = BrokeredLaunchClaimProvider._();

/// The broker's queue, claimed ahead of its delivery.
///
/// Startup claims it before the router mounts, to know whether a launch is on
/// its way while the profile picker held it (`StartupLaunchCover` in the
/// browser); [brokeredIntentDelivery] takes the same claim later and delivers
/// it. Claimed at most once per delivery: [take] hands the claim over and
/// forgets it, so a later delivery claims afresh rather than replaying.
final class BrokeredLaunchClaimProvider
    extends $NotifierProvider<BrokeredLaunchClaim, void> {
  /// The broker's queue, claimed ahead of its delivery.
  ///
  /// Startup claims it before the router mounts, to know whether a launch is on
  /// its way while the profile picker held it (`StartupLaunchCover` in the
  /// browser); [brokeredIntentDelivery] takes the same claim later and delivers
  /// it. Claimed at most once per delivery: [take] hands the claim over and
  /// forgets it, so a later delivery claims afresh rather than replaying.
  BrokeredLaunchClaimProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'brokeredLaunchClaimProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$brokeredLaunchClaimHash();

  @$internal
  @override
  BrokeredLaunchClaim create() => BrokeredLaunchClaim();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$brokeredLaunchClaimHash() =>
    r'be524d1db5d89556395a3a0ef9ec5ed9f390df1c';

/// The broker's queue, claimed ahead of its delivery.
///
/// Startup claims it before the router mounts, to know whether a launch is on
/// its way while the profile picker held it (`StartupLaunchCover` in the
/// browser); [brokeredIntentDelivery] takes the same claim later and delivers
/// it. Claimed at most once per delivery: [take] hands the claim over and
/// forgets it, so a later delivery claims afresh rather than replaying.

abstract class _$BrokeredLaunchClaim extends $Notifier<void> {
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

/// Intents the sharing pipeline let go of without passing anything on: blocked
/// by the gatekeeper, owned by another consumer, carrying nothing to open, or a
/// file of a type the browser does not take.
///
/// For whoever is waiting on a launch to tell when it is not coming, rather
/// than waiting out a timeout. Synchronous, so the news lands in the same turn
/// the pipeline gives up.
///
/// The pipeline adds to the controller; listeners take its stream.

@ProviderFor(unopenedSharingIntents)
final unopenedSharingIntentsProvider = UnopenedSharingIntentsProvider._();

/// Intents the sharing pipeline let go of without passing anything on: blocked
/// by the gatekeeper, owned by another consumer, carrying nothing to open, or a
/// file of a type the browser does not take.
///
/// For whoever is waiting on a launch to tell when it is not coming, rather
/// than waiting out a timeout. Synchronous, so the news lands in the same turn
/// the pipeline gives up.
///
/// The pipeline adds to the controller; listeners take its stream.

final class UnopenedSharingIntentsProvider
    extends
        $FunctionalProvider<
          Raw<StreamController<Intent>>,
          Raw<StreamController<Intent>>,
          Raw<StreamController<Intent>>
        >
    with $Provider<Raw<StreamController<Intent>>> {
  /// Intents the sharing pipeline let go of without passing anything on: blocked
  /// by the gatekeeper, owned by another consumer, carrying nothing to open, or a
  /// file of a type the browser does not take.
  ///
  /// For whoever is waiting on a launch to tell when it is not coming, rather
  /// than waiting out a timeout. Synchronous, so the news lands in the same turn
  /// the pipeline gives up.
  ///
  /// The pipeline adds to the controller; listeners take its stream.
  UnopenedSharingIntentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unopenedSharingIntentsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unopenedSharingIntentsHash();

  @$internal
  @override
  $ProviderElement<Raw<StreamController<Intent>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Raw<StreamController<Intent>> create(Ref ref) {
    return unopenedSharingIntents(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Raw<StreamController<Intent>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Raw<StreamController<Intent>>>(
        value,
      ),
    );
  }
}

String _$unopenedSharingIntentsHash() =>
    r'0406cbe379510442ee26afa182f9c657e0de84b3';

@ProviderFor(sharingIntentStream)
final sharingIntentStreamProvider = SharingIntentStreamProvider._();

final class SharingIntentStreamProvider
    extends
        $FunctionalProvider<
          Raw<Stream<ReceivedIntentParameter>>,
          Raw<Stream<ReceivedIntentParameter>>,
          Raw<Stream<ReceivedIntentParameter>>
        >
    with $Provider<Raw<Stream<ReceivedIntentParameter>>> {
  SharingIntentStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharingIntentStreamProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharingIntentStreamHash();

  @$internal
  @override
  $ProviderElement<Raw<Stream<ReceivedIntentParameter>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Raw<Stream<ReceivedIntentParameter>> create(Ref ref) {
    return sharingIntentStream(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Raw<Stream<ReceivedIntentParameter>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<Raw<Stream<ReceivedIntentParameter>>>(value),
    );
  }
}

String _$sharingIntentStreamHash() =>
    r'912751de09d538bd631520955e7405444e626387';

/// Stream of account callback handoff codes extracted from deep link intents.

@ProviderFor(accountCallbackStream)
final accountCallbackStreamProvider = AccountCallbackStreamProvider._();

/// Stream of account callback handoff codes extracted from deep link intents.

final class AccountCallbackStreamProvider
    extends
        $FunctionalProvider<
          Raw<Stream<AccountCallback>>,
          Raw<Stream<AccountCallback>>,
          Raw<Stream<AccountCallback>>
        >
    with $Provider<Raw<Stream<AccountCallback>>> {
  /// Stream of account callback handoff codes extracted from deep link intents.
  AccountCallbackStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountCallbackStreamProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountCallbackStreamHash();

  @$internal
  @override
  $ProviderElement<Raw<Stream<AccountCallback>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Raw<Stream<AccountCallback>> create(Ref ref) {
    return accountCallbackStream(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Raw<Stream<AccountCallback>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Raw<Stream<AccountCallback>>>(value),
    );
  }
}

String _$accountCallbackStreamHash() =>
    r'f6cf46d135a1fba08ad65f7d18e9ce737094c6e3';
