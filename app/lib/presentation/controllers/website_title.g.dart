// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'website_title.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pageInfoHash() => r'53380fbf9c67d494944330641cefbde9455cdb60';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [pageInfo].
@ProviderFor(pageInfo)
const pageInfoProvider = PageInfoFamily();

/// See also [pageInfo].
class PageInfoFamily extends Family<AsyncValue<WebPageInfo>> {
  /// See also [pageInfo].
  const PageInfoFamily();

  /// See also [pageInfo].
  PageInfoProvider call(Uri url, {required bool isImageRequest}) {
    return PageInfoProvider(url, isImageRequest: isImageRequest);
  }

  @override
  PageInfoProvider getProviderOverride(covariant PageInfoProvider provider) {
    return call(provider.url, isImageRequest: provider.isImageRequest);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'pageInfoProvider';
}

/// See also [pageInfo].
class PageInfoProvider extends AutoDisposeFutureProvider<WebPageInfo> {
  /// See also [pageInfo].
  PageInfoProvider(Uri url, {required bool isImageRequest})
    : this._internal(
        (ref) =>
            pageInfo(ref as PageInfoRef, url, isImageRequest: isImageRequest),
        from: pageInfoProvider,
        name: r'pageInfoProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$pageInfoHash,
        dependencies: PageInfoFamily._dependencies,
        allTransitiveDependencies: PageInfoFamily._allTransitiveDependencies,
        url: url,
        isImageRequest: isImageRequest,
      );

  PageInfoProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.url,
    required this.isImageRequest,
  }) : super.internal();

  final Uri url;
  final bool isImageRequest;

  @override
  Override overrideWith(
    FutureOr<WebPageInfo> Function(PageInfoRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PageInfoProvider._internal(
        (ref) => create(ref as PageInfoRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        url: url,
        isImageRequest: isImageRequest,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<WebPageInfo> createElement() {
    return _PageInfoProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PageInfoProvider &&
        other.url == url &&
        other.isImageRequest == isImageRequest;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, url.hashCode);
    hash = _SystemHash.combine(hash, isImageRequest.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PageInfoRef on AutoDisposeFutureProviderRef<WebPageInfo> {
  /// The parameter `url` of this provider.
  Uri get url;

  /// The parameter `isImageRequest` of this provider.
  bool get isImageRequest;
}

class _PageInfoProviderElement
    extends AutoDisposeFutureProviderElement<WebPageInfo>
    with PageInfoRef {
  _PageInfoProviderElement(super.provider);

  @override
  Uri get url => (origin as PageInfoProvider).url;
  @override
  bool get isImageRequest => (origin as PageInfoProvider).isImageRequest;
}

String _$completePageInfoHash() => r'face1bf561e0447a1260515816bac00c2b47fc71';

abstract class _$CompletePageInfo
    extends BuildlessAutoDisposeNotifier<AsyncValue<WebPageInfo>> {
  late final TabState cached;

  AsyncValue<WebPageInfo> build(TabState cached);
}

/// See also [CompletePageInfo].
@ProviderFor(CompletePageInfo)
const completePageInfoProvider = CompletePageInfoFamily();

/// See also [CompletePageInfo].
class CompletePageInfoFamily extends Family<AsyncValue<WebPageInfo>> {
  /// See also [CompletePageInfo].
  const CompletePageInfoFamily();

  /// See also [CompletePageInfo].
  CompletePageInfoProvider call(TabState cached) {
    return CompletePageInfoProvider(cached);
  }

  @override
  CompletePageInfoProvider getProviderOverride(
    covariant CompletePageInfoProvider provider,
  ) {
    return call(provider.cached);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'completePageInfoProvider';
}

/// See also [CompletePageInfo].
class CompletePageInfoProvider
    extends
        AutoDisposeNotifierProviderImpl<
          CompletePageInfo,
          AsyncValue<WebPageInfo>
        > {
  /// See also [CompletePageInfo].
  CompletePageInfoProvider(TabState cached)
    : this._internal(
        () => CompletePageInfo()..cached = cached,
        from: completePageInfoProvider,
        name: r'completePageInfoProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$completePageInfoHash,
        dependencies: CompletePageInfoFamily._dependencies,
        allTransitiveDependencies:
            CompletePageInfoFamily._allTransitiveDependencies,
        cached: cached,
      );

  CompletePageInfoProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.cached,
  }) : super.internal();

  final TabState cached;

  @override
  AsyncValue<WebPageInfo> runNotifierBuild(
    covariant CompletePageInfo notifier,
  ) {
    return notifier.build(cached);
  }

  @override
  Override overrideWith(CompletePageInfo Function() create) {
    return ProviderOverride(
      origin: this,
      override: CompletePageInfoProvider._internal(
        () => create()..cached = cached,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        cached: cached,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<CompletePageInfo, AsyncValue<WebPageInfo>>
  createElement() {
    return _CompletePageInfoProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CompletePageInfoProvider && other.cached == cached;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, cached.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CompletePageInfoRef
    on AutoDisposeNotifierProviderRef<AsyncValue<WebPageInfo>> {
  /// The parameter `cached` of this provider.
  TabState get cached;
}

class _CompletePageInfoProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          CompletePageInfo,
          AsyncValue<WebPageInfo>
        >
    with CompletePageInfoRef {
  _CompletePageInfoProviderElement(super.provider);

  @override
  TabState get cached => (origin as CompletePageInfoProvider).cached;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
