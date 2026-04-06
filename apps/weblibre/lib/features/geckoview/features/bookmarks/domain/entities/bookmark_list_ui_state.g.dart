// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark_list_ui_state.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BookmarkListUiStateCWProxy {
  BookmarkListUiState selectionMode(bool selectionMode);

  BookmarkListUiState selectedGuids(Set<String> selectedGuids);

  BookmarkListUiState sortType(BookmarkSortType sortType);

  BookmarkListUiState foldersOnly(bool foldersOnly);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `BookmarkListUiState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// BookmarkListUiState(...).copyWith(id: 12, name: "My name")
  /// ```
  BookmarkListUiState call({
    bool selectionMode,
    Set<String> selectedGuids,
    BookmarkSortType sortType,
    bool foldersOnly,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfBookmarkListUiState.copyWith(...)` or call `instanceOfBookmarkListUiState.copyWith.fieldName(value)` for a single field.
class _$BookmarkListUiStateCWProxyImpl implements _$BookmarkListUiStateCWProxy {
  const _$BookmarkListUiStateCWProxyImpl(this._value);

  final BookmarkListUiState _value;

  @override
  BookmarkListUiState selectionMode(bool selectionMode) =>
      call(selectionMode: selectionMode);

  @override
  BookmarkListUiState selectedGuids(Set<String> selectedGuids) =>
      call(selectedGuids: selectedGuids);

  @override
  BookmarkListUiState sortType(BookmarkSortType sortType) =>
      call(sortType: sortType);

  @override
  BookmarkListUiState foldersOnly(bool foldersOnly) =>
      call(foldersOnly: foldersOnly);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `BookmarkListUiState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// BookmarkListUiState(...).copyWith(id: 12, name: "My name")
  /// ```
  BookmarkListUiState call({
    Object? selectionMode = const $CopyWithPlaceholder(),
    Object? selectedGuids = const $CopyWithPlaceholder(),
    Object? sortType = const $CopyWithPlaceholder(),
    Object? foldersOnly = const $CopyWithPlaceholder(),
  }) {
    return BookmarkListUiState(
      selectionMode:
          selectionMode == const $CopyWithPlaceholder() || selectionMode == null
          ? _value.selectionMode
          // ignore: cast_nullable_to_non_nullable
          : selectionMode as bool,
      selectedGuids:
          selectedGuids == const $CopyWithPlaceholder() || selectedGuids == null
          ? _value.selectedGuids
          // ignore: cast_nullable_to_non_nullable
          : selectedGuids as Set<String>,
      sortType: sortType == const $CopyWithPlaceholder() || sortType == null
          ? _value.sortType
          // ignore: cast_nullable_to_non_nullable
          : sortType as BookmarkSortType,
      foldersOnly:
          foldersOnly == const $CopyWithPlaceholder() || foldersOnly == null
          ? _value.foldersOnly
          // ignore: cast_nullable_to_non_nullable
          : foldersOnly as bool,
    );
  }
}

extension $BookmarkListUiStateCopyWith on BookmarkListUiState {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfBookmarkListUiState.copyWith(...)` or `instanceOfBookmarkListUiState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BookmarkListUiStateCWProxy get copyWith =>
      _$BookmarkListUiStateCWProxyImpl(this);
}
