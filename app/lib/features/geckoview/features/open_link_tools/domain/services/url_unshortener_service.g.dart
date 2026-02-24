// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'url_unshortener_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UrlUnshortenerService)
final urlUnshortenerServiceProvider = UrlUnshortenerServiceProvider._();

final class UrlUnshortenerServiceProvider
    extends $AsyncNotifierProvider<UrlUnshortenerService, Set<String>> {
  UrlUnshortenerServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'urlUnshortenerServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$urlUnshortenerServiceHash();

  @$internal
  @override
  UrlUnshortenerService create() => UrlUnshortenerService();
}

String _$urlUnshortenerServiceHash() =>
    r'19dae758ed0c48cb183e3da814d01039548fae40';

abstract class _$UrlUnshortenerService extends $AsyncNotifier<Set<String>> {
  FutureOr<Set<String>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Set<String>>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Set<String>>, Set<String>>,
              AsyncValue<Set<String>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
