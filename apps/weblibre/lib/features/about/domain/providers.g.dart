// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(packageInfo)
final packageInfoProvider = PackageInfoProvider._();

final class PackageInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<PackageInfo>,
          PackageInfo,
          FutureOr<PackageInfo>
        >
    with $FutureModifier<PackageInfo>, $FutureProvider<PackageInfo> {
  PackageInfoProvider._()
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

@ProviderFor(geckoComponentVersions)
final geckoComponentVersionsProvider = GeckoComponentVersionsProvider._();

final class GeckoComponentVersionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<GeckoComponentVersions>,
          GeckoComponentVersions,
          FutureOr<GeckoComponentVersions>
        >
    with
        $FutureModifier<GeckoComponentVersions>,
        $FutureProvider<GeckoComponentVersions> {
  GeckoComponentVersionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: _noRetry,
        name: r'geckoComponentVersionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$geckoComponentVersionsHash();

  @$internal
  @override
  $FutureProviderElement<GeckoComponentVersions> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<GeckoComponentVersions> create(Ref ref) {
    return geckoComponentVersions(ref);
  }
}

String _$geckoComponentVersionsHash() =>
    r'2d9b588604dd2d3a07b7b81851c99da23bdd40d0';

@ProviderFor(torComponentVersions)
final torComponentVersionsProvider = TorComponentVersionsProvider._();

final class TorComponentVersionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<TorComponentVersions>,
          TorComponentVersions,
          FutureOr<TorComponentVersions>
        >
    with
        $FutureModifier<TorComponentVersions>,
        $FutureProvider<TorComponentVersions> {
  TorComponentVersionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: _noRetry,
        name: r'torComponentVersionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$torComponentVersionsHash();

  @$internal
  @override
  $FutureProviderElement<TorComponentVersions> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TorComponentVersions> create(Ref ref) {
    return torComponentVersions(ref);
  }
}

String _$torComponentVersionsHash() =>
    r'7785887244d1a54fd5ea5c0967024ad4089146df';

/// Null when the bundled runtime carries no version stamp.

@ProviderFor(singboxVersion)
final singboxVersionProvider = SingboxVersionProvider._();

/// Null when the bundled runtime carries no version stamp.

final class SingboxVersionProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// Null when the bundled runtime carries no version stamp.
  SingboxVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: _noRetry,
        name: r'singboxVersionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$singboxVersionHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return singboxVersion(ref);
  }
}

String _$singboxVersionHash() => r'4896499c9d0a9520906c4d3213a0b8aba6cfaaf3';
