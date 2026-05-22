// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'captured_page_state.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CapturedPageStateCWProxy {
  CapturedPageState sourceUrl(Uri sourceUrl);

  CapturedPageState status(CapturedPageStatus status);

  CapturedPageState captureId(String? captureId);

  CapturedPageState finalUrl(Uri? finalUrl);

  CapturedPageState filename(String? filename);

  CapturedPageState method(String? method);

  CapturedPageState variant(String? variant);

  CapturedPageState contentType(String? contentType);

  CapturedPageState byteLength(int? byteLength);

  CapturedPageState localPath(String? localPath);

  CapturedPageState downloadToken(String? downloadToken);

  CapturedPageState errorMessage(String? errorMessage);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `CapturedPageState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// CapturedPageState(...).copyWith(id: 12, name: "My name")
  /// ```
  CapturedPageState call({
    Uri sourceUrl,
    CapturedPageStatus status,
    String? captureId,
    Uri? finalUrl,
    String? filename,
    String? method,
    String? variant,
    String? contentType,
    int? byteLength,
    String? localPath,
    String? downloadToken,
    String? errorMessage,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfCapturedPageState.copyWith(...)` or call `instanceOfCapturedPageState.copyWith.fieldName(value)` for a single field.
class _$CapturedPageStateCWProxyImpl implements _$CapturedPageStateCWProxy {
  const _$CapturedPageStateCWProxyImpl(this._value);

  final CapturedPageState _value;

  @override
  CapturedPageState sourceUrl(Uri sourceUrl) => call(sourceUrl: sourceUrl);

  @override
  CapturedPageState status(CapturedPageStatus status) => call(status: status);

  @override
  CapturedPageState captureId(String? captureId) => call(captureId: captureId);

  @override
  CapturedPageState finalUrl(Uri? finalUrl) => call(finalUrl: finalUrl);

  @override
  CapturedPageState filename(String? filename) => call(filename: filename);

  @override
  CapturedPageState method(String? method) => call(method: method);

  @override
  CapturedPageState variant(String? variant) => call(variant: variant);

  @override
  CapturedPageState contentType(String? contentType) =>
      call(contentType: contentType);

  @override
  CapturedPageState byteLength(int? byteLength) => call(byteLength: byteLength);

  @override
  CapturedPageState localPath(String? localPath) => call(localPath: localPath);

  @override
  CapturedPageState downloadToken(String? downloadToken) =>
      call(downloadToken: downloadToken);

  @override
  CapturedPageState errorMessage(String? errorMessage) =>
      call(errorMessage: errorMessage);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `CapturedPageState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// CapturedPageState(...).copyWith(id: 12, name: "My name")
  /// ```
  CapturedPageState call({
    Object? sourceUrl = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? captureId = const $CopyWithPlaceholder(),
    Object? finalUrl = const $CopyWithPlaceholder(),
    Object? filename = const $CopyWithPlaceholder(),
    Object? method = const $CopyWithPlaceholder(),
    Object? variant = const $CopyWithPlaceholder(),
    Object? contentType = const $CopyWithPlaceholder(),
    Object? byteLength = const $CopyWithPlaceholder(),
    Object? localPath = const $CopyWithPlaceholder(),
    Object? downloadToken = const $CopyWithPlaceholder(),
    Object? errorMessage = const $CopyWithPlaceholder(),
  }) {
    return CapturedPageState(
      sourceUrl: sourceUrl == const $CopyWithPlaceholder() || sourceUrl == null
          ? _value.sourceUrl
          // ignore: cast_nullable_to_non_nullable
          : sourceUrl as Uri,
      status: status == const $CopyWithPlaceholder() || status == null
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as CapturedPageStatus,
      captureId: captureId == const $CopyWithPlaceholder()
          ? _value.captureId
          // ignore: cast_nullable_to_non_nullable
          : captureId as String?,
      finalUrl: finalUrl == const $CopyWithPlaceholder()
          ? _value.finalUrl
          // ignore: cast_nullable_to_non_nullable
          : finalUrl as Uri?,
      filename: filename == const $CopyWithPlaceholder()
          ? _value.filename
          // ignore: cast_nullable_to_non_nullable
          : filename as String?,
      method: method == const $CopyWithPlaceholder()
          ? _value.method
          // ignore: cast_nullable_to_non_nullable
          : method as String?,
      variant: variant == const $CopyWithPlaceholder()
          ? _value.variant
          // ignore: cast_nullable_to_non_nullable
          : variant as String?,
      contentType: contentType == const $CopyWithPlaceholder()
          ? _value.contentType
          // ignore: cast_nullable_to_non_nullable
          : contentType as String?,
      byteLength: byteLength == const $CopyWithPlaceholder()
          ? _value.byteLength
          // ignore: cast_nullable_to_non_nullable
          : byteLength as int?,
      localPath: localPath == const $CopyWithPlaceholder()
          ? _value.localPath
          // ignore: cast_nullable_to_non_nullable
          : localPath as String?,
      downloadToken: downloadToken == const $CopyWithPlaceholder()
          ? _value.downloadToken
          // ignore: cast_nullable_to_non_nullable
          : downloadToken as String?,
      errorMessage: errorMessage == const $CopyWithPlaceholder()
          ? _value.errorMessage
          // ignore: cast_nullable_to_non_nullable
          : errorMessage as String?,
    );
  }
}

extension $CapturedPageStateCopyWith on CapturedPageState {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfCapturedPageState.copyWith(...)` or `instanceOfCapturedPageState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CapturedPageStateCWProxy get copyWith =>
      _$CapturedPageStateCWProxyImpl(this);
}
