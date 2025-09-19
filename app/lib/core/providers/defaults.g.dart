// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'defaults.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(lightSeedColorFallback)
const lightSeedColorFallbackProvider = LightSeedColorFallbackProvider._();

final class LightSeedColorFallbackProvider
    extends $FunctionalProvider<Color, Color, Color>
    with $Provider<Color> {
  const LightSeedColorFallbackProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lightSeedColorFallbackProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lightSeedColorFallbackHash();

  @$internal
  @override
  $ProviderElement<Color> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Color create(Ref ref) {
    return lightSeedColorFallback(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Color value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Color>(value),
    );
  }
}

String _$lightSeedColorFallbackHash() =>
    r'af151d3293d372f5df451aa8c3a75136377b6ce1';

@ProviderFor(darkSeedColorFallback)
const darkSeedColorFallbackProvider = DarkSeedColorFallbackProvider._();

final class DarkSeedColorFallbackProvider
    extends $FunctionalProvider<Color, Color, Color>
    with $Provider<Color> {
  const DarkSeedColorFallbackProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'darkSeedColorFallbackProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$darkSeedColorFallbackHash();

  @$internal
  @override
  $ProviderElement<Color> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Color create(Ref ref) {
    return darkSeedColorFallback(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Color value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Color>(value),
    );
  }
}

String _$darkSeedColorFallbackHash() =>
    r'9418cf71e3d80c8a2142e0d3a8820989b29bff86';

@ProviderFor(docsUri)
const docsUriProvider = DocsUriProvider._();

final class DocsUriProvider extends $FunctionalProvider<Uri, Uri, Uri>
    with $Provider<Uri> {
  const DocsUriProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'docsUriProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$docsUriHash();

  @$internal
  @override
  $ProviderElement<Uri> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Uri create(Ref ref) {
    return docsUri(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Uri value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Uri>(value),
    );
  }
}

String _$docsUriHash() => r'6456efcf97ddc7ee87a67e2d3380f7241e3d76ea';
