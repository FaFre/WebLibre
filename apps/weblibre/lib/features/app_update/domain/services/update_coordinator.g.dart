// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_coordinator.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UpdateSnapshotCWProxy {
  UpdateSnapshot state(UpdateState state);

  UpdateSnapshot preferences(UpdatePreferences preferences);

  UpdateSnapshot lastSuccess(DateTime? lastSuccess);

  UpdateSnapshot pendingAnnouncement(UpdateAssessment? pendingAnnouncement);

  UpdateSnapshot updatedTo(String? updatedTo);

  UpdateSnapshot trustDamaged(bool trustDamaged);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `UpdateSnapshot(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// UpdateSnapshot(...).copyWith(id: 12, name: "My name")
  /// ```
  UpdateSnapshot call({
    UpdateState state,
    UpdatePreferences preferences,
    DateTime? lastSuccess,
    UpdateAssessment? pendingAnnouncement,
    String? updatedTo,
    bool trustDamaged,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfUpdateSnapshot.copyWith(...)` or call `instanceOfUpdateSnapshot.copyWith.fieldName(value)` for a single field.
class _$UpdateSnapshotCWProxyImpl implements _$UpdateSnapshotCWProxy {
  const _$UpdateSnapshotCWProxyImpl(this._value);

  final UpdateSnapshot _value;

  @override
  UpdateSnapshot state(UpdateState state) => call(state: state);

  @override
  UpdateSnapshot preferences(UpdatePreferences preferences) =>
      call(preferences: preferences);

  @override
  UpdateSnapshot lastSuccess(DateTime? lastSuccess) =>
      call(lastSuccess: lastSuccess);

  @override
  UpdateSnapshot pendingAnnouncement(UpdateAssessment? pendingAnnouncement) =>
      call(pendingAnnouncement: pendingAnnouncement);

  @override
  UpdateSnapshot updatedTo(String? updatedTo) => call(updatedTo: updatedTo);

  @override
  UpdateSnapshot trustDamaged(bool trustDamaged) =>
      call(trustDamaged: trustDamaged);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `UpdateSnapshot(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// UpdateSnapshot(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  UpdateSnapshot call({
    Object? state = const $CopyWithPlaceholder(),
    Object? preferences = const $CopyWithPlaceholder(),
    Object? lastSuccess = const $CopyWithPlaceholder(),
    Object? pendingAnnouncement = const $CopyWithPlaceholder(),
    Object? updatedTo = const $CopyWithPlaceholder(),
    Object? trustDamaged = const $CopyWithPlaceholder(),
  }) {
    return UpdateSnapshot(
      state: state == const $CopyWithPlaceholder() || state == null
          ? _value.state
          // ignore: cast_nullable_to_non_nullable
          : state as UpdateState,
      preferences:
          preferences == const $CopyWithPlaceholder() || preferences == null
          ? _value.preferences
          // ignore: cast_nullable_to_non_nullable
          : preferences as UpdatePreferences,
      lastSuccess: lastSuccess == const $CopyWithPlaceholder()
          ? _value.lastSuccess
          // ignore: cast_nullable_to_non_nullable
          : lastSuccess as DateTime?,
      pendingAnnouncement: pendingAnnouncement == const $CopyWithPlaceholder()
          ? _value.pendingAnnouncement
          // ignore: cast_nullable_to_non_nullable
          : pendingAnnouncement as UpdateAssessment?,
      updatedTo: updatedTo == const $CopyWithPlaceholder()
          ? _value.updatedTo
          // ignore: cast_nullable_to_non_nullable
          : updatedTo as String?,
      trustDamaged:
          trustDamaged == const $CopyWithPlaceholder() || trustDamaged == null
          ? _value.trustDamaged
          // ignore: cast_nullable_to_non_nullable
          : trustDamaged as bool,
    );
  }
}

extension $UpdateSnapshotCopyWith on UpdateSnapshot {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfUpdateSnapshot.copyWith(...)` or `instanceOfUpdateSnapshot.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UpdateSnapshotCWProxy get copyWith => _$UpdateSnapshotCWProxyImpl(this);
}
