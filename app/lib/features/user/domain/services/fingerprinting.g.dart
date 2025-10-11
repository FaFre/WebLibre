// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fingerprinting.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(fingerprintTargets)
const fingerprintTargetsProvider = FingerprintTargetsProvider._();

final class FingerprintTargetsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RFPTarget>>,
          List<RFPTarget>,
          FutureOr<List<RFPTarget>>
        >
    with $FutureModifier<List<RFPTarget>>, $FutureProvider<List<RFPTarget>> {
  const FingerprintTargetsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fingerprintTargetsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fingerprintTargetsHash();

  @$internal
  @override
  $FutureProviderElement<List<RFPTarget>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<RFPTarget>> create(Ref ref) {
    return fingerprintTargets(ref);
  }
}

String _$fingerprintTargetsHash() =>
    r'1ec5933a82941b84fdad2130ccf1ba2156ddc33a';
