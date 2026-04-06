// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_content_processor.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ArticleContentProcessorService)
final articleContentProcessorServiceProvider =
    ArticleContentProcessorServiceProvider._();

final class ArticleContentProcessorServiceProvider
    extends $NotifierProvider<ArticleContentProcessorService, void> {
  ArticleContentProcessorServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'articleContentProcessorServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$articleContentProcessorServiceHash();

  @$internal
  @override
  ArticleContentProcessorService create() => ArticleContentProcessorService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$articleContentProcessorServiceHash() =>
    r'e7cc3da71f6dcf39b0c10df4dcd061f816d5c12e';

abstract class _$ArticleContentProcessorService extends $Notifier<void> {
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
