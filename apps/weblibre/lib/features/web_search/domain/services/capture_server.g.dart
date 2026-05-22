// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capture_server.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(captureServer)
final captureServerProvider = CaptureServerProvider._();

final class CaptureServerProvider
    extends $FunctionalProvider<CaptureServer, CaptureServer, CaptureServer>
    with $Provider<CaptureServer> {
  CaptureServerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'captureServerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$captureServerHash();

  @$internal
  @override
  $ProviderElement<CaptureServer> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CaptureServer create(Ref ref) {
    return captureServer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CaptureServer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CaptureServer>(value),
    );
  }
}

String _$captureServerHash() => r'ddbb9eff1b3d622a44a5ae9523e2f96a37b075fb';
