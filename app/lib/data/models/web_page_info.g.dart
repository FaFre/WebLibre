// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_page_info.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WebPageInfoCWProxy {
  WebPageInfo url(Uri url);

  WebPageInfo title(String? title);

  WebPageInfo favicon(BrowserIcon? favicon);

  WebPageInfo feeds(Set<Uri>? feeds);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `WebPageInfo(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// WebPageInfo(...).copyWith(id: 12, name: "My name")
  /// ```
  WebPageInfo call({
    Uri url,
    String? title,
    BrowserIcon? favicon,
    Set<Uri>? feeds,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfWebPageInfo.copyWith(...)` or call `instanceOfWebPageInfo.copyWith.fieldName(value)` for a single field.
class _$WebPageInfoCWProxyImpl implements _$WebPageInfoCWProxy {
  const _$WebPageInfoCWProxyImpl(this._value);

  final WebPageInfo _value;

  @override
  WebPageInfo url(Uri url) => call(url: url);

  @override
  WebPageInfo title(String? title) => call(title: title);

  @override
  WebPageInfo favicon(BrowserIcon? favicon) => call(favicon: favicon);

  @override
  WebPageInfo feeds(Set<Uri>? feeds) => call(feeds: feeds);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `WebPageInfo(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// WebPageInfo(...).copyWith(id: 12, name: "My name")
  /// ```
  WebPageInfo call({
    Object? url = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? favicon = const $CopyWithPlaceholder(),
    Object? feeds = const $CopyWithPlaceholder(),
  }) {
    return WebPageInfo(
      url: url == const $CopyWithPlaceholder() || url == null
          ? _value.url
          // ignore: cast_nullable_to_non_nullable
          : url as Uri,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String?,
      favicon: favicon == const $CopyWithPlaceholder()
          ? _value.favicon
          // ignore: cast_nullable_to_non_nullable
          : favicon as BrowserIcon?,
      feeds: feeds == const $CopyWithPlaceholder()
          ? _value.feeds
          // ignore: cast_nullable_to_non_nullable
          : feeds as Set<Uri>?,
    );
  }
}

extension $WebPageInfoCopyWith on WebPageInfo {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfWebPageInfo.copyWith(...)` or `instanceOfWebPageInfo.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WebPageInfoCWProxy get copyWith => _$WebPageInfoCWProxyImpl(this);
}
