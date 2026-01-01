// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_filter.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ArticleFilter)
final articleFilterProvider = ArticleFilterProvider._();

final class ArticleFilterProvider
    extends $NotifierProvider<ArticleFilter, Set<String>> {
  ArticleFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'articleFilterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$articleFilterHash();

  @$internal
  @override
  ArticleFilter create() => ArticleFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$articleFilterHash() => r'61e4d5230e214038e753bc173158ed1d4dc57040';

abstract class _$ArticleFilter extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
