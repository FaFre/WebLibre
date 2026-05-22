// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capture_artifact_downloader.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(captureArtifactDownloader)
final captureArtifactDownloaderProvider = CaptureArtifactDownloaderProvider._();

final class CaptureArtifactDownloaderProvider
    extends
        $FunctionalProvider<
          CaptureArtifactDownloader,
          CaptureArtifactDownloader,
          CaptureArtifactDownloader
        >
    with $Provider<CaptureArtifactDownloader> {
  CaptureArtifactDownloaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'captureArtifactDownloaderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$captureArtifactDownloaderHash();

  @$internal
  @override
  $ProviderElement<CaptureArtifactDownloader> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CaptureArtifactDownloader create(Ref ref) {
    return captureArtifactDownloader(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CaptureArtifactDownloader value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CaptureArtifactDownloader>(value),
    );
  }
}

String _$captureArtifactDownloaderHash() =>
    r'f746015082a68afc71e2af2e37ac83e3cc856891';
