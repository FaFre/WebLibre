// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark_item.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BookmarkEntryCWProxy {
  BookmarkEntry guid(String guid);

  BookmarkEntry parentGuid(String? parentGuid);

  BookmarkEntry url(Uri url);

  BookmarkEntry title(String title);

  BookmarkEntry previewImageUrl(Uri previewImageUrl);

  BookmarkEntry position(int? position);

  BookmarkEntry dateAdded(int dateAdded);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `BookmarkEntry(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// BookmarkEntry(...).copyWith(id: 12, name: "My name")
  /// ```
  BookmarkEntry call({
    String guid,
    String? parentGuid,
    Uri url,
    String title,
    Uri previewImageUrl,
    int? position,
    int dateAdded,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfBookmarkEntry.copyWith(...)` or call `instanceOfBookmarkEntry.copyWith.fieldName(value)` for a single field.
class _$BookmarkEntryCWProxyImpl implements _$BookmarkEntryCWProxy {
  const _$BookmarkEntryCWProxyImpl(this._value);

  final BookmarkEntry _value;

  @override
  BookmarkEntry guid(String guid) => call(guid: guid);

  @override
  BookmarkEntry parentGuid(String? parentGuid) => call(parentGuid: parentGuid);

  @override
  BookmarkEntry url(Uri url) => call(url: url);

  @override
  BookmarkEntry title(String title) => call(title: title);

  @override
  BookmarkEntry previewImageUrl(Uri previewImageUrl) =>
      call(previewImageUrl: previewImageUrl);

  @override
  BookmarkEntry position(int? position) => call(position: position);

  @override
  BookmarkEntry dateAdded(int dateAdded) => call(dateAdded: dateAdded);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `BookmarkEntry(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// BookmarkEntry(...).copyWith(id: 12, name: "My name")
  /// ```
  BookmarkEntry call({
    Object? guid = const $CopyWithPlaceholder(),
    Object? parentGuid = const $CopyWithPlaceholder(),
    Object? url = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? previewImageUrl = const $CopyWithPlaceholder(),
    Object? position = const $CopyWithPlaceholder(),
    Object? dateAdded = const $CopyWithPlaceholder(),
  }) {
    return BookmarkEntry(
      guid: guid == const $CopyWithPlaceholder() || guid == null
          ? _value.guid
          // ignore: cast_nullable_to_non_nullable
          : guid as String,
      parentGuid: parentGuid == const $CopyWithPlaceholder()
          ? _value.parentGuid
          // ignore: cast_nullable_to_non_nullable
          : parentGuid as String?,
      url: url == const $CopyWithPlaceholder() || url == null
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as Uri,
      title: title == const $CopyWithPlaceholder() || title == null
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      previewImageUrl:
          previewImageUrl == const $CopyWithPlaceholder() ||
              previewImageUrl == null
          ? _value.previewImageUrl
          // ignore: cast_nullable_to_non_nullable
          : previewImageUrl as Uri,
      position: position == const $CopyWithPlaceholder()
          ? _value.position
          // ignore: cast_nullable_to_non_nullable
          : position as int?,
      dateAdded: dateAdded == const $CopyWithPlaceholder() || dateAdded == null
          ? _value.dateAdded
          // ignore: cast_nullable_to_non_nullable
          : dateAdded as int,
    );
  }
}

extension $BookmarkEntryCopyWith on BookmarkEntry {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfBookmarkEntry.copyWith(...)` or `instanceOfBookmarkEntry.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BookmarkEntryCWProxy get copyWith => _$BookmarkEntryCWProxyImpl(this);
}

abstract class _$BookmarkFolderCWProxy {
  BookmarkFolder guid(String guid);

  BookmarkFolder parentGuid(String? parentGuid);

  BookmarkFolder title(String title);

  BookmarkFolder position(int? position);

  BookmarkFolder dateAdded(int dateAdded);

  BookmarkFolder children(List<BookmarkItem>? children);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `BookmarkFolder(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// BookmarkFolder(...).copyWith(id: 12, name: "My name")
  /// ```
  BookmarkFolder call({
    String guid,
    String? parentGuid,
    String title,
    int? position,
    int dateAdded,
    List<BookmarkItem>? children,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfBookmarkFolder.copyWith(...)` or call `instanceOfBookmarkFolder.copyWith.fieldName(value)` for a single field.
class _$BookmarkFolderCWProxyImpl implements _$BookmarkFolderCWProxy {
  const _$BookmarkFolderCWProxyImpl(this._value);

  final BookmarkFolder _value;

  @override
  BookmarkFolder guid(String guid) => call(guid: guid);

  @override
  BookmarkFolder parentGuid(String? parentGuid) => call(parentGuid: parentGuid);

  @override
  BookmarkFolder title(String title) => call(title: title);

  @override
  BookmarkFolder position(int? position) => call(position: position);

  @override
  BookmarkFolder dateAdded(int dateAdded) => call(dateAdded: dateAdded);

  @override
  BookmarkFolder children(List<BookmarkItem>? children) =>
      call(children: children);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `BookmarkFolder(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// BookmarkFolder(...).copyWith(id: 12, name: "My name")
  /// ```
  BookmarkFolder call({
    Object? guid = const $CopyWithPlaceholder(),
    Object? parentGuid = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? position = const $CopyWithPlaceholder(),
    Object? dateAdded = const $CopyWithPlaceholder(),
    Object? children = const $CopyWithPlaceholder(),
  }) {
    return BookmarkFolder(
      guid: guid == const $CopyWithPlaceholder() || guid == null
          ? _value.guid
          // ignore: cast_nullable_to_non_nullable
          : guid as String,
      parentGuid: parentGuid == const $CopyWithPlaceholder()
          ? _value.parentGuid
          // ignore: cast_nullable_to_non_nullable
          : parentGuid as String?,
      title: title == const $CopyWithPlaceholder() || title == null
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      position: position == const $CopyWithPlaceholder()
          ? _value.position
          // ignore: cast_nullable_to_non_nullable
          : position as int?,
      dateAdded: dateAdded == const $CopyWithPlaceholder() || dateAdded == null
          ? _value.dateAdded
          // ignore: cast_nullable_to_non_nullable
          : dateAdded as int,
      children: children == const $CopyWithPlaceholder()
          ? _value.children
          // ignore: cast_nullable_to_non_nullable
          : children as List<BookmarkItem>?,
    );
  }
}

extension $BookmarkFolderCopyWith on BookmarkFolder {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfBookmarkFolder.copyWith(...)` or `instanceOfBookmarkFolder.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BookmarkFolderCWProxy get copyWith => _$BookmarkFolderCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookmarkEntry _$BookmarkEntryFromJson(Map<String, dynamic> json) =>
    BookmarkEntry(
      guid: json['guid'] as String,
      parentGuid: json['parentGuid'] as String?,
      url: Uri.parse(json['url'] as String),
      title: json['title'] as String,
      previewImageUrl: Uri.parse(json['previewImageUrl'] as String),
      position: (json['position'] as num?)?.toInt(),
      dateAdded: (json['dateAdded'] as num).toInt(),
    );

Map<String, dynamic> _$BookmarkEntryToJson(BookmarkEntry instance) =>
    <String, dynamic>{
      'guid': instance.guid,
      'parentGuid': instance.parentGuid,
      'url': instance.url.toString(),
      'title': instance.title,
      'previewImageUrl': instance.previewImageUrl.toString(),
      'position': instance.position,
      'dateAdded': instance.dateAdded,
    };

BookmarkFolder _$BookmarkFolderFromJson(Map<String, dynamic> json) =>
    BookmarkFolder(
      guid: json['guid'] as String,
      parentGuid: json['parentGuid'] as String?,
      title: json['title'] as String,
      position: (json['position'] as num?)?.toInt(),
      dateAdded: (json['dateAdded'] as num).toInt(),
      children: (json['children'] as List<dynamic>?)
          ?.map((e) => BookmarkItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BookmarkFolderToJson(BookmarkFolder instance) =>
    <String, dynamic>{
      'guid': instance.guid,
      'parentGuid': instance.parentGuid,
      'title': instance.title,
      'position': instance.position,
      'dateAdded': instance.dateAdded,
      'children': instance.children?.map((e) => e.toJson()).toList(),
    };
