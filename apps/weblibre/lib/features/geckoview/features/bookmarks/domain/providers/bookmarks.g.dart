// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmarks.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BookmarkSearchResults)
final bookmarkSearchResultsProvider = BookmarkSearchResultsProvider._();

final class BookmarkSearchResultsProvider
    extends $NotifierProvider<BookmarkSearchResults, List<BookmarkEntry>> {
  BookmarkSearchResultsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookmarkSearchResultsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookmarkSearchResultsHash();

  @$internal
  @override
  BookmarkSearchResults create() => BookmarkSearchResults();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<BookmarkEntry> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<BookmarkEntry>>(value),
    );
  }
}

String _$bookmarkSearchResultsHash() =>
    r'49ebd21a137bc09bbd67b692aacb2554b8364564';

abstract class _$BookmarkSearchResults extends $Notifier<List<BookmarkEntry>> {
  List<BookmarkEntry> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<BookmarkEntry>, List<BookmarkEntry>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<BookmarkEntry>, List<BookmarkEntry>>,
              List<BookmarkEntry>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// A single folder with its direct children.
///
/// The load is scoped to one folder, so its cost tracks the folder being shown
/// rather than the size of the library. Rebuilds whenever the repository
/// reports a change.

@ProviderFor(bookmarkFolder)
final bookmarkFolderProvider = BookmarkFolderFamily._();

/// A single folder with its direct children.
///
/// The load is scoped to one folder, so its cost tracks the folder being shown
/// rather than the size of the library. Rebuilds whenever the repository
/// reports a change.

final class BookmarkFolderProvider
    extends
        $FunctionalProvider<
          AsyncValue<BookmarkFolder?>,
          BookmarkFolder?,
          FutureOr<BookmarkFolder?>
        >
    with $FutureModifier<BookmarkFolder?>, $FutureProvider<BookmarkFolder?> {
  /// A single folder with its direct children.
  ///
  /// The load is scoped to one folder, so its cost tracks the folder being shown
  /// rather than the size of the library. Rebuilds whenever the repository
  /// reports a change.
  BookmarkFolderProvider._({
    required BookmarkFolderFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'bookmarkFolderProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bookmarkFolderHash();

  @override
  String toString() {
    return r'bookmarkFolderProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<BookmarkFolder?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BookmarkFolder?> create(Ref ref) {
    final argument = this.argument as String;
    return bookmarkFolder(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BookmarkFolderProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookmarkFolderHash() => r'a0a3754a2b8099415cffad6358d9388dc7c4e7bf';

/// A single folder with its direct children.
///
/// The load is scoped to one folder, so its cost tracks the folder being shown
/// rather than the size of the library. Rebuilds whenever the repository
/// reports a change.

final class BookmarkFolderFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<BookmarkFolder?>, String> {
  BookmarkFolderFamily._()
    : super(
        retry: null,
        name: r'bookmarkFolderProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A single folder with its direct children.
  ///
  /// The load is scoped to one folder, so its cost tracks the folder being shown
  /// rather than the size of the library. Rebuilds whenever the repository
  /// reports a change.

  BookmarkFolderProvider call(String guid) =>
      BookmarkFolderProvider._(argument: guid, from: this);

  @override
  String toString() => r'bookmarkFolderProvider';
}

/// The folder shown by the bookmark list, with the roots the user asked to
/// hide already removed.
///
/// Emptiness can only be judged by looking inside each root, but the root level
/// has a fixed handful of children, so the extra loads are bounded and shallow.

@ProviderFor(bookmarkListFolder)
final bookmarkListFolderProvider = BookmarkListFolderFamily._();

/// The folder shown by the bookmark list, with the roots the user asked to
/// hide already removed.
///
/// Emptiness can only be judged by looking inside each root, but the root level
/// has a fixed handful of children, so the extra loads are bounded and shallow.

final class BookmarkListFolderProvider
    extends
        $FunctionalProvider<
          AsyncValue<BookmarkFolder?>,
          BookmarkFolder?,
          FutureOr<BookmarkFolder?>
        >
    with $FutureModifier<BookmarkFolder?>, $FutureProvider<BookmarkFolder?> {
  /// The folder shown by the bookmark list, with the roots the user asked to
  /// hide already removed.
  ///
  /// Emptiness can only be judged by looking inside each root, but the root level
  /// has a fixed handful of children, so the extra loads are bounded and shallow.
  BookmarkListFolderProvider._({
    required BookmarkListFolderFamily super.from,
    required (String, {bool hideEmptyRoots}) super.argument,
  }) : super(
         retry: null,
         name: r'bookmarkListFolderProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bookmarkListFolderHash();

  @override
  String toString() {
    return r'bookmarkListFolderProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<BookmarkFolder?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BookmarkFolder?> create(Ref ref) {
    final argument = this.argument as (String, {bool hideEmptyRoots});
    return bookmarkListFolder(
      ref,
      argument.$1,
      hideEmptyRoots: argument.hideEmptyRoots,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BookmarkListFolderProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookmarkListFolderHash() =>
    r'da6b257ef55b38021a2da7e41209b66a58cfbbb9';

/// The folder shown by the bookmark list, with the roots the user asked to
/// hide already removed.
///
/// Emptiness can only be judged by looking inside each root, but the root level
/// has a fixed handful of children, so the extra loads are bounded and shallow.

final class BookmarkListFolderFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<BookmarkFolder?>,
          (String, {bool hideEmptyRoots})
        > {
  BookmarkListFolderFamily._()
    : super(
        retry: null,
        name: r'bookmarkListFolderProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The folder shown by the bookmark list, with the roots the user asked to
  /// hide already removed.
  ///
  /// Emptiness can only be judged by looking inside each root, but the root level
  /// has a fixed handful of children, so the extra loads are bounded and shallow.

  BookmarkListFolderProvider call(
    String entryGuid, {
    bool hideEmptyRoots = false,
  }) => BookmarkListFolderProvider._(
    argument: (entryGuid, hideEmptyRoots: hideEmptyRoots),
    from: this,
  );

  @override
  String toString() => r'bookmarkListFolderProvider';
}

/// Guids of the bookmarks pointing at [url], or an empty list when there are
/// none.
///
/// Backed by a storage lookup, so "is this page bookmarked?" costs the same
/// whether the user has ten bookmarks or fifty thousand.

@ProviderFor(bookmarkGuidsForUrl)
final bookmarkGuidsForUrlProvider = BookmarkGuidsForUrlFamily._();

/// Guids of the bookmarks pointing at [url], or an empty list when there are
/// none.
///
/// Backed by a storage lookup, so "is this page bookmarked?" costs the same
/// whether the user has ten bookmarks or fifty thousand.

final class BookmarkGuidsForUrlProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// Guids of the bookmarks pointing at [url], or an empty list when there are
  /// none.
  ///
  /// Backed by a storage lookup, so "is this page bookmarked?" costs the same
  /// whether the user has ten bookmarks or fifty thousand.
  BookmarkGuidsForUrlProvider._({
    required BookmarkGuidsForUrlFamily super.from,
    required Uri? super.argument,
  }) : super(
         retry: null,
         name: r'bookmarkGuidsForUrlProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bookmarkGuidsForUrlHash();

  @override
  String toString() {
    return r'bookmarkGuidsForUrlProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    final argument = this.argument as Uri?;
    return bookmarkGuidsForUrl(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BookmarkGuidsForUrlProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookmarkGuidsForUrlHash() =>
    r'aeca791afdcad74c2e8af93c392860ea3cb92b20';

/// Guids of the bookmarks pointing at [url], or an empty list when there are
/// none.
///
/// Backed by a storage lookup, so "is this page bookmarked?" costs the same
/// whether the user has ten bookmarks or fifty thousand.

final class BookmarkGuidsForUrlFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<String>>, Uri?> {
  BookmarkGuidsForUrlFamily._()
    : super(
        retry: null,
        name: r'bookmarkGuidsForUrlProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Guids of the bookmarks pointing at [url], or an empty list when there are
  /// none.
  ///
  /// Backed by a storage lookup, so "is this page bookmarked?" costs the same
  /// whether the user has ten bookmarks or fifty thousand.

  BookmarkGuidsForUrlProvider call(Uri? url) =>
      BookmarkGuidsForUrlProvider._(argument: url, from: this);

  @override
  String toString() => r'bookmarkGuidsForUrlProvider';
}

/// Number of bookmarks inside the trees rooted at [guids].
///
/// Used to tell the user how much a destructive action will affect.

@ProviderFor(bookmarkCountInTrees)
final bookmarkCountInTreesProvider = BookmarkCountInTreesFamily._();

/// Number of bookmarks inside the trees rooted at [guids].
///
/// Used to tell the user how much a destructive action will affect.

final class BookmarkCountInTreesProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Number of bookmarks inside the trees rooted at [guids].
  ///
  /// Used to tell the user how much a destructive action will affect.
  BookmarkCountInTreesProvider._({
    required BookmarkCountInTreesFamily super.from,
    required List<String> super.argument,
  }) : super(
         retry: null,
         name: r'bookmarkCountInTreesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bookmarkCountInTreesHash();

  @override
  String toString() {
    return r'bookmarkCountInTreesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    final argument = this.argument as List<String>;
    return bookmarkCountInTrees(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BookmarkCountInTreesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookmarkCountInTreesHash() =>
    r'efe0cc45e7e77aa542d9ebbd9f4fee5cf9ee5903';

/// Number of bookmarks inside the trees rooted at [guids].
///
/// Used to tell the user how much a destructive action will affect.

final class BookmarkCountInTreesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int>, List<String>> {
  BookmarkCountInTreesFamily._()
    : super(
        retry: null,
        name: r'bookmarkCountInTreesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Number of bookmarks inside the trees rooted at [guids].
  ///
  /// Used to tell the user how much a destructive action will affect.

  BookmarkCountInTreesProvider call(List<String> guids) =>
      BookmarkCountInTreesProvider._(argument: guids, from: this);

  @override
  String toString() => r'bookmarkCountInTreesProvider';
}
