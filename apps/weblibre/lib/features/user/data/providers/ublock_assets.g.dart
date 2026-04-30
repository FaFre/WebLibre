// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ublock_assets.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ublockAssetsRegistry)
final ublockAssetsRegistryProvider = UblockAssetsRegistryProvider._();

final class UblockAssetsRegistryProvider
    extends
        $FunctionalProvider<
          AsyncValue<UBlockAssetsRegistry>,
          UBlockAssetsRegistry,
          FutureOr<UBlockAssetsRegistry>
        >
    with
        $FutureModifier<UBlockAssetsRegistry>,
        $FutureProvider<UBlockAssetsRegistry> {
  UblockAssetsRegistryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ublockAssetsRegistryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ublockAssetsRegistryHash();

  @$internal
  @override
  $FutureProviderElement<UBlockAssetsRegistry> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<UBlockAssetsRegistry> create(Ref ref) {
    return ublockAssetsRegistry(ref);
  }
}

String _$ublockAssetsRegistryHash() =>
    r'512d2bf06d16661f5b49b4b4f02840aad5722cd3';
