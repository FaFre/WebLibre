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

@ProviderFor(NativeIntentGatekeeperReplicator)
final nativeIntentGatekeeperReplicatorProvider =
    NativeIntentGatekeeperReplicatorProvider._();

/// Mirrors the Flutter-side block list to the native side so the
/// `IntentReceiverActivity` can reject intents without launching Flutter.
/// Only blocked packages are replicated — allow/unknown still fall through to
/// the Flutter gatekeeper dialog.
final class NativeIntentGatekeeperReplicatorProvider
    extends $NotifierProvider<NativeIntentGatekeeperReplicator, void> {
  /// Mirrors the Flutter-side block list to the native side so the
  /// `IntentReceiverActivity` can reject intents without launching Flutter.
  /// Only blocked packages are replicated — allow/unknown still fall through to
  /// the Flutter gatekeeper dialog.
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
    r'ee97dbd489e4e946e0a98cd640300f939f3b0682';

/// Mirrors the Flutter-side block list to the native side so the
/// `IntentReceiverActivity` can reject intents without launching Flutter.
/// Only blocked packages are replicated — allow/unknown still fall through to
/// the Flutter gatekeeper dialog.

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
