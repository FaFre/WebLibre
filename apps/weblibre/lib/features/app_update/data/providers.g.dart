// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appUpdateHost)
final appUpdateHostProvider = AppUpdateHostProvider._();

final class AppUpdateHostProvider
    extends $FunctionalProvider<AppUpdateHost, AppUpdateHost, AppUpdateHost>
    with $Provider<AppUpdateHost> {
  AppUpdateHostProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appUpdateHostProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appUpdateHostHash();

  @$internal
  @override
  $ProviderElement<AppUpdateHost> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppUpdateHost create(Ref ref) {
    return appUpdateHost(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppUpdateHost value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppUpdateHost>(value),
    );
  }
}

String _$appUpdateHostHash() => r'3faf1ab32dad4fd5ba76debb1f27e95407ad284c';

/// Fixed for the life of the process.

@ProviderFor(installedBuildInfo)
final installedBuildInfoProvider = InstalledBuildInfoProvider._();

/// Fixed for the life of the process.

final class InstalledBuildInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<InstalledBuildInfo>,
          InstalledBuildInfo,
          FutureOr<InstalledBuildInfo>
        >
    with
        $FutureModifier<InstalledBuildInfo>,
        $FutureProvider<InstalledBuildInfo> {
  /// Fixed for the life of the process.
  InstalledBuildInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'installedBuildInfoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$installedBuildInfoHash();

  @$internal
  @override
  $FutureProviderElement<InstalledBuildInfo> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<InstalledBuildInfo> create(Ref ref) {
    return installedBuildInfo(ref);
  }
}

String _$installedBuildInfoHash() =>
    r'2cc7dc2d3b2e02cb3566640506c7a9dccee6603f';

/// Derived once and immutable for the process (3.5). Anything that goes
/// wrong reading the build resolves to no updater: an updater failure never
/// blocks browsing.

@ProviderFor(distributionPolicy)
final distributionPolicyProvider = DistributionPolicyProvider._();

/// Derived once and immutable for the process (3.5). Anything that goes
/// wrong reading the build resolves to no updater: an updater failure never
/// blocks browsing.

final class DistributionPolicyProvider
    extends
        $FunctionalProvider<
          AsyncValue<DistributionPolicy>,
          DistributionPolicy,
          FutureOr<DistributionPolicy>
        >
    with
        $FutureModifier<DistributionPolicy>,
        $FutureProvider<DistributionPolicy> {
  /// Derived once and immutable for the process (3.5). Anything that goes
  /// wrong reading the build resolves to no updater: an updater failure never
  /// blocks browsing.
  DistributionPolicyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'distributionPolicyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$distributionPolicyHash();

  @$internal
  @override
  $FutureProviderElement<DistributionPolicy> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DistributionPolicy> create(Ref ref) {
    return distributionPolicy(ref);
  }
}

String _$distributionPolicyHash() =>
    r'45f631fc070627e03bd8602a9542ea17e4fd1193';

/// The coordinator for this build's distribution, or null when it has no
/// updater. Created on first use, which only happens once a profile is
/// committed (the browser and settings exist only then), so nothing runs
/// during the startup profile picker.

@ProviderFor(appUpdateCoordinator)
final appUpdateCoordinatorProvider = AppUpdateCoordinatorProvider._();

/// The coordinator for this build's distribution, or null when it has no
/// updater. Created on first use, which only happens once a profile is
/// committed (the browser and settings exist only then), so nothing runs
/// during the startup profile picker.

final class AppUpdateCoordinatorProvider
    extends
        $FunctionalProvider<
          AsyncValue<UpdateCoordinator?>,
          UpdateCoordinator?,
          FutureOr<UpdateCoordinator?>
        >
    with
        $FutureModifier<UpdateCoordinator?>,
        $FutureProvider<UpdateCoordinator?> {
  /// The coordinator for this build's distribution, or null when it has no
  /// updater. Created on first use, which only happens once a profile is
  /// committed (the browser and settings exist only then), so nothing runs
  /// during the startup profile picker.
  AppUpdateCoordinatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appUpdateCoordinatorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appUpdateCoordinatorHash();

  @$internal
  @override
  $FutureProviderElement<UpdateCoordinator?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<UpdateCoordinator?> create(Ref ref) {
    return appUpdateCoordinator(ref);
  }
}

String _$appUpdateCoordinatorHash() =>
    r'f96c75054255515b953c3a45da505ced1e2b52d1';
