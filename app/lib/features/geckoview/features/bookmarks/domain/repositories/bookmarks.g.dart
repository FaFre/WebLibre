// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmarks.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BookmarksRepository)
const bookmarksRepositoryProvider = BookmarksRepositoryProvider._();

final class BookmarksRepositoryProvider
    extends $AsyncNotifierProvider<BookmarksRepository, BookmarkItem?> {
  const BookmarksRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookmarksRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookmarksRepositoryHash();

  @$internal
  @override
  BookmarksRepository create() => BookmarksRepository();
}

String _$bookmarksRepositoryHash() =>
    r'b8fa5b5699c053b91fcabd46dc97b7192e32d068';

abstract class _$BookmarksRepository extends $AsyncNotifier<BookmarkItem?> {
  FutureOr<BookmarkItem?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<BookmarkItem?>, BookmarkItem?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<BookmarkItem?>, BookmarkItem?>,
              AsyncValue<BookmarkItem?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
