// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'website_title.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CompletePageInfo)
const completePageInfoProvider = CompletePageInfoFamily._();

final class CompletePageInfoProvider
    extends $NotifierProvider<CompletePageInfo, AsyncValue<WebPageInfo>> {
  const CompletePageInfoProvider._({
    required CompletePageInfoFamily super.from,
    required TabState super.argument,
  }) : super(
         retry: null,
         name: r'completePageInfoProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$completePageInfoHash();

  @override
  String toString() {
    return r'completePageInfoProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CompletePageInfo create() => CompletePageInfo();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<WebPageInfo> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<WebPageInfo>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CompletePageInfoProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$completePageInfoHash() => r'e033a1439ee47af5aef0fd6bf3e8a41d5e88c6fe';

final class CompletePageInfoFamily extends $Family
    with
        $ClassFamilyOverride<
          CompletePageInfo,
          AsyncValue<WebPageInfo>,
          AsyncValue<WebPageInfo>,
          AsyncValue<WebPageInfo>,
          TabState
        > {
  const CompletePageInfoFamily._()
    : super(
        retry: null,
        name: r'completePageInfoProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CompletePageInfoProvider call(TabState cached) =>
      CompletePageInfoProvider._(argument: cached, from: this);

  @override
  String toString() => r'completePageInfoProvider';
}

abstract class _$CompletePageInfo extends $Notifier<AsyncValue<WebPageInfo>> {
  late final _$args = ref.$arg as TabState;
  TabState get cached => _$args;

  AsyncValue<WebPageInfo> build(TabState cached);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref as $Ref<AsyncValue<WebPageInfo>, AsyncValue<WebPageInfo>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<WebPageInfo>, AsyncValue<WebPageInfo>>,
              AsyncValue<WebPageInfo>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(pageInfo)
const pageInfoProvider = PageInfoFamily._();

final class PageInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<WebPageInfo>,
          WebPageInfo,
          FutureOr<WebPageInfo>
        >
    with $FutureModifier<WebPageInfo>, $FutureProvider<WebPageInfo> {
  const PageInfoProvider._({
    required PageInfoFamily super.from,
    required (Uri, {bool isImageRequest}) super.argument,
  }) : super(
         retry: null,
         name: r'pageInfoProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pageInfoHash();

  @override
  String toString() {
    return r'pageInfoProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<WebPageInfo> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<WebPageInfo> create(Ref ref) {
    final argument = this.argument as (Uri, {bool isImageRequest});
    return pageInfo(ref, argument.$1, isImageRequest: argument.isImageRequest);
  }

  @override
  bool operator ==(Object other) {
    return other is PageInfoProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pageInfoHash() => r'87d23da9b25c3557e7270d90c2dee6f37eaaf8e0';

final class PageInfoFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<WebPageInfo>,
          (Uri, {bool isImageRequest})
        > {
  const PageInfoFamily._()
    : super(
        retry: null,
        name: r'pageInfoProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PageInfoProvider call(Uri url, {required bool isImageRequest}) =>
      PageInfoProvider._(
        argument: (url, isImageRequest: isImageRequest),
        from: this,
      );

  @override
  String toString() => r'pageInfoProvider';
}
