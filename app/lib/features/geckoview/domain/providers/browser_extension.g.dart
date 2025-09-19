// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'browser_extension.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(browserExtensionService)
const browserExtensionServiceProvider = BrowserExtensionServiceProvider._();

final class BrowserExtensionServiceProvider
    extends
        $FunctionalProvider<
          GeckoBrowserExtensionService,
          GeckoBrowserExtensionService,
          GeckoBrowserExtensionService
        >
    with $Provider<GeckoBrowserExtensionService> {
  const BrowserExtensionServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'browserExtensionServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$browserExtensionServiceHash();

  @$internal
  @override
  $ProviderElement<GeckoBrowserExtensionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GeckoBrowserExtensionService create(Ref ref) {
    return browserExtensionService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GeckoBrowserExtensionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GeckoBrowserExtensionService>(value),
    );
  }
}

String _$browserExtensionServiceHash() =>
    r'c3f67763e0abb10039b407fced6e175e5ec7c6c3';

@ProviderFor(feedRequested)
const feedRequestedProvider = FeedRequestedProvider._();

final class FeedRequestedProvider
    extends $FunctionalProvider<AsyncValue<String>, String, Stream<String>>
    with $FutureModifier<String>, $StreamProvider<String> {
  const FeedRequestedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedRequestedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedRequestedHash();

  @$internal
  @override
  $StreamProviderElement<String> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<String> create(Ref ref) {
    return feedRequested(ref);
  }
}

String _$feedRequestedHash() => r'4f179d0878072a77a87422ff6afdac53a3d57c04';
