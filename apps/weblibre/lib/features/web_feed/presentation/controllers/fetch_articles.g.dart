// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fetch_articles.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FetchArticlesController)
final fetchArticlesControllerProvider = FetchArticlesControllerProvider._();

final class FetchArticlesControllerProvider
    extends $NotifierProvider<FetchArticlesController, AsyncValue<void>> {
  FetchArticlesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fetchArticlesControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fetchArticlesControllerHash();

  @$internal
  @override
  FetchArticlesController create() => FetchArticlesController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$fetchArticlesControllerHash() =>
    r'b8a1813f3497af731f20a48693b700eb3d9aeceb';

abstract class _$FetchArticlesController extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
