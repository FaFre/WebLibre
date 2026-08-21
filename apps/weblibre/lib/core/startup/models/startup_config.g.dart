// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'startup_config.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MaintenanceTaskCWProxy {
  MaintenanceTask actionId(String actionId);

  MaintenanceTask stateId(String stateId);

  MaintenanceTask profileId(String profileId);

  MaintenanceTask profileName(String profileName);

  MaintenanceTask createdAt(DateTime createdAt);

  MaintenanceTask targetTreeUri(String? targetTreeUri);

  MaintenanceTask sourceFileUri(String? sourceFileUri);

  MaintenanceTask sourceDigest(String? sourceDigest);

  MaintenanceTask integrityCheck(bool integrityCheck);

  MaintenanceTask adoptArchiveName(bool adoptArchiveName);

  MaintenanceTask startedAt(DateTime? startedAt);

  MaintenanceTask error(String? error);

  MaintenanceTask errorKindId(String? errorKindId);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `MaintenanceTask(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// MaintenanceTask(...).copyWith(id: 12, name: "My name")
  /// ```
  MaintenanceTask call({
    String actionId,
    String stateId,
    String profileId,
    String profileName,
    DateTime createdAt,
    String? targetTreeUri,
    String? sourceFileUri,
    String? sourceDigest,
    bool integrityCheck,
    bool adoptArchiveName,
    DateTime? startedAt,
    String? error,
    String? errorKindId,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfMaintenanceTask.copyWith(...)` or call `instanceOfMaintenanceTask.copyWith.fieldName(value)` for a single field.
class _$MaintenanceTaskCWProxyImpl implements _$MaintenanceTaskCWProxy {
  const _$MaintenanceTaskCWProxyImpl(this._value);

  final MaintenanceTask _value;

  @override
  MaintenanceTask actionId(String actionId) => call(actionId: actionId);

  @override
  MaintenanceTask stateId(String stateId) => call(stateId: stateId);

  @override
  MaintenanceTask profileId(String profileId) => call(profileId: profileId);

  @override
  MaintenanceTask profileName(String profileName) =>
      call(profileName: profileName);

  @override
  MaintenanceTask createdAt(DateTime createdAt) => call(createdAt: createdAt);

  @override
  MaintenanceTask targetTreeUri(String? targetTreeUri) =>
      call(targetTreeUri: targetTreeUri);

  @override
  MaintenanceTask sourceFileUri(String? sourceFileUri) =>
      call(sourceFileUri: sourceFileUri);

  @override
  MaintenanceTask sourceDigest(String? sourceDigest) =>
      call(sourceDigest: sourceDigest);

  @override
  MaintenanceTask integrityCheck(bool integrityCheck) =>
      call(integrityCheck: integrityCheck);

  @override
  MaintenanceTask adoptArchiveName(bool adoptArchiveName) =>
      call(adoptArchiveName: adoptArchiveName);

  @override
  MaintenanceTask startedAt(DateTime? startedAt) => call(startedAt: startedAt);

  @override
  MaintenanceTask error(String? error) => call(error: error);

  @override
  MaintenanceTask errorKindId(String? errorKindId) =>
      call(errorKindId: errorKindId);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `MaintenanceTask(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// MaintenanceTask(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  MaintenanceTask call({
    Object? actionId = const $CopyWithPlaceholder(),
    Object? stateId = const $CopyWithPlaceholder(),
    Object? profileId = const $CopyWithPlaceholder(),
    Object? profileName = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? targetTreeUri = const $CopyWithPlaceholder(),
    Object? sourceFileUri = const $CopyWithPlaceholder(),
    Object? sourceDigest = const $CopyWithPlaceholder(),
    Object? integrityCheck = const $CopyWithPlaceholder(),
    Object? adoptArchiveName = const $CopyWithPlaceholder(),
    Object? startedAt = const $CopyWithPlaceholder(),
    Object? error = const $CopyWithPlaceholder(),
    Object? errorKindId = const $CopyWithPlaceholder(),
  }) {
    return MaintenanceTask(
      id: _value.id,
      actionId: actionId == const $CopyWithPlaceholder() || actionId == null
          ? _value.actionId
          // ignore: cast_nullable_to_non_nullable
          : actionId as String,
      stateId: stateId == const $CopyWithPlaceholder() || stateId == null
          ? _value.stateId
          // ignore: cast_nullable_to_non_nullable
          : stateId as String,
      profileId: profileId == const $CopyWithPlaceholder() || profileId == null
          ? _value.profileId
          // ignore: cast_nullable_to_non_nullable
          : profileId as String,
      profileName:
          profileName == const $CopyWithPlaceholder() || profileName == null
          ? _value.profileName
          // ignore: cast_nullable_to_non_nullable
          : profileName as String,
      createdAt: createdAt == const $CopyWithPlaceholder() || createdAt == null
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      targetTreeUri: targetTreeUri == const $CopyWithPlaceholder()
          ? _value.targetTreeUri
          // ignore: cast_nullable_to_non_nullable
          : targetTreeUri as String?,
      sourceFileUri: sourceFileUri == const $CopyWithPlaceholder()
          ? _value.sourceFileUri
          // ignore: cast_nullable_to_non_nullable
          : sourceFileUri as String?,
      sourceDigest: sourceDigest == const $CopyWithPlaceholder()
          ? _value.sourceDigest
          // ignore: cast_nullable_to_non_nullable
          : sourceDigest as String?,
      integrityCheck:
          integrityCheck == const $CopyWithPlaceholder() ||
              integrityCheck == null
          ? _value.integrityCheck
          // ignore: cast_nullable_to_non_nullable
          : integrityCheck as bool,
      adoptArchiveName:
          adoptArchiveName == const $CopyWithPlaceholder() ||
              adoptArchiveName == null
          ? _value.adoptArchiveName
          // ignore: cast_nullable_to_non_nullable
          : adoptArchiveName as bool,
      startedAt: startedAt == const $CopyWithPlaceholder()
          ? _value.startedAt
          // ignore: cast_nullable_to_non_nullable
          : startedAt as DateTime?,
      error: error == const $CopyWithPlaceholder()
          ? _value.error
          // ignore: cast_nullable_to_non_nullable
          : error as String?,
      errorKindId: errorKindId == const $CopyWithPlaceholder()
          ? _value.errorKindId
          // ignore: cast_nullable_to_non_nullable
          : errorKindId as String?,
    );
  }
}

