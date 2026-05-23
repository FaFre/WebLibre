// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sharing_intent.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Shared intent receiver instance. Both the sharing intent stream
/// and the account callback handler listen to its broadcast events.

@ProviderFor(intentReceiver)
final intentReceiverProvider = IntentReceiverProvider._();

/// Shared intent receiver instance. Both the sharing intent stream
/// and the account callback handler listen to its broadcast events.

final class IntentReceiverProvider
    extends
        $FunctionalProvider<
          Raw<IntentReceiver>,
          Raw<IntentReceiver>,
          Raw<IntentReceiver>
        >
    with $Provider<Raw<IntentReceiver>> {
  /// Shared intent receiver instance. Both the sharing intent stream
  /// and the account callback handler listen to its broadcast events.
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
    r'62e9e54bfa168e7400c4c496d0aca0972ccdf4c1';

/// Stream of account callback handoff codes extracted from deep link intents.

@ProviderFor(accountCallbackStream)
final accountCallbackStreamProvider = AccountCallbackStreamProvider._();

/// Stream of account callback handoff codes extracted from deep link intents.

final class AccountCallbackStreamProvider
    extends
        $FunctionalProvider<
          Raw<Stream<String>>,
          Raw<Stream<String>>,
          Raw<Stream<String>>
        >
    with $Provider<Raw<Stream<String>>> {
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
  $ProviderElement<Raw<Stream<String>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Raw<Stream<String>> create(Ref ref) {
    return accountCallbackStream(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Raw<Stream<String>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Raw<Stream<String>>>(value),
    );
  }
}

String _$accountCallbackStreamHash() =>
    r'669354c8000657bcaea046ab6318f89cb10dd7fc';
