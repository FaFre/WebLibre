// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restart_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RestartRequestCWProxy {
  RestartRequest reason(String reason);

  RestartRequest processInstanceId(String processInstanceId);

  RestartRequest stateId(String stateId);

  RestartRequest createdAt(DateTime createdAt);

  RestartRequest expiresAt(DateTime expiresAt);

  RestartRequest version(int version);

  RestartRequest targetProfileId(String? targetProfileId);

  RestartRequest brokerEntryId(String? brokerEntryId);

  RestartRequest appliedAt(DateTime? appliedAt);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RestartRequest(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RestartRequest(...).copyWith(id: 12, name: "My name")
  /// ```
  RestartRequest call({
    String reason,
    String processInstanceId,
    String stateId,
    DateTime createdAt,
    DateTime expiresAt,
    int version,
    String? targetProfileId,
    String? brokerEntryId,
    DateTime? appliedAt,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfRestartRequest.copyWith(...)` or call `instanceOfRestartRequest.copyWith.fieldName(value)` for a single field.
class _$RestartRequestCWProxyImpl implements _$RestartRequestCWProxy {
  const _$RestartRequestCWProxyImpl(this._value);

  final RestartRequest _value;

  @override
  RestartRequest reason(String reason) => call(reason: reason);

  @override
  RestartRequest processInstanceId(String processInstanceId) =>
      call(processInstanceId: processInstanceId);

  @override
  RestartRequest stateId(String stateId) => call(stateId: stateId);

  @override
  RestartRequest createdAt(DateTime createdAt) => call(createdAt: createdAt);

  @override
  RestartRequest expiresAt(DateTime expiresAt) => call(expiresAt: expiresAt);

  @override
  RestartRequest version(int version) => call(version: version);

  @override
  RestartRequest targetProfileId(String? targetProfileId) =>
      call(targetProfileId: targetProfileId);

  @override
  RestartRequest brokerEntryId(String? brokerEntryId) =>
      call(brokerEntryId: brokerEntryId);

  @override
  RestartRequest appliedAt(DateTime? appliedAt) => call(appliedAt: appliedAt);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `RestartRequest(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// RestartRequest(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  RestartRequest call({
    Object? reason = const $CopyWithPlaceholder(),
    Object? processInstanceId = const $CopyWithPlaceholder(),
    Object? stateId = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? expiresAt = const $CopyWithPlaceholder(),
    Object? version = const $CopyWithPlaceholder(),
    Object? targetProfileId = const $CopyWithPlaceholder(),
    Object? brokerEntryId = const $CopyWithPlaceholder(),
    Object? appliedAt = const $CopyWithPlaceholder(),
  }) {
    return RestartRequest(
      requestId: _value.requestId,
      reason: reason == const $CopyWithPlaceholder() || reason == null
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String,
      processInstanceId:
          processInstanceId == const $CopyWithPlaceholder() ||
              processInstanceId == null
          ? _value.processInstanceId
          // ignore: cast_nullable_to_non_nullable
          : processInstanceId as String,
      stateId: stateId == const $CopyWithPlaceholder() || stateId == null
          ? _value.stateId
          // ignore: cast_nullable_to_non_nullable
          : stateId as String,
      createdAt: createdAt == const $CopyWithPlaceholder() || createdAt == null
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      expiresAt: expiresAt == const $CopyWithPlaceholder() || expiresAt == null
          ? _value.expiresAt
          // ignore: cast_nullable_to_non_nullable
          : expiresAt as DateTime,
      version: version == const $CopyWithPlaceholder() || version == null
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
      targetProfileId: targetProfileId == const $CopyWithPlaceholder()
          ? _value.targetProfileId
          // ignore: cast_nullable_to_non_nullable
          : targetProfileId as String?,
      brokerEntryId: brokerEntryId == const $CopyWithPlaceholder()
          ? _value.brokerEntryId
          // ignore: cast_nullable_to_non_nullable
          : brokerEntryId as String?,
      appliedAt: appliedAt == const $CopyWithPlaceholder()
          ? _value.appliedAt
          // ignore: cast_nullable_to_non_nullable
          : appliedAt as DateTime?,
    );
  }
}

extension $RestartRequestCopyWith on RestartRequest {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfRestartRequest.copyWith(...)` or `instanceOfRestartRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RestartRequestCWProxy get copyWith => _$RestartRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RestartRequest _$RestartRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RestartRequest', json, ($checkedConvert) {
      final val = RestartRequest(
        requestId: $checkedConvert('requestId', (v) => requiredString(v)),
        reason: $checkedConvert('reason', (v) => stringOrEmpty(v)),
        processInstanceId: $checkedConvert(
          'processInstanceId',
          (v) => requiredString(v),
        ),
        stateId: $checkedConvert('state', (v) => RestartRequest._state(v)),
        createdAt: $checkedConvert('createdAt', (v) => requiredDateTime(v)),
        expiresAt: $checkedConvert('expiresAt', (v) => requiredDateTime(v)),
        version: $checkedConvert(
          'version',
          (v) => v == null ? restartRequestVersion : RestartRequest._version(v),
        ),
        targetProfileId: $checkedConvert(
          'targetProfileId',
          (v) => stringOrNull(v),
        ),
        brokerEntryId: $checkedConvert('brokerEntryId', (v) => stringOrNull(v)),
        appliedAt: $checkedConvert('appliedAt', (v) => dateTimeOrNull(v)),
      );
      return val;
    }, fieldKeyMap: const {'stateId': 'state'});

Map<String, dynamic> _$RestartRequestToJson(RestartRequest instance) =>
    <String, dynamic>{
      'version': instance.version,
      'requestId': instance.requestId,
      'targetProfileId': instance.targetProfileId,
      'brokerEntryId': instance.brokerEntryId,
      'reason': instance.reason,
      'processInstanceId': instance.processInstanceId,
      'state': instance.stateId,
      'createdAt': utcIso(instance.createdAt),
      'expiresAt': utcIso(instance.expiresAt),
      'appliedAt': utcIsoOrNull(instance.appliedAt),
    };
