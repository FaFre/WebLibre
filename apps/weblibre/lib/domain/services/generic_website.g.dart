// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generic_website.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(faviconResolver)
final faviconResolverProvider = FaviconResolverProvider._();

final class FaviconResolverProvider
    extends
        $FunctionalProvider<FaviconResolver, FaviconResolver, FaviconResolver>
    with $Provider<FaviconResolver> {
  FaviconResolverProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'faviconResolverProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$faviconResolverHash();

  @$internal
  @override
  $ProviderElement<FaviconResolver> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FaviconResolver create(Ref ref) {
    return faviconResolver(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FaviconResolver value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FaviconResolver>(value),
    );
  }
}

String _$faviconResolverHash() => r'3935f8cb31a4cee625de343597e4a486e169f4f9';

@ProviderFor(geckoIconService)
final geckoIconServiceProvider = GeckoIconServiceProvider._();

final class GeckoIconServiceProvider
    extends
        $FunctionalProvider<
          GeckoIconService,
          GeckoIconService,
          GeckoIconService
        >
    with $Provider<GeckoIconService> {
  GeckoIconServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'geckoIconServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$geckoIconServiceHash();

  @$internal
  @override
  $ProviderElement<GeckoIconService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GeckoIconService create(Ref ref) {
    return geckoIconService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GeckoIconService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GeckoIconService>(value),
    );
  }
}

String _$geckoIconServiceHash() => r'e7d2862992c6dfaa031499de06c2d6af04e30fba';

@ProviderFor(GenericWebsiteService)
final genericWebsiteServiceProvider = GenericWebsiteServiceProvider._();

final class GenericWebsiteServiceProvider
    extends $NotifierProvider<GenericWebsiteService, void> {
  GenericWebsiteServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'genericWebsiteServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$genericWebsiteServiceHash();

  @$internal
  @override
  GenericWebsiteService create() => GenericWebsiteService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$genericWebsiteServiceHash() =>
    r'83c62a15492606a7ffe4a7990fc1f9bdbfee87cc';

abstract class _$GenericWebsiteService extends $Notifier<void> {
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
