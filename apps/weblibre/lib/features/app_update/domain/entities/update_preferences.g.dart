// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_preferences.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UpdateMiscStateCWProxy {
  UpdateMiscState lastAttempt(DateTime? lastAttempt);

  UpdateMiscState lastSuccess(DateTime? lastSuccess);

  UpdateMiscState backoffStep(int backoffStep);

  UpdateMiscState announcedSequence(int? announcedSequence);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `UpdateMiscState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// UpdateMiscState(...).copyWith(id: 12, name: "My name")
  /// ```
  UpdateMiscState call({
    DateTime? lastAttempt,
    DateTime? lastSuccess,
    int backoffStep,
    int? announcedSequence,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfUpdateMiscState.copyWith(...)` or call `instanceOfUpdateMiscState.copyWith.fieldName(value)` for a single field.
class _$UpdateMiscStateCWProxyImpl implements _$UpdateMiscStateCWProxy {
  const _$UpdateMiscStateCWProxyImpl(this._value);

  final UpdateMiscState _value;

  @override
  UpdateMiscState lastAttempt(DateTime? lastAttempt) =>
      call(lastAttempt: lastAttempt);

  @override
  UpdateMiscState lastSuccess(DateTime? lastSuccess) =>
      call(lastSuccess: lastSuccess);

  @override
  UpdateMiscState backoffStep(int backoffStep) =>
      call(backoffStep: backoffStep);

  @override
  UpdateMiscState announcedSequence(int? announcedSequence) =>
      call(announcedSequence: announcedSequence);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `UpdateMiscState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// UpdateMiscState(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  UpdateMiscState call({
    Object? lastAttempt = const $CopyWithPlaceholder(),
    Object? lastSuccess = const $CopyWithPlaceholder(),
    Object? backoffStep = const $CopyWithPlaceholder(),
    Object? announcedSequence = const $CopyWithPlaceholder(),
  }) {
    return UpdateMiscState(
      lastAttempt: lastAttempt == const $CopyWithPlaceholder()
          ? _value.lastAttempt
          // ignore: cast_nullable_to_non_nullable
          : lastAttempt as DateTime?,
      lastSuccess: lastSuccess == const $CopyWithPlaceholder()
          ? _value.lastSuccess
          // ignore: cast_nullable_to_non_nullable
          : lastSuccess as DateTime?,
      backoffStep:
          backoffStep == const $CopyWithPlaceholder() || backoffStep == null
          ? _value.backoffStep
          // ignore: cast_nullable_to_non_nullable
          : backoffStep as int,
      announcedSequence: announcedSequence == const $CopyWithPlaceholder()
          ? _value.announcedSequence
          // ignore: cast_nullable_to_non_nullable
          : announcedSequence as int?,
    );
  }
}

extension $UpdateMiscStateCopyWith on UpdateMiscState {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfUpdateMiscState.copyWith(...)` or `instanceOfUpdateMiscState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UpdateMiscStateCWProxy get copyWith => _$UpdateMiscStateCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdatePreferences _$UpdatePreferencesFromJson(Map<String, dynamic> json) =>
    $checkedCreate('UpdatePreferences', json, ($checkedConvert) {
      final val = UpdatePreferences(
        automaticChecks: $checkedConvert('automaticChecks', (v) => v as bool),
        recoveryRequired: $checkedConvert(
          'recoveryRequired',
          (v) => v as bool? ?? false,
        ),
      );
      return val;
    });

Map<String, dynamic> _$UpdatePreferencesToJson(UpdatePreferences instance) =>
    <String, dynamic>{
      'automaticChecks': instance.automaticChecks,
      'recoveryRequired': instance.recoveryRequired,
    };

UpdateMiscState _$UpdateMiscStateFromJson(Map<String, dynamic> json) =>
    $checkedCreate('UpdateMiscState', json, ($checkedConvert) {
      final val = UpdateMiscState(
        lastAttempt: $checkedConvert('lastAttempt', (v) => dateTimeOrNull(v)),
        lastSuccess: $checkedConvert('lastSuccess', (v) => dateTimeOrNull(v)),
        backoffStep: $checkedConvert(
          'backoffStep',
          (v) => (v as num?)?.toInt() ?? 0,
        ),
        announcedSequence: $checkedConvert(
          'announcedSequence',
          (v) => (v as num?)?.toInt(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$UpdateMiscStateToJson(UpdateMiscState instance) =>
    <String, dynamic>{
      'lastAttempt': ?utcIsoOrNull(instance.lastAttempt),
      'lastSuccess': ?utcIsoOrNull(instance.lastSuccess),
      'backoffStep': instance.backoffStep,
      'announcedSequence': ?instance.announcedSequence,
    };
