// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'website_title.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pageInfoHash() => r'dd5644057e4ba7280275105de4788eb4046592d4';

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
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
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

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
