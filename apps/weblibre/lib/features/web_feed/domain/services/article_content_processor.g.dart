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
    r'1c71920fb6c685624ea5e4d8e14495fcc7e3c58f';

abstract class _$ArticleContentProcessorService extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
