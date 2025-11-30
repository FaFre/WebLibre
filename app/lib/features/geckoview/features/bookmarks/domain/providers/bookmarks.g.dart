// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmarks.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(bookmarks)
const bookmarksProvider = BookmarksFamily._();

final class BookmarksProvider<T extends BookmarkItem>
    extends $FunctionalProvider<AsyncValue<T?>, AsyncValue<T?>, AsyncValue<T?>>
    with $Provider<AsyncValue<T?>> {
  const BookmarksProvider._({
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
  const BookmarksFamily._()
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
