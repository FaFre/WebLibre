// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'defaults.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(lightSeedColorFallback)
final lightSeedColorFallbackProvider = LightSeedColorFallbackProvider._();

final class LightSeedColorFallbackProvider
    extends $FunctionalProvider<Color, Color, Color>
    with $Provider<Color> {
  LightSeedColorFallbackProvider._()
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
    r'851efdcb11e4367ea2e54f1884a73fd4cd841d4a';

@ProviderFor(darkSeedColorFallback)
final darkSeedColorFallbackProvider = DarkSeedColorFallbackProvider._();

final class DarkSeedColorFallbackProvider
    extends $FunctionalProvider<Color, Color, Color>
    with $Provider<Color> {
  DarkSeedColorFallbackProvider._()
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
    r'161a8c4318108c31d5c300441bc3332d08c24496';

@ProviderFor(docsUri)
final docsUriProvider = DocsUriProvider._();

final class DocsUriProvider extends $FunctionalProvider<Uri, Uri, Uri>
    with $Provider<Uri> {
  DocsUriProvider._()
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
