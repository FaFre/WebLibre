// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark_list_rows.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The bookmark list of [entryGuid] flattened into rows: the entry folder and
/// every folder of [expandedGuids] beneath it, in display order.
///
/// A folder's children are only requested once it is expanded, so a collapsed
/// subtree costs nothing — this is what keeps the list openable after a large
/// import or sync. Expanding starts the load, and the rows follow when it
/// lands; until then the folder has a placeholder row.
///
/// While [enabled] is false (the list shows search hits instead) nothing is
/// loaded or watched, so expanded folders are released until the tree comes
/// back.

@ProviderFor(bookmarkListRows)
final bookmarkListRowsProvider = BookmarkListRowsFamily._();

/// The bookmark list of [entryGuid] flattened into rows: the entry folder and
/// every folder of [expandedGuids] beneath it, in display order.
///
/// A folder's children are only requested once it is expanded, so a collapsed
/// subtree costs nothing — this is what keeps the list openable after a large
/// import or sync. Expanding starts the load, and the rows follow when it
/// lands; until then the folder has a placeholder row.
///
/// While [enabled] is false (the list shows search hits instead) nothing is
/// loaded or watched, so expanded folders are released until the tree comes
/// back.

final class BookmarkListRowsProvider
    extends
        $FunctionalProvider<
          List<BookmarkRow>,
          List<BookmarkRow>,
          List<BookmarkRow>
        >
    with $Provider<List<BookmarkRow>> {
  /// The bookmark list of [entryGuid] flattened into rows: the entry folder and
  /// every folder of [expandedGuids] beneath it, in display order.
  ///
  /// A folder's children are only requested once it is expanded, so a collapsed
  /// subtree costs nothing — this is what keeps the list openable after a large
  /// import or sync. Expanding starts the load, and the rows follow when it
  /// lands; until then the folder has a placeholder row.
  ///
  /// While [enabled] is false (the list shows search hits instead) nothing is
  /// loaded or watched, so expanded folders are released until the tree comes
  /// back.
  BookmarkListRowsProvider._({
    required BookmarkListRowsFamily super.from,
    required (
      String, {
      bool hideEmptyRoots,
      EquatableValue<Set<String>> expandedGuids,
      bool enabled,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'bookmarkListRowsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bookmarkListRowsHash();

  @override
  String toString() {
    return r'bookmarkListRowsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<List<BookmarkRow>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<BookmarkRow> create(Ref ref) {
    final argument =
        this.argument
            as (
              String, {
              bool hideEmptyRoots,
              EquatableValue<Set<String>> expandedGuids,
              bool enabled,
            });
    return bookmarkListRows(
      ref,
      argument.$1,
      hideEmptyRoots: argument.hideEmptyRoots,
      expandedGuids: argument.expandedGuids,
      enabled: argument.enabled,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<BookmarkRow> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<BookmarkRow>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BookmarkListRowsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookmarkListRowsHash() => r'5e9a74ddfa56b8b8ab5796ee305f03bca82037b4';

/// The bookmark list of [entryGuid] flattened into rows: the entry folder and
/// every folder of [expandedGuids] beneath it, in display order.
///
/// A folder's children are only requested once it is expanded, so a collapsed
/// subtree costs nothing — this is what keeps the list openable after a large
/// import or sync. Expanding starts the load, and the rows follow when it
/// lands; until then the folder has a placeholder row.
///
/// While [enabled] is false (the list shows search hits instead) nothing is
/// loaded or watched, so expanded folders are released until the tree comes
/// back.

final class BookmarkListRowsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          List<BookmarkRow>,
          (
            String, {
            bool hideEmptyRoots,
            EquatableValue<Set<String>> expandedGuids,
            bool enabled,
          })
        > {
  BookmarkListRowsFamily._()
    : super(
        retry: null,
        name: r'bookmarkListRowsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The bookmark list of [entryGuid] flattened into rows: the entry folder and
  /// every folder of [expandedGuids] beneath it, in display order.
  ///
  /// A folder's children are only requested once it is expanded, so a collapsed
  /// subtree costs nothing — this is what keeps the list openable after a large
  /// import or sync. Expanding starts the load, and the rows follow when it
  /// lands; until then the folder has a placeholder row.
  ///
  /// While [enabled] is false (the list shows search hits instead) nothing is
  /// loaded or watched, so expanded folders are released until the tree comes
  /// back.

  BookmarkListRowsProvider call(
    String entryGuid, {
    required bool hideEmptyRoots,
    required EquatableValue<Set<String>> expandedGuids,
    required bool enabled,
  }) => BookmarkListRowsProvider._(
    argument: (
      entryGuid,
      hideEmptyRoots: hideEmptyRoots,
      expandedGuids: expandedGuids,
      enabled: enabled,
    ),
    from: this,
  );

  @override
  String toString() => r'bookmarkListRowsProvider';
}
