// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_filter.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$FeedFilterCWProxy {
  FeedFilter feedId(Uri? feedId);

  FeedFilter query(String? query);

  FeedFilter tags(Set<String>? tags);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FeedFilter(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FeedFilter(...).copyWith(id: 12, name: "My name")
  /// ````
  FeedFilter call({Uri? feedId, String? query, Set<String>? tags});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfFeedFilter.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfFeedFilter.copyWith.fieldName(...)`
class _$FeedFilterCWProxyImpl implements _$FeedFilterCWProxy {
  const _$FeedFilterCWProxyImpl(this._value);

  final FeedFilter _value;

  @override
  FeedFilter feedId(Uri? feedId) => this(feedId: feedId);

  @override
  FeedFilter query(String? query) => this(query: query);

  @override
  FeedFilter tags(Set<String>? tags) => this(tags: tags);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FeedFilter(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FeedFilter(...).copyWith(id: 12, name: "My name")
  /// ````
  FeedFilter call({
    Object? feedId = const $CopyWithPlaceholder(),
    Object? query = const $CopyWithPlaceholder(),
    Object? tags = const $CopyWithPlaceholder(),
  }) {
    return FeedFilter(
      feedId:
          feedId == const $CopyWithPlaceholder()
              ? _value.feedId
              // ignore: cast_nullable_to_non_nullable
              : feedId as Uri?,
      query:
          query == const $CopyWithPlaceholder()
              ? _value.query
              // ignore: cast_nullable_to_non_nullable
              : query as String?,
      tags:
          tags == const $CopyWithPlaceholder()
              ? _value.tags
              // ignore: cast_nullable_to_non_nullable
              : tags as Set<String>?,
    );
  }
}

extension $FeedFilterCopyWith on FeedFilter {
  /// Returns a callable class that can be used as follows: `instanceOfFeedFilter.copyWith(...)` or like so:`instanceOfFeedFilter.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$FeedFilterCWProxy get copyWith => _$FeedFilterCWProxyImpl(this);
}
