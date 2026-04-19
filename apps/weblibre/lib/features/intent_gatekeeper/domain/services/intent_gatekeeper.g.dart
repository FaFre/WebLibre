// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intent_gatekeeper.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(IntentGatekeeper)
final intentGatekeeperProvider = IntentGatekeeperProvider._();

final class IntentGatekeeperProvider
    extends $StreamNotifierProvider<IntentGatekeeper, PendingIntentDecision> {
  IntentGatekeeperProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'intentGatekeeperProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$intentGatekeeperHash();

  @$internal
  @override
  IntentGatekeeper create() => IntentGatekeeper();
}

String _$intentGatekeeperHash() => r'0ab4a96dde7a21df5dd32d034f841bf4d40dbb10';

abstract class _$IntentGatekeeper
    extends $StreamNotifier<PendingIntentDecision> {
  Stream<PendingIntentDecision> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<PendingIntentDecision>, PendingIntentDecision>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PendingIntentDecision>,
                PendingIntentDecision
              >,
              AsyncValue<PendingIntentDecision>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
