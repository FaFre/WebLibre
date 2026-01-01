// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmarks.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BookmarksSearch)
final bookmarksSearchProvider = BookmarksSearchProvider._();

final class BookmarksSearchProvider
    extends $StreamNotifierProvider<BookmarksSearch, Set<String>> {
  BookmarksSearchProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookmarksSearchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookmarksSearchHash();

  @$internal
  @override
  BookmarksSearch create() => BookmarksSearch();
}

String _$bookmarksSearchHash() => r'ac2ce51c4fd66c2c0e25bdf2475cf2fba57c9e0c';

abstract class _$BookmarksSearch extends $StreamNotifier<Set<String>> {
  Stream<Set<String>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Set<String>>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Set<String>>, Set<String>>,
              AsyncValue<Set<String>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(bookmarks)
final bookmarksProvider = BookmarksFamily._();

final class BookmarksProvider<T extends BookmarkItem>
    extends $FunctionalProvider<AsyncValue<T?>, AsyncValue<T?>, AsyncValue<T?>>
    with $Provider<AsyncValue<T?>> {
  BookmarksProvider._({
    required BookmarksFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'bookmarksProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bookmarksHash();

  @override
  String toString() {
    return r'bookmarksProvider'
        '<${T}>'
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<T?>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AsyncValue<T?> create(Ref ref) {
    final argument = this.argument as String;
    return bookmarks<T>(ref, argument);
  }

  $R _captureGenerics<$R>($R Function<T extends BookmarkItem>() cb) {
    return cb<T>();
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<T?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<T?>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BookmarksProvider &&
        other.runtimeType == runtimeType &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return Object.hash(runtimeType, argument);
  }
}

String _$bookmarksHash() => r'dfa19aea04f352b8a6cefe35a0b283c9fddb214f';

final class BookmarksFamily extends $Family {
  BookmarksFamily._()
    : super(
        retry: null,
        name: r'bookmarksProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BookmarksProvider<T> call<T extends BookmarkItem>(String entryGuid) =>
      BookmarksProvider<T>._(argument: entryGuid, from: this);

  @override
  String toString() => r'bookmarksProvider';

  /// {@macro riverpod.override_with}
  Override overrideWith(
    AsyncValue<T?> Function<T extends BookmarkItem>(Ref ref, String args)
    create,
  ) => $FamilyOverride(
    from: this,
    createElement: (pointer) {
      final provider = pointer.origin as BookmarksProvider;
      return provider._captureGenerics(<T extends BookmarkItem>() {
        provider as BookmarksProvider<T>;
        final argument = provider.argument as String;
        return provider
            .$view(create: (ref) => create(ref, argument))
            .$createElement(pointer);
      });
    },
  );
}

@ProviderFor(SeamlessBookmarks)
final seamlessBookmarksProvider = SeamlessBookmarksFamily._();

final class SeamlessBookmarksProvider
    extends $NotifierProvider<SeamlessBookmarks, AsyncValue<BookmarkItem?>> {
  SeamlessBookmarksProvider._({
    required SeamlessBookmarksFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'seamlessBookmarksProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$seamlessBookmarksHash();

  @override
  String toString() {
    return r'seamlessBookmarksProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SeamlessBookmarks create() => SeamlessBookmarks();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<BookmarkItem?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<BookmarkItem?>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SeamlessBookmarksProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$seamlessBookmarksHash() => r'ddbc51ba22141a2c81bd9cf25adc610e5cdd72d9';

final class SeamlessBookmarksFamily extends $Family
    with
        $ClassFamilyOverride<
          SeamlessBookmarks,
          AsyncValue<BookmarkItem?>,
          AsyncValue<BookmarkItem?>,
          AsyncValue<BookmarkItem?>,
          String
        > {
  SeamlessBookmarksFamily._()
    : super(
        retry: null,
        name: r'seamlessBookmarksProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SeamlessBookmarksProvider call(String entryGuid) =>
      SeamlessBookmarksProvider._(argument: entryGuid, from: this);

  @override
  String toString() => r'seamlessBookmarksProvider';
}

abstract class _$SeamlessBookmarks
    extends $Notifier<AsyncValue<BookmarkItem?>> {
  late final _$args = ref.$arg as String;
  String get entryGuid => _$args;

  AsyncValue<BookmarkItem?> build(String entryGuid);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<BookmarkItem?>, AsyncValue<BookmarkItem?>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<BookmarkItem?>, AsyncValue<BookmarkItem?>>,
              AsyncValue<BookmarkItem?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
