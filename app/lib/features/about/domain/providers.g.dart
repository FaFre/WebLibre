// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(packageInfo)
const packageInfoProvider = PackageInfoProvider._();

final class PackageInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<PackageInfo>,
          PackageInfo,
          FutureOr<PackageInfo>
        >
    with $FutureModifier<PackageInfo>, $FutureProvider<PackageInfo> {
  const PackageInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'packageInfoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$packageInfoHash();

  @$internal
  @override
  $FutureProviderElement<PackageInfo> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PackageInfo> create(Ref ref) {
    return packageInfo(ref);
  }
}

String _$packageInfoHash() => r'44d37547139567a5f03c1942c1d62ff1abb07248';

@ProviderFor(geckoVersion)
const geckoVersionProvider = GeckoVersionProvider._();

final class GeckoVersionProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  const GeckoVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'geckoVersionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$geckoVersionHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return geckoVersion(ref);
  }
}

String _$geckoVersionHash() => r'1ad2af96ba1999660c208a0095530d901d589228';
