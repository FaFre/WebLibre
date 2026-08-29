// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallpaper_override.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$WallpaperOverrideCWProxy {
  WallpaperOverride file(String file);

  WallpaperOverride blur(double? blur);

  WallpaperOverride dim(double? dim);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `WallpaperOverride(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// WallpaperOverride(...).copyWith(id: 12, name: "My name")
  /// ```
  WallpaperOverride call({String file, double? blur, double? dim});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfWallpaperOverride.copyWith(...)` or call `instanceOfWallpaperOverride.copyWith.fieldName(value)` for a single field.
class _$WallpaperOverrideCWProxyImpl implements _$WallpaperOverrideCWProxy {
  const _$WallpaperOverrideCWProxyImpl(this._value);

  final WallpaperOverride _value;

  @override
  WallpaperOverride file(String file) => call(file: file);

  @override
  WallpaperOverride blur(double? blur) => call(blur: blur);

  @override
  WallpaperOverride dim(double? dim) => call(dim: dim);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `WallpaperOverride(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// WallpaperOverride(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  WallpaperOverride call({
    Object? file = const $CopyWithPlaceholder(),
    Object? blur = const $CopyWithPlaceholder(),
    Object? dim = const $CopyWithPlaceholder(),
  }) {
    return WallpaperOverride(
      file: file == const $CopyWithPlaceholder() || file == null
          ? _value.file
          // ignore: cast_nullable_to_non_nullable
          : file as String,
      blur: blur == const $CopyWithPlaceholder()
          ? _value.blur
          // ignore: cast_nullable_to_non_nullable
          : blur as double?,
      dim: dim == const $CopyWithPlaceholder()
          ? _value.dim
          // ignore: cast_nullable_to_non_nullable
          : dim as double?,
    );
  }
}

extension $WallpaperOverrideCopyWith on WallpaperOverride {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfWallpaperOverride.copyWith(...)` or `instanceOfWallpaperOverride.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$WallpaperOverrideCWProxy get copyWith =>
      _$WallpaperOverrideCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WallpaperOverride _$WallpaperOverrideFromJson(Map<String, dynamic> json) =>
    WallpaperOverride.withDefaults(
      file: json['file'] as String,
      blur: (json['blur'] as num?)?.toDouble(),
      dim: (json['dim'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$WallpaperOverrideToJson(WallpaperOverride instance) =>
    <String, dynamic>{
      'file': instance.file,
      'blur': instance.blur,
      'dim': instance.dim,
    };
