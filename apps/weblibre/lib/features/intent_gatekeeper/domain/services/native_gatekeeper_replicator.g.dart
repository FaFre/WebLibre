// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'native_gatekeeper_replicator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Mirrors the Flutter-side block list to the native side so the
/// `IntentReceiverActivity` can reject intents without launching Flutter.
/// Only blocked packages are replicated — allow/unknown still fall through to
/// the Flutter gatekeeper dialog.
///
/// On startup, also consumes any "always allow" decisions made via notification
/// actions while Flutter was not running, and merges them into Flutter's policy.

@ProviderFor(NativeIntentGatekeeperReplicator)
final nativeIntentGatekeeperReplicatorProvider =
    NativeIntentGatekeeperReplicatorProvider._();

/// Mirrors the Flutter-side block list to the native side so the
/// `IntentReceiverActivity` can reject intents without launching Flutter.
/// Only blocked packages are replicated — allow/unknown still fall through to
/// the Flutter gatekeeper dialog.
///
/// On startup, also consumes any "always allow" decisions made via notification
/// actions while Flutter was not running, and merges them into Flutter's policy.
final class NativeIntentGatekeeperReplicatorProvider
    extends $NotifierProvider<NativeIntentGatekeeperReplicator, void> {
  /// Mirrors the Flutter-side block list to the native side so the
  /// `IntentReceiverActivity` can reject intents without launching Flutter.
  /// Only blocked packages are replicated — allow/unknown still fall through to
  /// the Flutter gatekeeper dialog.
  ///
  /// On startup, also consumes any "always allow" decisions made via notification
  /// actions while Flutter was not running, and merges them into Flutter's policy.
  NativeIntentGatekeeperReplicatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nativeIntentGatekeeperReplicatorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nativeIntentGatekeeperReplicatorHash();

  @$internal
  @override
  NativeIntentGatekeeperReplicator create() =>
      NativeIntentGatekeeperReplicator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$nativeIntentGatekeeperReplicatorHash() =>
    r'ed1ba2a318467317d6fb412495171acb8819e483';

/// Mirrors the Flutter-side block list to the native side so the
/// `IntentReceiverActivity` can reject intents without launching Flutter.
/// Only blocked packages are replicated — allow/unknown still fall through to
/// the Flutter gatekeeper dialog.
///
/// On startup, also consumes any "always allow" decisions made via notification
/// actions while Flutter was not running, and merges them into Flutter's policy.

abstract class _$NativeIntentGatekeeperReplicator extends $Notifier<void> {
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
