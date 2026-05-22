// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'handoff_redeem_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(handoffRedeemClient)
final handoffRedeemClientProvider = HandoffRedeemClientProvider._();

final class HandoffRedeemClientProvider
    extends
        $FunctionalProvider<
          HandoffRedeemClient,
          HandoffRedeemClient,
          HandoffRedeemClient
        >
    with $Provider<HandoffRedeemClient> {
  HandoffRedeemClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'handoffRedeemClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$handoffRedeemClientHash();

  @$internal
  @override
  $ProviderElement<HandoffRedeemClient> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HandoffRedeemClient create(Ref ref) {
    return handoffRedeemClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HandoffRedeemClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HandoffRedeemClient>(value),
    );
  }
}

String _$handoffRedeemClientHash() =>
    r'6746d14547090c9ff4fcdc1c554fc7aa3d1e6795';
