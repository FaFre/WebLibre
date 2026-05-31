// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gesture_stroke.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GestureStrokeCWProxy {
  GestureStroke startPosition(GestureStartPosition startPosition);

  GestureStroke fingers(int fingers);

  GestureStroke arrows(List<GestureArrow> arrows);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `GestureStroke(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// GestureStroke(...).copyWith(id: 12, name: "My name")
  /// ```
  GestureStroke call({
    GestureStartPosition startPosition,
    int fingers,
    List<GestureArrow> arrows,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfGestureStroke.copyWith(...)` or call `instanceOfGestureStroke.copyWith.fieldName(value)` for a single field.
class _$GestureStrokeCWProxyImpl implements _$GestureStrokeCWProxy {
  const _$GestureStrokeCWProxyImpl(this._value);

  final GestureStroke _value;

  @override
  GestureStroke startPosition(GestureStartPosition startPosition) =>
      call(startPosition: startPosition);

  @override
  GestureStroke fingers(int fingers) => call(fingers: fingers);

  @override
  GestureStroke arrows(List<GestureArrow> arrows) => call(arrows: arrows);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `GestureStroke(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// GestureStroke(...).copyWith(id: 12, name: "My name")
  /// ```
  GestureStroke call({
    Object? startPosition = const $CopyWithPlaceholder(),
    Object? fingers = const $CopyWithPlaceholder(),
    Object? arrows = const $CopyWithPlaceholder(),
  }) {
    return GestureStroke(
      startPosition:
          startPosition == const $CopyWithPlaceholder() || startPosition == null
          ? _value.startPosition
          // ignore: cast_nullable_to_non_nullable
          : startPosition as GestureStartPosition,
      fingers: fingers == const $CopyWithPlaceholder() || fingers == null
          ? _value.fingers
          // ignore: cast_nullable_to_non_nullable
          : fingers as int,
      arrows: arrows == const $CopyWithPlaceholder() || arrows == null
          ? _value.arrows
          // ignore: cast_nullable_to_non_nullable
          : arrows as List<GestureArrow>,
    );
  }
}

extension $GestureStrokeCopyWith on GestureStroke {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfGestureStroke.copyWith(...)` or `instanceOfGestureStroke.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GestureStrokeCWProxy get copyWith => _$GestureStrokeCWProxyImpl(this);
}
