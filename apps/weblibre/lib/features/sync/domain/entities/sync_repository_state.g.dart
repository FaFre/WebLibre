// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_repository_state.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SyncRepositoryStateCWProxy {
  SyncRepositoryState account(SyncAccountInfo account);

  SyncRepositoryState remoteTabs(List<SyncDeviceTabs> remoteTabs);

  SyncRepositoryState devices(List<SyncDevice> devices);

  SyncRepositoryState deviceName(String? deviceName);

  SyncRepositoryState lastSyncEvent(SyncEvent? lastSyncEvent);

  SyncRepositoryState lastSyncError(String? lastSyncError);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `SyncRepositoryState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// SyncRepositoryState(...).copyWith(id: 12, name: "My name")
  /// ```
  SyncRepositoryState call({
    SyncAccountInfo account,
    List<SyncDeviceTabs> remoteTabs,
    List<SyncDevice> devices,
    String? deviceName,
    SyncEvent? lastSyncEvent,
    String? lastSyncError,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfSyncRepositoryState.copyWith(...)` or call `instanceOfSyncRepositoryState.copyWith.fieldName(value)` for a single field.
class _$SyncRepositoryStateCWProxyImpl implements _$SyncRepositoryStateCWProxy {
  const _$SyncRepositoryStateCWProxyImpl(this._value);

  final SyncRepositoryState _value;

  @override
  SyncRepositoryState account(SyncAccountInfo account) =>
      call(account: account);

  @override
  SyncRepositoryState remoteTabs(List<SyncDeviceTabs> remoteTabs) =>
      call(remoteTabs: remoteTabs);

  @override
  SyncRepositoryState devices(List<SyncDevice> devices) =>
      call(devices: devices);

  @override
  SyncRepositoryState deviceName(String? deviceName) =>
      call(deviceName: deviceName);

  @override
  SyncRepositoryState lastSyncEvent(SyncEvent? lastSyncEvent) =>
      call(lastSyncEvent: lastSyncEvent);

  @override
  SyncRepositoryState lastSyncError(String? lastSyncError) =>
      call(lastSyncError: lastSyncError);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `SyncRepositoryState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// SyncRepositoryState(...).copyWith(id: 12, name: "My name")
  /// ```
  SyncRepositoryState call({
    Object? account = const $CopyWithPlaceholder(),
    Object? remoteTabs = const $CopyWithPlaceholder(),
    Object? devices = const $CopyWithPlaceholder(),
    Object? deviceName = const $CopyWithPlaceholder(),
    Object? lastSyncEvent = const $CopyWithPlaceholder(),
    Object? lastSyncError = const $CopyWithPlaceholder(),
  }) {
    return SyncRepositoryState(
      account: account == const $CopyWithPlaceholder() || account == null
          ? _value.account
          // ignore: cast_nullable_to_non_nullable
          : account as SyncAccountInfo,
      remoteTabs:
          remoteTabs == const $CopyWithPlaceholder() || remoteTabs == null
          ? _value.remoteTabs
          // ignore: cast_nullable_to_non_nullable
          : remoteTabs as List<SyncDeviceTabs>,
      devices: devices == const $CopyWithPlaceholder() || devices == null
          ? _value.devices
          // ignore: cast_nullable_to_non_nullable
          : devices as List<SyncDevice>,
      deviceName: deviceName == const $CopyWithPlaceholder()
          ? _value.deviceName
          // ignore: cast_nullable_to_non_nullable
          : deviceName as String?,
      lastSyncEvent: lastSyncEvent == const $CopyWithPlaceholder()
          ? _value.lastSyncEvent
          // ignore: cast_nullable_to_non_nullable
          : lastSyncEvent as SyncEvent?,
      lastSyncError: lastSyncError == const $CopyWithPlaceholder()
          ? _value.lastSyncError
          // ignore: cast_nullable_to_non_nullable
          : lastSyncError as String?,
    );
  }
}

extension $SyncRepositoryStateCopyWith on SyncRepositoryState {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfSyncRepositoryState.copyWith(...)` or `instanceOfSyncRepositoryState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SyncRepositoryStateCWProxy get copyWith =>
      _$SyncRepositoryStateCWProxyImpl(this);
}
