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
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$feedListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FeedListRef = AutoDisposeStreamProviderRef<List<FeedData>>;
String _$feedDataHash() => r'0599a2e3d159ef3abb6c3d2c871f87da2f5e646b';

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

/// See also [feedData].
@ProviderFor(feedData)
const feedDataProvider = FeedDataFamily();

/// See also [feedData].
class FeedDataFamily extends Family<AsyncValue<FeedData?>> {
  /// See also [feedData].
  const FeedDataFamily();

  /// See also [feedData].
  FeedDataProvider call(Uri? feedId) {
    return FeedDataProvider(feedId);
  }

  @override
  FeedDataProvider getProviderOverride(covariant FeedDataProvider provider) {
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
  String? get name => r'feedDataProvider';
}

/// See also [feedData].
class FeedDataProvider extends AutoDisposeStreamProvider<FeedData?> {
  /// See also [feedData].
  FeedDataProvider(Uri? feedId)
    : this._internal(
        (ref) => feedData(ref as FeedDataRef, feedId),
        from: feedDataProvider,
        name: r'feedDataProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$feedDataHash,
        dependencies: FeedDataFamily._dependencies,
        allTransitiveDependencies: FeedDataFamily._allTransitiveDependencies,
        feedId: feedId,
      );

  FeedDataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.feedId,
  }) : super.internal();

  final Uri? feedId;

  @override
  Override overrideWith(
    Stream<FeedData?> Function(FeedDataRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FeedDataProvider._internal(
        (ref) => create(ref as FeedDataRef),
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
  AutoDisposeStreamProviderElement<FeedData?> createElement() {
    return _FeedDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FeedDataProvider && other.feedId == feedId;
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
mixin FeedDataRef on AutoDisposeStreamProviderRef<FeedData?> {
  /// The parameter `feedId` of this provider.
  Uri? get feedId;
}

class _FeedDataProviderElement
    extends AutoDisposeStreamProviderElement<FeedData?>
    with FeedDataRef {
  _FeedDataProviderElement(super.provider);

  @override
  Uri? get feedId => (origin as FeedDataProvider).feedId;
}

String _$feedArticleListHash() => r'45d585cc9f59ad48a0d1d6fbcf802b1c7de7f6bc';

/// See also [feedArticleList].
@ProviderFor(feedArticleList)
const feedArticleListProvider = FeedArticleListFamily();

/// See also [feedArticleList].
class FeedArticleListFamily extends Family<AsyncValue<List<FeedArticle>>> {
  /// See also [feedArticleList].
  const FeedArticleListFamily();

  /// See also [feedArticleList].
  FeedArticleListProvider call(Uri? feedId) {
    return FeedArticleListProvider(feedId);
  }

  @override
  FeedArticleListProvider getProviderOverride(
    covariant FeedArticleListProvider provider,
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
  String? get name => r'feedArticleListProvider';
}

/// See also [feedArticleList].
class FeedArticleListProvider
    extends AutoDisposeStreamProvider<List<FeedArticle>> {
  /// See also [feedArticleList].
  FeedArticleListProvider(Uri? feedId)
    : this._internal(
        (ref) => feedArticleList(ref as FeedArticleListRef, feedId),
        from: feedArticleListProvider,
        name: r'feedArticleListProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$feedArticleListHash,
        dependencies: FeedArticleListFamily._dependencies,
        allTransitiveDependencies:
            FeedArticleListFamily._allTransitiveDependencies,
        feedId: feedId,
      );

  FeedArticleListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.feedId,
  }) : super.internal();

  final Uri? feedId;

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
        feedId: feedId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<FeedArticle>> createElement() {
    return _FeedArticleListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FeedArticleListProvider && other.feedId == feedId;
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
mixin FeedArticleListRef on AutoDisposeStreamProviderRef<List<FeedArticle>> {
  /// The parameter `feedId` of this provider.
  Uri? get feedId;
}

class _FeedArticleListProviderElement
    extends AutoDisposeStreamProviderElement<List<FeedArticle>>
    with FeedArticleListRef {
  _FeedArticleListProviderElement(super.provider);

  @override
  Uri? get feedId => (origin as FeedArticleListProvider).feedId;
}

String _$feedArticleHash() => r'18b5faf391867b95f4b3bc4f74a6083854b633a5';

/// See also [feedArticle].
@ProviderFor(feedArticle)
const feedArticleProvider = FeedArticleFamily();

/// See also [feedArticle].
class FeedArticleFamily extends Family<AsyncValue<FeedArticle?>> {
  /// See also [feedArticle].
  const FeedArticleFamily();

  /// See also [feedArticle].
  FeedArticleProvider call(String articleId, {required bool updateReadDate}) {
    return FeedArticleProvider(articleId, updateReadDate: updateReadDate);
  }

  @override
  FeedArticleProvider getProviderOverride(
    covariant FeedArticleProvider provider,
  ) {
    return call(provider.articleId, updateReadDate: provider.updateReadDate);
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
  FeedArticleProvider(String articleId, {required bool updateReadDate})
    : this._internal(
        (ref) => feedArticle(
          ref as FeedArticleRef,
          articleId,
          updateReadDate: updateReadDate,
        ),
        from: feedArticleProvider,
        name: r'feedArticleProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$feedArticleHash,
        dependencies: FeedArticleFamily._dependencies,
        allTransitiveDependencies: FeedArticleFamily._allTransitiveDependencies,
        articleId: articleId,
        updateReadDate: updateReadDate,
      );

  FeedArticleProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.articleId,
    required this.updateReadDate,
  }) : super.internal();

  final String articleId;
  final bool updateReadDate;

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
        updateReadDate: updateReadDate,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<FeedArticle?> createElement() {
    return _FeedArticleProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FeedArticleProvider &&
        other.articleId == articleId &&
        other.updateReadDate == updateReadDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, articleId.hashCode);
    hash = _SystemHash.combine(hash, updateReadDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FeedArticleRef on AutoDisposeStreamProviderRef<FeedArticle?> {
  /// The parameter `articleId` of this provider.
  String get articleId;

  /// The parameter `updateReadDate` of this provider.
  bool get updateReadDate;
}

class _FeedArticleProviderElement
    extends AutoDisposeStreamProviderElement<FeedArticle?>
    with FeedArticleRef {
  _FeedArticleProviderElement(super.provider);

  @override
  String get articleId => (origin as FeedArticleProvider).articleId;
  @override
  bool get updateReadDate => (origin as FeedArticleProvider).updateReadDate;
}

String _$unreadArticleCountHash() =>
    r'709518ad229636df0f1095f47e3a6d116b3aa7e6';

/// See also [unreadArticleCount].
@ProviderFor(unreadArticleCount)
final unreadArticleCountProvider =
    AutoDisposeProvider<Raw<Stream<Map<String, int>>>>.internal(
      unreadArticleCount,
      name: r'unreadArticleCountProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$unreadArticleCountHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UnreadArticleCountRef =
    AutoDisposeProviderRef<Raw<Stream<Map<String, int>>>>;
String _$unreadFeedArticleCountHash() =>
    r'5e0d8e58b3d1dec978dc07b22367f2cb037b1b15';

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
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
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

String _$fetchWebFeedHash() => r'73bdf87ad7dbd039c7dc181d80acdf99d96fe1c6';

/// See also [fetchWebFeed].
@ProviderFor(fetchWebFeed)
const fetchWebFeedProvider = FetchWebFeedFamily();

/// See also [fetchWebFeed].
class FetchWebFeedFamily extends Family<AsyncValue<FeedParseResult>> {
  /// See also [fetchWebFeed].
  const FetchWebFeedFamily();

  /// See also [fetchWebFeed].
  FetchWebFeedProvider call(Uri url) {
    return FetchWebFeedProvider(url);
  }

  @override
  FetchWebFeedProvider getProviderOverride(
    covariant FetchWebFeedProvider provider,
  ) {
    return call(provider.url);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'fetchWebFeedProvider';
}

/// See also [fetchWebFeed].
class FetchWebFeedProvider extends AutoDisposeFutureProvider<FeedParseResult> {
  /// See also [fetchWebFeed].
  FetchWebFeedProvider(Uri url)
    : this._internal(
        (ref) => fetchWebFeed(ref as FetchWebFeedRef, url),
        from: fetchWebFeedProvider,
        name: r'fetchWebFeedProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$fetchWebFeedHash,
        dependencies: FetchWebFeedFamily._dependencies,
        allTransitiveDependencies:
            FetchWebFeedFamily._allTransitiveDependencies,
        url: url,
      );

  FetchWebFeedProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.url,
  }) : super.internal();

  final Uri url;

  @override
  Override overrideWith(
    FutureOr<FeedParseResult> Function(FetchWebFeedRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FetchWebFeedProvider._internal(
        (ref) => create(ref as FetchWebFeedRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        url: url,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<FeedParseResult> createElement() {
    return _FetchWebFeedProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchWebFeedProvider && other.url == url;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, url.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FetchWebFeedRef on AutoDisposeFutureProviderRef<FeedParseResult> {
  /// The parameter `url` of this provider.
  Uri get url;
}

class _FetchWebFeedProviderElement
    extends AutoDisposeFutureProviderElement<FeedParseResult>
    with FetchWebFeedRef {
  _FetchWebFeedProviderElement(super.provider);

  @override
  Uri get url => (origin as FetchWebFeedProvider).url;
}

String _$articleSearchHash() => r'cc59a5d3c4b926db9f03ed96db592965ff925b04';

abstract class _$ArticleSearch
    extends BuildlessAutoDisposeStreamNotifier<List<FeedArticle>> {
  late final Uri? feedId;

  Stream<List<FeedArticle>> build(Uri? feedId);
}

/// See also [ArticleSearch].
@ProviderFor(ArticleSearch)
const articleSearchProvider = ArticleSearchFamily();

/// See also [ArticleSearch].
class ArticleSearchFamily extends Family<AsyncValue<List<FeedArticle>>> {
  /// See also [ArticleSearch].
  const ArticleSearchFamily();

  /// See also [ArticleSearch].
  ArticleSearchProvider call(Uri? feedId) {
    return ArticleSearchProvider(feedId);
  }

  @override
  ArticleSearchProvider getProviderOverride(
    covariant ArticleSearchProvider provider,
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
  String? get name => r'articleSearchProvider';
}

/// See also [ArticleSearch].
class ArticleSearchProvider
    extends
        AutoDisposeStreamNotifierProviderImpl<
          ArticleSearch,
          List<FeedArticle>
        > {
  /// See also [ArticleSearch].
  ArticleSearchProvider(Uri? feedId)
    : this._internal(
        () => ArticleSearch()..feedId = feedId,
        from: articleSearchProvider,
        name: r'articleSearchProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$articleSearchHash,
        dependencies: ArticleSearchFamily._dependencies,
        allTransitiveDependencies:
            ArticleSearchFamily._allTransitiveDependencies,
        feedId: feedId,
      );

  ArticleSearchProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.feedId,
  }) : super.internal();

  final Uri? feedId;

  @override
  Stream<List<FeedArticle>> runNotifierBuild(covariant ArticleSearch notifier) {
    return notifier.build(feedId);
  }

  @override
  Override overrideWith(ArticleSearch Function() create) {
    return ProviderOverride(
      origin: this,
      override: ArticleSearchProvider._internal(
        () => create()..feedId = feedId,
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
  AutoDisposeStreamNotifierProviderElement<ArticleSearch, List<FeedArticle>>
  createElement() {
    return _ArticleSearchProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ArticleSearchProvider && other.feedId == feedId;
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
mixin ArticleSearchRef
    on AutoDisposeStreamNotifierProviderRef<List<FeedArticle>> {
  /// The parameter `feedId` of this provider.
  Uri? get feedId;
}

class _ArticleSearchProviderElement
    extends
        AutoDisposeStreamNotifierProviderElement<
          ArticleSearch,
          List<FeedArticle>
        >
    with ArticleSearchRef {
  _ArticleSearchProviderElement(super.provider);

  @override
  Uri? get feedId => (origin as ArticleSearchProvider).feedId;
}

String _$filteredArticleListHash() =>
    r'a691c3c6aa722dd85ee4980e6c48721a8025f1d8';

abstract class _$FilteredArticleList
    extends BuildlessAutoDisposeNotifier<AsyncValue<List<FeedArticle>>> {
  late final Uri? feedId;

  AsyncValue<List<FeedArticle>> build(Uri? feedId);
}

/// See also [FilteredArticleList].
@ProviderFor(FilteredArticleList)
const filteredArticleListProvider = FilteredArticleListFamily();

/// See also [FilteredArticleList].
class FilteredArticleListFamily extends Family<AsyncValue<List<FeedArticle>>> {
  /// See also [FilteredArticleList].
  const FilteredArticleListFamily();

  /// See also [FilteredArticleList].
  FilteredArticleListProvider call(Uri? feedId) {
    return FilteredArticleListProvider(feedId);
  }

  @override
  FilteredArticleListProvider getProviderOverride(
    covariant FilteredArticleListProvider provider,
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
  String? get name => r'filteredArticleListProvider';
}

/// See also [FilteredArticleList].
class FilteredArticleListProvider
    extends
        AutoDisposeNotifierProviderImpl<
          FilteredArticleList,
          AsyncValue<List<FeedArticle>>
        > {
  /// See also [FilteredArticleList].
  FilteredArticleListProvider(Uri? feedId)
    : this._internal(
        () => FilteredArticleList()..feedId = feedId,
        from: filteredArticleListProvider,
        name: r'filteredArticleListProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$filteredArticleListHash,
        dependencies: FilteredArticleListFamily._dependencies,
        allTransitiveDependencies:
            FilteredArticleListFamily._allTransitiveDependencies,
        feedId: feedId,
      );

  FilteredArticleListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.feedId,
  }) : super.internal();

  final Uri? feedId;

  @override
  AsyncValue<List<FeedArticle>> runNotifierBuild(
    covariant FilteredArticleList notifier,
  ) {
    return notifier.build(feedId);
  }

  @override
  Override overrideWith(FilteredArticleList Function() create) {
    return ProviderOverride(
      origin: this,
      override: FilteredArticleListProvider._internal(
        () => create()..feedId = feedId,
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
  AutoDisposeNotifierProviderElement<
    FilteredArticleList,
    AsyncValue<List<FeedArticle>>
  >
  createElement() {
    return _FilteredArticleListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredArticleListProvider && other.feedId == feedId;
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
mixin FilteredArticleListRef
    on AutoDisposeNotifierProviderRef<AsyncValue<List<FeedArticle>>> {
  /// The parameter `feedId` of this provider.
  Uri? get feedId;
}

class _FilteredArticleListProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          FilteredArticleList,
          AsyncValue<List<FeedArticle>>
        >
    with FilteredArticleListRef {
  _FilteredArticleListProviderElement(super.provider);

  @override
  Uri? get feedId => (origin as FilteredArticleListProvider).feedId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
