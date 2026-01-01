// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'readerable.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(readerableService)
final readerableServiceProvider = ReaderableServiceProvider._();

final class ReaderableServiceProvider
    extends
        $FunctionalProvider<
          GeckoReaderableService,
          GeckoReaderableService,
          GeckoReaderableService
        >
    with $Provider<GeckoReaderableService> {
  ReaderableServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readerableServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readerableServiceHash();

  @$internal
  @override
  $ProviderElement<GeckoReaderableService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GeckoReaderableService create(Ref ref) {
    return readerableService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GeckoReaderableService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GeckoReaderableService>(value),
    );
  }
}

String _$readerableServiceHash() => r'0c432ede496d85ed6a7d028af346b129d97f7502';

@ProviderFor(appearanceButtonVisibility)
final appearanceButtonVisibilityProvider =
    AppearanceButtonVisibilityProvider._();

final class AppearanceButtonVisibilityProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  AppearanceButtonVisibilityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appearanceButtonVisibilityProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appearanceButtonVisibilityHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return appearanceButtonVisibility(ref);
  }
}

String _$appearanceButtonVisibilityHash() =>
    r'e7102b63113937dd5d17028a5ec8dac428c38bbb';
