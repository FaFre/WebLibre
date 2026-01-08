// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'website_title.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CompletePageInfo)
final completePageInfoProvider = CompletePageInfoFamily._();

final class CompletePageInfoProvider
    extends $NotifierProvider<CompletePageInfo, AsyncValue<WebPageInfo>> {
  CompletePageInfoProvider._({
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

String _$completePageInfoHash() => r'edf5538b913d1ebb285c15ec83644818fe90707d';

final class CompletePageInfoFamily extends $Family
    with
        $ClassFamilyOverride<
          CompletePageInfo,
          AsyncValue<WebPageInfo>,
          AsyncValue<WebPageInfo>,
          AsyncValue<WebPageInfo>,
          TabState
        > {
  CompletePageInfoFamily._()
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
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(pageInfo)
final pageInfoProvider = PageInfoFamily._();

final class PageInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<WebPageInfo>,
          WebPageInfo,
          FutureOr<WebPageInfo>
        >
    with $FutureModifier<WebPageInfo>, $FutureProvider<WebPageInfo> {
  PageInfoProvider._({
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

String _$pageInfoHash() => r'19116a520df214240254f95989818c1ac3bde6f6';

final class PageInfoFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<WebPageInfo>,
          (Uri, {bool isImageRequest})
        > {
  PageInfoFamily._()
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

@ProviderFor(websiteFeedProvider)
final websiteFeedProviderProvider = WebsiteFeedProviderFamily._();

final class WebsiteFeedProviderProvider
    extends
        $FunctionalProvider<
          AsyncValue<EquatableValue<Set<Uri>?>>,
          AsyncValue<EquatableValue<Set<Uri>?>>,
          AsyncValue<EquatableValue<Set<Uri>?>>
        >
    with $Provider<AsyncValue<EquatableValue<Set<Uri>?>>> {
  WebsiteFeedProviderProvider._({
    required WebsiteFeedProviderFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'websiteFeedProviderProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$websiteFeedProviderHash();

  @override
  String toString() {
    return r'websiteFeedProviderProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<EquatableValue<Set<Uri>?>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<EquatableValue<Set<Uri>?>> create(Ref ref) {
    final argument = this.argument as String;
    return websiteFeedProvider(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<EquatableValue<Set<Uri>?>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<AsyncValue<EquatableValue<Set<Uri>?>>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is WebsiteFeedProviderProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$websiteFeedProviderHash() =>
    r'b8ad81b883acee41f420af9aeca254fbd29b3107';

final class WebsiteFeedProviderFamily extends $Family
    with
        $FunctionalFamilyOverride<
          AsyncValue<EquatableValue<Set<Uri>?>>,
          String
        > {
  WebsiteFeedProviderFamily._()
    : super(
        retry: null,
        name: r'websiteFeedProviderProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WebsiteFeedProviderProvider call(String tabId) =>
      WebsiteFeedProviderProvider._(argument: tabId, from: this);

  @override
  String toString() => r'websiteFeedProviderProvider';
}
