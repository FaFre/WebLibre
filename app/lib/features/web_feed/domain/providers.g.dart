// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$feedListHash() => r'0076186437354768c39fb1d7c8bcfcf7b94c7dd1';

/// See also [feedList].
@ProviderFor(feedList)
final feedListProvider = AutoDisposeStreamProvider<List<FeedData>>.internal(
  feedList,
  name: r'feedListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$feedListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FeedListRef = AutoDisposeStreamProviderRef<List<FeedData>>;
String _$feedArticleListHash() => r'64e834a1b69d913f1c860b38956b69af9e89a833';

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

/// See also [feedArticleList].
@ProviderFor(feedArticleList)
const feedArticleListProvider = FeedArticleListFamily();

/// See also [feedArticleList].
class FeedArticleListFamily extends Family<AsyncValue<List<FeedArticle>>> {
  /// See also [feedArticleList].
  const FeedArticleListFamily();

  /// See also [feedArticleList].
  FeedArticleListProvider call(FeedFilter filter) {
    return FeedArticleListProvider(filter);
  }

  @override
  FeedArticleListProvider getProviderOverride(
    covariant FeedArticleListProvider provider,
  ) {
    return call(provider.filter);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'feedArticleListProvider';
}

/// See also [feedArticleList].
class FeedArticleListProvider
    extends AutoDisposeStreamProvider<List<FeedArticle>> {
  /// See also [feedArticleList].
  FeedArticleListProvider(FeedFilter filter)
    : this._internal(
        (ref) => feedArticleList(ref as FeedArticleListRef, filter),
        from: feedArticleListProvider,
        name: r'feedArticleListProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$feedArticleListHash,
        dependencies: FeedArticleListFamily._dependencies,
        allTransitiveDependencies:
            FeedArticleListFamily._allTransitiveDependencies,
        filter: filter,
      );

  FeedArticleListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.filter,
  }) : super.internal();

  final FeedFilter filter;

  @override
  Override overrideWith(
    Stream<List<FeedArticle>> Function(FeedArticleListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FeedArticleListProvider._internal(
        (ref) => create(ref as FeedArticleListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        filter: filter,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<FeedArticle>> createElement() {
    return _FeedArticleListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FeedArticleListProvider && other.filter == filter;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, filter.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FeedArticleListRef on AutoDisposeStreamProviderRef<List<FeedArticle>> {
  /// The parameter `filter` of this provider.
  FeedFilter get filter;
}

class _FeedArticleListProviderElement
    extends AutoDisposeStreamProviderElement<List<FeedArticle>>
    with FeedArticleListRef {
  _FeedArticleListProviderElement(super.provider);

  @override
  FeedFilter get filter => (origin as FeedArticleListProvider).filter;
}

String _$feedArticleHash() => r'b1670f2ce11636f42fc0595befe42ada19319880';

/// See also [feedArticle].
@ProviderFor(feedArticle)
const feedArticleProvider = FeedArticleFamily();

/// See also [feedArticle].
class FeedArticleFamily extends Family<AsyncValue<FeedArticle?>> {
  /// See also [feedArticle].
  const FeedArticleFamily();

  /// See also [feedArticle].
  FeedArticleProvider call(String articleId) {
    return FeedArticleProvider(articleId);
  }

  @override
  FeedArticleProvider getProviderOverride(
    covariant FeedArticleProvider provider,
  ) {
    return call(provider.articleId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'feedArticleProvider';
}

/// See also [feedArticle].
class FeedArticleProvider extends AutoDisposeStreamProvider<FeedArticle?> {
  /// See also [feedArticle].
  FeedArticleProvider(String articleId)
    : this._internal(
        (ref) => feedArticle(ref as FeedArticleRef, articleId),
        from: feedArticleProvider,
        name: r'feedArticleProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$feedArticleHash,
        dependencies: FeedArticleFamily._dependencies,
        allTransitiveDependencies: FeedArticleFamily._allTransitiveDependencies,
        articleId: articleId,
      );

  FeedArticleProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.articleId,
  }) : super.internal();

  final String articleId;

  @override
  Override overrideWith(
    Stream<FeedArticle?> Function(FeedArticleRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FeedArticleProvider._internal(
        (ref) => create(ref as FeedArticleRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        articleId: articleId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<FeedArticle?> createElement() {
    return _FeedArticleProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FeedArticleProvider && other.articleId == articleId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, articleId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FeedArticleRef on AutoDisposeStreamProviderRef<FeedArticle?> {
  /// The parameter `articleId` of this provider.
  String get articleId;
}

class _FeedArticleProviderElement
    extends AutoDisposeStreamProviderElement<FeedArticle?>
    with FeedArticleRef {
  _FeedArticleProviderElement(super.provider);

  @override
  String get articleId => (origin as FeedArticleProvider).articleId;
}

String _$unreadArticleCountHash() =>
    r'6fb96215fb3b7739a6cbd594a0358415ced04fca';

/// See also [_unreadArticleCount].
@ProviderFor(_unreadArticleCount)
final _unreadArticleCountProvider =
    AutoDisposeProvider<Raw<Stream<Map<String, int>>>>.internal(
      _unreadArticleCount,
      name: r'_unreadArticleCountProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$unreadArticleCountHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef _UnreadArticleCountRef =
    AutoDisposeProviderRef<Raw<Stream<Map<String, int>>>>;
String _$unreadFeedArticleCountHash() =>
    r'f8573674477f0d9813b42c82d75e8196c1c1445b';

/// See also [unreadFeedArticleCount].
@ProviderFor(unreadFeedArticleCount)
const unreadFeedArticleCountProvider = UnreadFeedArticleCountFamily();

/// See also [unreadFeedArticleCount].
class UnreadFeedArticleCountFamily extends Family<AsyncValue<int?>> {
  /// See also [unreadFeedArticleCount].
  const UnreadFeedArticleCountFamily();

  /// See also [unreadFeedArticleCount].
  UnreadFeedArticleCountProvider call(Uri feedId) {
    return UnreadFeedArticleCountProvider(feedId);
  }

  @override
  UnreadFeedArticleCountProvider getProviderOverride(
    covariant UnreadFeedArticleCountProvider provider,
  ) {
    return call(provider.feedId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'unreadFeedArticleCountProvider';
}

/// See also [unreadFeedArticleCount].
class UnreadFeedArticleCountProvider extends AutoDisposeStreamProvider<int?> {
  /// See also [unreadFeedArticleCount].
  UnreadFeedArticleCountProvider(Uri feedId)
    : this._internal(
        (ref) =>
            unreadFeedArticleCount(ref as UnreadFeedArticleCountRef, feedId),
        from: unreadFeedArticleCountProvider,
        name: r'unreadFeedArticleCountProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$unreadFeedArticleCountHash,
        dependencies: UnreadFeedArticleCountFamily._dependencies,
        allTransitiveDependencies:
            UnreadFeedArticleCountFamily._allTransitiveDependencies,
        feedId: feedId,
      );

  UnreadFeedArticleCountProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.feedId,
  }) : super.internal();

  final Uri feedId;

  @override
  Override overrideWith(
    Stream<int?> Function(UnreadFeedArticleCountRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UnreadFeedArticleCountProvider._internal(
        (ref) => create(ref as UnreadFeedArticleCountRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        feedId: feedId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<int?> createElement() {
    return _UnreadFeedArticleCountProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UnreadFeedArticleCountProvider && other.feedId == feedId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, feedId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UnreadFeedArticleCountRef on AutoDisposeStreamProviderRef<int?> {
  /// The parameter `feedId` of this provider.
  Uri get feedId;
}

class _UnreadFeedArticleCountProviderElement
    extends AutoDisposeStreamProviderElement<int?>
    with UnreadFeedArticleCountRef {
  _UnreadFeedArticleCountProviderElement(super.provider);

  @override
  Uri get feedId => (origin as UnreadFeedArticleCountProvider).feedId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
