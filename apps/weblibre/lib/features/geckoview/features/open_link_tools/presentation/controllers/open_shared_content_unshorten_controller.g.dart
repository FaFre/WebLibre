// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'open_shared_content_unshorten_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OpenSharedContentUnshortenController)
final openSharedContentUnshortenControllerProvider =
    OpenSharedContentUnshortenControllerProvider._();

final class OpenSharedContentUnshortenControllerProvider
    extends
        $NotifierProvider<
          OpenSharedContentUnshortenController,
          AsyncValue<UnshortenResult>?
        > {
  OpenSharedContentUnshortenControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'openSharedContentUnshortenControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$openSharedContentUnshortenControllerHash();

  @$internal
  @override
  OpenSharedContentUnshortenController create() =>
      OpenSharedContentUnshortenController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<UnshortenResult>? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<UnshortenResult>?>(value),
    );
  }
}

String _$openSharedContentUnshortenControllerHash() =>
    r'f94bb6f343a8fdb1f122128225f2752fadb259c2';

abstract class _$OpenSharedContentUnshortenController
    extends $Notifier<AsyncValue<UnshortenResult>?> {
  AsyncValue<UnshortenResult>? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<UnshortenResult>?, AsyncValue<UnshortenResult>?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<UnshortenResult>?,
                AsyncValue<UnshortenResult>?
              >,
              AsyncValue<UnshortenResult>?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