extension $MaintenanceTaskCopyWith on MaintenanceTask {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfMaintenanceTask.copyWith(...)` or `instanceOfMaintenanceTask.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MaintenanceTaskCWProxy get copyWith => _$MaintenanceTaskCWProxyImpl(this);
}

abstract class _$StartupConfigCWProxy {
  StartupConfig version(int version);

  StartupConfig profilePrompt(ProfilePromptMode profilePrompt);

  StartupConfig honorShortcutProfile(bool honorShortcutProfile);

  StartupConfig pendingTasks(List<MaintenanceTask> pendingTasks);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `StartupConfig(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// StartupConfig(...).copyWith(id: 12, name: "My name")
  /// ```
  StartupConfig call({
    int version,
    ProfilePromptMode profilePrompt,
    bool honorShortcutProfile,
    List<MaintenanceTask> pendingTasks,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfStartupConfig.copyWith(...)` or call `instanceOfStartupConfig.copyWith.fieldName(value)` for a single field.
class _$StartupConfigCWProxyImpl implements _$StartupConfigCWProxy {
  const _$StartupConfigCWProxyImpl(this._value);

  final StartupConfig _value;

  @override
  StartupConfig version(int version) => call(version: version);

  @override
  StartupConfig profilePrompt(ProfilePromptMode profilePrompt) =>
      call(profilePrompt: profilePrompt);

  @override
  StartupConfig honorShortcutProfile(bool honorShortcutProfile) =>
      call(honorShortcutProfile: honorShortcutProfile);

  @override
  StartupConfig pendingTasks(List<MaintenanceTask> pendingTasks) =>
      call(pendingTasks: pendingTasks);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `StartupConfig(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// StartupConfig(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  StartupConfig call({
    Object? version = const $CopyWithPlaceholder(),
    Object? profilePrompt = const $CopyWithPlaceholder(),
    Object? honorShortcutProfile = const $CopyWithPlaceholder(),
    Object? pendingTasks = const $CopyWithPlaceholder(),
  }) {
    return StartupConfig(
      version: version == const $CopyWithPlaceholder() || version == null
          ? _value.version
          // ignore: cast_nullable_to_non_nullable
          : version as int,
      profilePrompt:
          profilePrompt == const $CopyWithPlaceholder() || profilePrompt == null
          ? _value.profilePrompt
          // ignore: cast_nullable_to_non_nullable
          : profilePrompt as ProfilePromptMode,
      honorShortcutProfile:
          honorShortcutProfile == const $CopyWithPlaceholder() ||
              honorShortcutProfile == null
          ? _value.honorShortcutProfile
          // ignore: cast_nullable_to_non_nullable
          : honorShortcutProfile as bool,
      pendingTasks:
          pendingTasks == const $CopyWithPlaceholder() || pendingTasks == null
          ? _value.pendingTasks
          // ignore: cast_nullable_to_non_nullable
          : pendingTasks as List<MaintenanceTask>,
    );
  }
}

extension $StartupConfigCopyWith on StartupConfig {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfStartupConfig.copyWith(...)` or `instanceOfStartupConfig.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$StartupConfigCWProxy get copyWith => _$StartupConfigCWProxyImpl(this);
}
